---
title: TypeORM 커넥션
permalink: /wating/커넥션
---

```
TypeORM 설정 확인:

TypeORM의 ConnectionOptions 설정에서 커넥션 풀과 관련된 설정(max, idleTimeoutMillis)을 조정합니다.
```

```
mysql> SHOW PROCESSLIST;
+----+------+--------------------+----------+---------+------+-----------+------------------+
| Id | User | Host               | db       | Command | Time | State     | Info             |
+----+------+--------------------+----------+---------+------+-----------+------------------+
| 19 | yang | 192.168.65.1:57806 | mokakbab | Sleep   |   21 |           | NULL             |
| 20 | yang | 192.168.65.1:57807 | mokakbab | Sleep   |   21 |           | NULL             |
| 21 | yang | 192.168.65.1:57808 | mokakbab | Sleep   |   21 |           | NULL             |
| 22 | yang | localhost          | mokakbab | Query   |    0 | executing | SHOW PROCESSLIST |
+----+------+--------------------+----------+---------+------+-----------+------------------+
4 rows in set (0.00 sec)
```

```ts
async findAllV2(
        currentMemberId: number,
        cursor: number,
        limit: number = 10,
    ): Promise<any[]> {
        // EntityManager를 직접 사용해보기
        const manager = this.repository.manager;
        const articles = await manager.query(
            `
        WITH filtered_articles AS (
            SELECT id
            FROM articles
            WHERE id < ?
            ORDER BY id DESC
            LIMIT ?
        )
        SELECT
            article.id                     AS "articleId",
            article.title                  AS "title",
            article.content                AS "content",
            article.startTime              AS "startTime",
            article.endTime                AS "endTime",
            article.articleImage           AS "articleImage",
            article.createdAt              AS "createdAt",
            article.updatedAt              AS "updatedAt",
            member.id                      AS "memberId",
            member.name                    AS "memberName",
            member.nickname                AS "memberNickname",
            member.profileImage            AS "memberProfileImage",
            category.id                    AS "categoryId",
            category.name                  AS "categoryName",
            region.id                      AS "regionId",
            region.name                    AS "regionName",
            district.id                    AS "districtId",
            district.name                  AS "districtName"
        FROM 
            filtered_articles fa
            JOIN articles article ON article.id = fa.id
            INNER JOIN member ON member.id = article.memberId
            INNER JOIN category ON category.id = article.categoryId
            INNER JOIN region ON region.id = article.regionId
            INNER JOIN district ON district.id = article.districtId
        ORDER BY article.id DESC
    `,
            [cursor, limit],
        );

        const articleIds = articles.map(
            (article: { articleId: number }) => article.articleId,
        );

        const [likeCounts, participantCounts, likedArticles] =
            await Promise.all([
                manager.query(
                    `
                SELECT 
                    articleId,
                    COUNT(*) as "likeCount"
                FROM article_likes
                WHERE articleId IN (?)
                GROUP BY articleId
                `,
                    [articleIds],
                ),
                manager.query(
                    `
                SELECT 
                    articleId,
                    COUNT(*) as "participantCount"
                FROM participation
                WHERE status = 'ACTIVE' AND articleId IN (?)
                GROUP BY articleId
                `,
                    [articleIds],
                ),
                manager.query(
                    `
                SELECT DISTINCT articleId
                FROM article_likes
                WHERE memberId = ? AND articleId IN (?)
                `,
                    [currentMemberId, articleIds],
                ),
            ]);

        //void manager.release();

        return articles.map((article: { articleId: number }) => ({
            ...article,
            likeCount:
                likeCounts.find(
                    (lc: { articleId: number }) =>
                        lc.articleId === article.articleId,
                )?.likeCount || 0,
            participantCount:
                participantCounts.find(
                    (pc: { articleId: number }) =>
                        pc.articleId === article.articleId,
                )?.participantCount || 0,
            isLiked: likedArticles.some(
                (la: { articleId: number }) =>
                    la.articleId === article.articleId,
            ),
        }));
    }
```

- 대상 SQL이다.

### 직접적으로 Mager 호출 사용

- 직접적으로 `manager` 를 가져와서 사용하면 커넥션풀을 3개나 점유하는걸 알 수 있다.

```
mysql> SHOW PROCESSLIST;
+----+------+--------------------+----------+---------+------+-----------+------------------+
| Id | User | Host               | db       | Command | Time | State     | Info             |
+----+------+--------------------+----------+---------+------+-----------+------------------+
| 19 | yang | 192.168.65.1:57806 | mokakbab | Sleep   |   78 |           | NULL             |
| 20 | yang | 192.168.65.1:57807 | mokakbab | Sleep   |   78 |           | NULL             |
| 21 | yang | 192.168.65.1:57808 | mokakbab | Sleep   |   78 |           | NULL             |
| 22 | yang | localhost          | mokakbab | Query   |    0 | executing | SHOW PROCESSLIST |
+----+------+--------------------+----------+---------+------+-----------+------------------+
4 rows in set (0.02 sec)
```

### 핵심은 Promise.all 사용시 커넥션풀을 하나 더 만든다

```ts
// 병렬 실행을 위한 Promise.all
const [likeCounts, participantCounts, likedArticles] =
            await Promise.all([
                this.repository.query(
                    `
                SELECT 
                    articleId,
                    COUNT(*) as "likeCount"
                FROM article_likes
                WHERE articleId IN (?)
                GROUP BY articleId
                `,
                    [articleIds],
                ),
                this.repository.query(
                    `
                SELECT 
                    articleId,
                    COUNT(*) as "participantCount"
                FROM participation
                WHERE status = 'ACTIVE' AND articleId IN (?)
                GROUP BY articleId
                `,
                    [articleIds],
                ),
                this.repository.query(
                    `
                SELECT DISTINCT articleId
                FROM article_likes
                WHERE memberId = ? AND articleId IN (?)
                `,
                    [currentMemberId, articleIds],
                ),
            ]);

+----+------+--------------------+----------+---------+------+-----------+------------------+
| Id | User | Host               | db       | Command | Time | State     | Info             |
+----+------+--------------------+----------+---------+------+-----------+------------------+
| 14 | yang | 192.168.65.1:49150 | mokakbab | Sleep   |   43 |           | NULL             |
| 15 | yang | localhost          | mokakbab | Query   |    0 | executing | SHOW PROCESSLIST |
+----+------+--------------------+----------+---------+------+-----------+------------------+
2 rows in set (0.44 sec)
```

#### 개별 처리하면 커넥션 하나임

```ts
const likeCounts = await this.repository.query(
            `
                SELECT 
                    articleId,
                    COUNT(*) as "likeCount"
                FROM article_likes
                WHERE articleId IN (?)
                GROUP BY articleId
                `,
            [articleIds],
        );

        const participantCounts = await this.repository.query(
            `
                SELECT 
                    articleId,
                    COUNT(*) as "participantCount"
                FROM participation
                WHERE status = 'ACTIVE' AND articleId IN (?)
                GROUP BY articleId
                `,
            [articleIds],
        );

        const likedArticles = await this.repository.query(
            `
                SELECT DISTINCT articleId
                FROM article_likes
                WHERE memberId = ? AND articleId IN (?)
                `,
            [currentMemberId, articleIds],
        );
```

```
mysql> SHOW PROCESSLIST;
+----+------+--------------------+----------+---------+------+-----------+------------------+
| Id | User | Host               | db       | Command | Time | State     | Info             |
+----+------+--------------------+----------+---------+------+-----------+------------------+
| 25 | yang | localhost          | mokakbab | Query   |    0 | executing | SHOW PROCESSLIST |
| 26 | yang | 192.168.65.1:22194 | mokakbab | Sleep   |    8 |           | NULL             |
+----+------+--------------------+----------+---------+------+-----------+------------------+
2 rows in set (0.00 sec)
```

- 초기 데이터베이스 연결 커넥션
### Promise.all을 사용 할때마다 커넥션을 만드는걸까?

```ts
const articles = await this.repository.query(
            `
            WITH filtered_articles AS (
                SELECT id
                FROM articles
                WHERE id < ?
                ORDER BY id DESC
                LIMIT ?
            )
            SELECT
                article.id                     AS "articleId",
                article.title                  AS "title",
                article.content                AS "content",
                article.startTime              AS "startTime",
                article.endTime                AS "endTime",
                article.articleImage           AS "articleImage",
                article.createdAt              AS "createdAt",
                article.updatedAt              AS "updatedAt",
                member.id                      AS "memberId",
                member.name                    AS "memberName",
                member.nickname                AS "memberNickname",
                member.profileImage            AS "memberProfileImage",
                category.id                    AS "categoryId",
                category.name                  AS "categoryName",
                region.id                      AS "regionId",
                region.name                    AS "regionName",
                district.id                    AS "districtId",
                district.name                  AS "districtName"
            FROM 
                filtered_articles fa
                JOIN articles article ON article.id = fa.id
                INNER JOIN member ON member.id = article.memberId
                INNER JOIN category ON category.id = article.categoryId
                INNER JOIN region ON region.id = article.regionId
                INNER JOIN district ON district.id = article.districtId
            ORDER BY article.id DESC
        `,
            [cursor, limit],
        );


const [likeCounts, participantCounts] = await Promise.all([
	this.repository.query(
		`
			SELECT 
				articleId,
				COUNT(*) as "likeCount"
			FROM article_likes
			WHERE articleId IN (?)
			GROUP BY articleId
			`,
		[articleIds],
	),
	this.repository.query(
		`
			SELECT 
				articleId,
				COUNT(*) as "participantCount"
			FROM participation
			WHERE status = 'ACTIVE' AND articleId IN (?)
			GROUP BY articleId
			`,
		[articleIds],
	),
]);


const [likedArticles] = await Promise.all([
	this.repository.query(
		`
			SELECT DISTINCT articleId
			FROM article_likes
			WHERE memberId = ? AND articleId IN (?)
			`,
		[currentMemberId, articleIds],
	),
]);

```

- *그건 아니다 repository 쿼리 사용 이외에 Promise.all이든 settled든 1개를 무조건 더 추가로 생성한다고 이해하면 된다* 


### Promise.all로 커넥션 하나만 사용하기

```ts
async findAllV2(
        currentMemberId: number,
        cursor: number,
        limit: number = 10,
    ): Promise<any[]> {
        return await this.repository.manager.transaction(async (manager) => {
            const articles = await manager.query(
        ...


mysql> SHOW PROCESSLIST;
+----+------+--------------------+----------+---------+------+-----------+------------------+
| Id | User | Host               | db       | Command | Time | State     | Info             |
+----+------+--------------------+----------+---------+------+-----------+------------------+
| 34 | yang | localhost          | mokakbab | Query   |    0 | executing | SHOW PROCESSLIST |
| 35 | yang | 192.168.65.1:44292 | mokakbab | Sleep   |   59 |           | NULL             |
+----+------+--------------------+----------+---------+------+-----------+------------------+
2 rows in set (0.05 sec)
```


- 이런식으로 manager.transaction을 호출한다.
- 커넥션 하나만 사용 가능 해지기 때문에 현재 CPU1코어와 RAM1GB에서 커넥션을 좀 더 활용도 높게 사용하여 커넥션 마름 현상을 방지 할 수 있게 되는것이다.


### 그렇다면 커넥션은 언제 반환 되는지 정확히 이해해보자.

```ts
// typeorm 설정
connectionLimit: 2,

// Mysql conf 설정
max_connections = 2
```

- 자 이렇다면 이제 커넥션은 2개가 최대가 될것이다.

```ts
async findById(memberId: number) {
        const result = await this.membersRepository.findOne({
            where: {
                id: memberId,
            },
        });

        await this.sleep(300000);

        return result;
    }
```

- 커넥션 제한을 2개를 주었지만 `repository의 findOne` 이 await로 리졸브 되니 커넥션을 반납하여 api를 다시 호출 할 수 있었다.

#### 다음은 쿼리요청 repository부분을 끝까지 await를 하지 않았을때

```ts
@Get(":memberId")
    async getMember(@Param("memberId", new ParseIntPipe()) memberId: number) {
        const result = this.membersService.findById(memberId);
        await this.sleep(300000);
        return await result;
    }

// membersService
findById(memberId: number) {
        return this.membersRepository.findOne({
            where: {
                id: memberId,
            },
        });
    }
```

- 정확히는 `findOne` 메서드가 실행 되고 이게 리졸브 되야 그때 커넥션 사용하면서 쿼리 날리고 쿼리 결과 가져오고 커넥션 반납 하는거임.
- 정리하면 repository 메서드를 호출해서 쿼리를 실행 할 때 promise가 `pending` 상태일때는 쿼리도 실행이 되지 않고 커넥션 연결 자체가 발생 하지 않는다.

## 커넥션 풀 에러

```ts
@Get(":memberId")
getMember(@Param("memberId", new ParseIntPipe()) memberId: number) {
	return this.membersService.findById(memberId);
}

async findById(memberId: number) {
        return await this.membersRepository.query(
            `
            SELECT SLEEP(60) AS delay, id 
            FROM member 
            WHERE id = ?
        `,
            [memberId],
        );
    }

// 쿼리 요청 보낼때 1분 동안 쿼리 발생하게 만들어서 커넥션을 점유
```

- 현재 최대 커넥션 상태 : 2개
- `mysql` 사용자 접속용 1개 사용중
- 해당 슬립 쿼리로 커넥션 1개 점유
- 해당 상태에서 새로운 쿼리를 요청하는 api를 호출하면 아래와 같이 `Too many connections` 오류를 볼 수 있다.

```
{
    "statusCode": 500,
    "message": "Too many connections"
}
```

```
mysql> show processlist;
+----+------+--------------------+----------+---------+------+------------+----------------------------------------------------------------------------------+
| Id | User | Host               | db       | Command | Time | State      | Info                                                                             |
+----+------+--------------------+----------+---------+------+------------+----------------------------------------------------------------------------------+
| 25 | yang | localhost          | mokakbab | Query   |    0 | executing  | show processlist                                                                 |
| 27 | yang | 192.168.65.1:54792 | mokakbab | Query   |    4 | User sleep | SELECT SLEEP(60) AS delay, id 
            FROM member 
            WHERE id = 1 |
+----+------+--------------------+----------+---------+------+------------+----------------------------------------------------------------------------------+
2 rows in set (0.01 sec)
```


# 커넥션 결론

1. TypeORM에서 repository 함수를 사용할 때 해당 프로미스가 `resolved` 되는 순간 쿼리를 실행 후에 커넥션을 바로 반납한다.
	- 그냥 쉽게 쿼리 실행됨과 동시에 커넥션 반납한다.
2. `Promise.all` 을 사용하여 병렬처리를 하게 되면 커넥션을 새로 또 생성한다.
3. `repository.manger` 를 사용 하는것은 지양해야 한다.
4. 가장 좋은 방법은 `this.repository.manager.transaction(async (manager) =>` 를 이용하여 모든 쿼리를 사용 하는것이다.

```ts
const articles = await this.repository.query(
            `
            WITH filtered_articles AS (
                SELECT id
                FROM articles
                WHERE id < ?
                ORDER BY id DESC
                LIMIT ?
            )
            SELECT
                article.id                     AS "articleId",
                article.title                  AS "title",
                article.content                AS "content",
                article.startTime              AS "startTime",
                article.endTime                AS "endTime",
                article.articleImage           AS "articleImage",
                article.createdAt              AS "createdAt",
                article.updatedAt              AS "updatedAt",
                member.id                      AS "memberId",
                member.name                    AS "memberName",
                member.nickname                AS "memberNickname",
                member.profileImage            AS "memberProfileImage",
                category.id                    AS "categoryId",
                category.name                  AS "categoryName",
                region.id                      AS "regionId",
                region.name                    AS "regionName",
                district.id                    AS "districtId",
                district.name                  AS "districtName"
            FROM 
                filtered_articles fa
                JOIN articles article ON article.id = fa.id
                INNER JOIN member ON member.id = article.memberId
                INNER JOIN category ON category.id = article.categoryId
                INNER JOIN region ON region.id = article.regionId
                INNER JOIN district ON district.id = article.districtId
            ORDER BY article.id DESC
        `,
            [cursor, limit],
        );

        const articleIds = articles.map(
            (article: { articleId: number }) => article.articleId,
        );

        const [likeCounts, participantCounts, likedArticles] =
            await Promise.all([
                this.repository.query(
                    `
                    SELECT 
                        articleId,
                        COUNT(*) as "likeCount"
                    FROM article_likes
                    WHERE articleId IN (?)
                    GROUP BY articleId
                    `,
                    [articleIds],
                ),
                this.repository.query(
                    `
                    SELECT 
                        articleId,
                        COUNT(*) as "participantCount"
                    FROM participation
                    WHERE status = 'ACTIVE' AND articleId IN (?)
                    GROUP BY articleId
                    `,
                    [articleIds],
                ),
                this.repository.query(
                    `
                    SELECT DISTINCT articleId
                    FROM article_likes
                    WHERE memberId = ? AND articleId IN (?)
                    `,
                    [currentMemberId, articleIds],
                ),
            ]);

        return articles.map((article: { articleId: number }) => ({
            ...article,
            likeCount:
                likeCounts.find(
                    (lc: { articleId: number }) =>
                        lc.articleId === article.articleId,
                )?.likeCount || 0,
            participantCount:
                participantCounts.find(
                    (pc: { articleId: number }) =>
                        pc.articleId === article.articleId,
                )?.participantCount || 0,
            isLiked: likedArticles.some(
                (la: { articleId: number }) =>
                    la.articleId === article.articleId,
            ),
        }));
```

- 즉, 이러한 쿼리 요청 repository함수가 있다고 가정 하면 커넥션이 2개가 필요하게 되어서 `Exception: Too many connections` 에러가 발생하게 되어 버린다.

3. repository 내에서 만약에 manager를 사용하고자 하면 주의 해야한다. manager 사용시 각각의 쿼리마다 커넥션을 생성한다.

```ts
const likeCounts = await this.repository.manager.query(
            `
                SELECT 
                    articleId,
                    COUNT(*) as "likeCount"
                FROM article_likes
                WHERE articleId IN (?)
                GROUP BY articleId
                `,
            [articleIds],
        );

        const participantCounts = await this.repository.manager.query(
            `
                SELECT 
                    articleId,
                    COUNT(*) as "participantCount"
                FROM participation
                WHERE status = 'ACTIVE' AND articleId IN (?)
                GROUP BY articleId
                `,
            [articleIds],
        );

        const likedArticles = await this.repository.manager.query(
            `
                SELECT DISTINCT articleId
                FROM article_likes
                WHERE memberId = ? AND articleId IN (?)
                `,
            [currentMemberId, articleIds],
        );
```

- *각각 개별적으로 await를 쓰면 repository.manager도 커넥션 하나로 재사용한다.*

**문제는 repository.manager를 사용시에 Promise.all** 처럼 병렬 호출 했을때 문제가 발생한다.

```ts

// 1
const articles = await this.repository.manager.query()

// 2
const [likeCounts, participantCounts, likedArticles] =

await Promise.all([
	this.repository.manager.query();
	this.repository.manager.query();
	this.repository.manager.query();
]);

mysql> show processlist;
+----+------+--------------------+----------+---------+------+-----------+------------------+
| Id | User | Host               | db       | Command | Time | State     | Info             |
+----+------+--------------------+----------+---------+------+-----------+------------------+
| 35 | yang | localhost          | mokakbab | Query   |    0 | executing | show processlist |
| 36 | yang | 192.168.65.1:36443 | mokakbab | Sleep   |    2 |           | NULL             |
| 37 | yang | 192.168.65.1:36444 | mokakbab | Sleep   |    2 |           | NULL             |
| 38 | yang | 192.168.65.1:36445 | mokakbab | Sleep   |    2 |           | NULL             |
+----+------+--------------------+----------+---------+------+-----------+------------------+
4 rows in set (0.00 sec)
```

- **커넥션을 3개나 생성해버림** 

```ts
const [
	likeCounts,
	participantCounts,
	likedArticles,
	_likeCounts2,
	_participantCounts2,
] = await Promise.all([
this.repository.manager.query(),
this.repository.manager.query(),
this.repository.manager.query(),
this.repository.manager.query(),
this.repository.manager.query(),
]);
mysql> show processlist;
+----+------+--------------------+----------+---------+------+-----------+------------------+
| Id | User | Host               | db       | Command | Time | State     | Info             |
+----+------+--------------------+----------+---------+------+-----------+------------------+
| 35 | yang | localhost          | mokakbab | Query   |    0 | executing | show processlist |
| 40 | yang | 192.168.65.1:38607 | mokakbab | Sleep   |    2 |           | NULL             |
| 41 | yang | 192.168.65.1:38608 | mokakbab | Sleep   |    2 |           | NULL             |
| 42 | yang | 192.168.65.1:38609 | mokakbab | Sleep   |    2 |           | NULL             |
| 43 | yang | 192.168.65.1:38610 | mokakbab | Sleep   |    2 |           | NULL             |
+----+------+--------------------+----------+---------+------+-----------+------------------+
5 rows in set (0.00 sec)
```

- 쿼리를 2개를 더 늘리니까 커넥션을 하나 더 생성했다.

```ts
// manger아닌 repository를 사용해도 부족한 만큼 커넥션을 생성한다.
+----+------+--------------------+----------+---------+------+-----------+------------------+
| Id | User | Host               | db       | Command | Time | State     | Info             |
+----+------+--------------------+----------+---------+------+-----------+------------------+
| 45 | yang | localhost          | mokakbab | Query   |    0 | executing | show processlist |
| 46 | yang | 192.168.65.1:41732 | mokakbab | Sleep   |    2 |           | NULL             |
| 47 | yang | 192.168.65.1:41733 | mokakbab | Sleep   |    2 |           | NULL             |
| 48 | yang | 192.168.65.1:41735 | mokakbab | Sleep   |    2 |           | NULL             |
| 49 | yang | 192.168.65.1:41734 | mokakbab | Sleep   |    2 |           | NULL             |
+----+------+--------------------+----------+---------+------+-----------+------------------+
5 rows in set (0.02 sec)
```

- **마지막 정리**

```ts
// 커넥션 1개 생성
const articles = await this.repository.query();

// Promise all 병렬처리에 필요한 만큼 커넥션 n개 생성
const [
likeCounts,
participantCounts,
likedArticles,
_likeCounts2,
_participantCounts2,
] = await Promise.all([
...
]);

// 커넥션 재활용
const _articleIds2 = await this.repository.query();

// 위의 Promise all 커넥션 재활용
const [
_likeCounts3,
_participantCounts3,
_likedArticles3,
_likeCounts4,
_participantCounts4,
] = await Promise.all([
...
]);
```

- 커넥션 1개로 충분히 다 가능하지만 Promise.all을 사용하면 여러개의 커넥션을 생성 해버린다.

## 해결책

- `this.repository.manager.transaction(async (manager) =>` 

```ts
return await this.repository.manager.transaction(async (manager) => {
            const articles = await manager.query(
                `
            WITH filtered_articles AS (
                SELECT id
                FROM articles
                WHERE id < ?
                ORDER BY id DESC
                LIMIT ?
            )
            SELECT
                article.id                     AS "articleId",
                article.title                  AS "title",
                article.content                AS "content",
                article.startTime              AS "startTime",
                article.endTime                AS "endTime",
                article.articleImage           AS "articleImage",
                article.createdAt              AS "createdAt",
                article.updatedAt              AS "updatedAt",
                member.id                      AS "memberId",
                member.name                    AS "memberName",
                member.nickname                AS "memberNickname",
                member.profileImage            AS "memberProfileImage",
                category.id                    AS "categoryId",
                category.name                  AS "categoryName",
                region.id                      AS "regionId",
                region.name                    AS "regionName",
                district.id                    AS "districtId",
                district.name                  AS "districtName"
            FROM 
                filtered_articles fa
                JOIN articles article ON article.id = fa.id
                INNER JOIN member ON member.id = article.memberId
                INNER JOIN category ON category.id = article.categoryId
                INNER JOIN region ON region.id = article.regionId
                INNER JOIN district ON district.id = article.districtId
            ORDER BY article.id DESC
        `,
                [cursor, limit],
            );

            const articleIds = articles.map(
                (article: { articleId: number }) => article.articleId,
            );

            const [
                likeCounts,
                participantCounts,
                likedArticles,
                _likeCounts2,
                _participantCounts2,
            ] = await Promise.all([
                manager.query(
                    `
                SELECT
                    articleId,
                    COUNT(*) as "likeCount"
                FROM article_likes
                WHERE articleId IN (?)
                GROUP BY articleId
                `,
                    [articleIds],
                ),
                manager.query(
                    `
                SELECT
                    articleId,
                    COUNT(*) as "participantCount"
                FROM participation
                WHERE status = 'ACTIVE' AND articleId IN (?)
                GROUP BY articleId
                `,
                    [articleIds],
                ),
                manager.query(
                    `
                SELECT DISTINCT articleId
                FROM article_likes
                WHERE memberId = ? AND articleId IN (?)
                `,
                    [currentMemberId, articleIds],
                ),
                manager.query(
                    `
                SELECT COUNT(*) as "likeCount"
                FROM article_likes
                WHERE articleId IN (?)
                GROUP BY articleId
                `,
                    [articleIds],
                ),
                manager.query(
                    `
                SELECT COUNT(*) as "participantCount"
                FROM participation
                WHERE status = 'ACTIVE' AND articleId IN (?)
                GROUP BY articleId
                `,
                    [articleIds],
                ),
            ]);

            const _articleIds2 = await manager.query(
                `
            SELECT articleId
            FROM article_likes
            WHERE articleId IN (?)
            GROUP BY articleId
            `,
                [articleIds],
            );

            console.log(_articleIds2);

            const [
                _likeCounts3,
                _participantCounts3,
                _likedArticles3,
                _likeCounts4,
                _participantCounts4,
            ] = await Promise.all([
                manager.query(
                    `
                SELECT
                    articleId,
                    COUNT(*) as "likeCount"
                FROM article_likes
                WHERE articleId IN (?)
                GROUP BY articleId
                `,
                    [articleIds],
                ),
                manager.query(
                    `
                SELECT
                    articleId,
                    COUNT(*) as "participantCount"
                FROM participation
                WHERE status = 'ACTIVE' AND articleId IN (?)
                GROUP BY articleId
                `,
                    [articleIds],
                ),
                manager.query(
                    `
                SELECT DISTINCT articleId
                FROM article_likes
                WHERE memberId = ? AND articleId IN (?)
                `,
                    [currentMemberId, articleIds],
                ),
                manager.query(
                    `
                SELECT COUNT(*) as "likeCount"
                FROM article_likes
                WHERE articleId IN (?)
                GROUP BY articleId
                `,
                    [articleIds],
                ),
                manager.query(
                    `
                SELECT COUNT(*) as "participantCount"
                FROM participation
                WHERE status = 'ACTIVE' AND articleId IN (?)
                GROUP BY articleId
                `,
                    [articleIds],
                ),
            ]);

            return articles.map((article: { articleId: number }) => ({
                ...article,
                likeCount:
                    likeCounts.find(
                        (lc: { articleId: number }) =>
                            lc.articleId === article.articleId,
                    )?.likeCount || 0,
                participantCount:
                    participantCounts.find(
                        (pc: { articleId: number }) =>
                            pc.articleId === article.articleId,
                    )?.participantCount || 0,
                isLiked: likedArticles.some(
                    (la: { articleId: number }) =>
                        la.articleId === article.articleId,
                ),
            }));
        });

mysql> show processlist;
+----+------+--------------------+----------+---------+------+-----------+------------------+
| Id | User | Host               | db       | Command | Time | State     | Info             |
+----+------+--------------------+----------+---------+------+-----------+------------------+
| 62 | yang | localhost          | mokakbab | Query   |    0 | executing | show processlist |
| 63 | yang | 192.168.65.1:62879 | mokakbab | Sleep   |    5 |           | NULL             |
+----+------+--------------------+----------+---------+------+-----------+------------------+
2 rows in set (0.02 sec)
```

- *트랜잭션을 이용하면 하나의 커넥션을 사용하여 효율적으로 사용할 수 있다* 

# 심화과정

- 이 문제들을 잘 해결하지 못하면 `Too many connections` 오류를 계속 접하게 될것이다. 왜냐하면 특히나 `async await` 쿼리와 `Promise.all` 병렬 실행 쿼리를 작성 했을 때 Promise.all의 필요 커넥션이 병렬 쿼리 개수 -1만큼 생성될 가능성이 높기 때문에 충분히 실행 할 수 있음에도 `Too many connections` 에러를 던지게 된다.
- 하나의 repository내에서도 쓸데 없는 커넥션이 여러개 필요하게 되는데 그렇다면 여러 repository를 사용하거나 여러 `insert` 나 `update` 쿼리를 함께 쓰는 경우에는 어떻게 될까?
- 현재 모든 api들이 하나의 트랜잭션만 필요하다고 가정 했을때 그렇다면 하나의 커넥션만 있으면 된다.
	- 이를 어떻게 모니터링 하면 좋을까 api 호출 할때마다 커넥션을 확인 해야 될 노릇이다.
	- *이것을 해결 하기 위해서 controller 같은 곳에서 커넥션을 가지고 와서 컨트롤레이어에서 활용 하면어떨까*
- 스케일아웃된 여러 서버일경우에 또 한번의 문제점이 발생 할 가능성이 높다.(분산환경일때 문제점)
	- 커넥션 관리 자체를 최적화 해두지 않는다면 예를들어 위의 상황처럼 하나의 간단한 `select` api인데 커넥션을 4개 5개 생성 하고 반납하고 하지만 그 짧은 시간에 높은 트래픽이 들어온다면 커넥션을 기다리는 시간이 매우매우 길어질 수 있고 `Too many connections` 에러를 마주할 가능성이 높아진다.
	- 즉, 결국 모든 api에 트랜잭션과 커넥션 관리 자체를 최적화 해두어야지만 서버 `stateless` 상태를 만든 후에 서버를 스케일 아웃 하게 되면 좀 더 최적화해서 사용할 수 있게 된다.

## 개선방법

- 하나의 커넥션당 트랜잭션1개
- 다른 repository와 select, insert,update시에 커넥션이 어떻게 생성 되는지 알아봐야한다.
- 이것을 근데 새로운 api나 로직들을 만들때마다 커넥션 사용을 확인 수작업으로 하는것은 너무 오랜시간이 걸릴것 같다. 어떻게 하면 최적화 할 수 있는 커넥션 관리 방법이 있을지 고민을 해봐야 된다.
- 예를 들자면) 뱅커스 알고리즘을 통해서 1개의 `request`에서 1개의 트랜잭션에 1개의 커넥션이 아니라 지금처럼 2개의 커넥션 3개의 커넥션을 사용하는것이 발생 한다면 로그를 남기거나 슬랙에 훅메세지를 보내거나 할 수 있는 커넥션상태를 모니터링 할 수 있는것이 필요할것 같다.
- 이게 필요한 이유가 위에서처럼 서버가 스케일 아웃 될 경우도 있고 서비스 규모가 커질수록 커넥션 관리는 매우매우 중요하기 때문이다.
	- 커넥션 생성도 오버헤드가 발생하기 떄문이다.
- 병렬 실행 쿼리나 `async await` 쿼리를 사용할때를 잘 확인 해야한다.

### 문제1

- dataSource의 queryRunner와 repository는 다른 `connection` 을 생성한다.

```
@IsPublicDecorator(IsPublicEnum.PUBLIC)
    @Post("sign-up")
    async signUp(@Body() dto: RegisterMemberDto) {
        const queryRunner = this.dataSource.createQueryRunner();
        await queryRunner.connect();
        await queryRunner.startTransaction();

        try {
            const result = await this.authService.registerByEmail(
                dto,
                queryRunner,
            );

            await queryRunner.commitTransaction();

            return result;
        } catch (error) {
            await queryRunner.rollbackTransaction();
            throw error;
        } finally {
            await queryRunner.release();
        }
    }

const existMember = await this.membersService.existByEmail(dto.email);

        if (existMember) {
            throw new BusinessErrorException(
                MemberErrorCode.EMAIL_ALREADY_EXISTS,
            );
        }
....
```

- insert 부분을 제외하고 select부분은 굳이 트랜잭션 작업에 커밋 롤백에 포함 시킬 필요가 없는데 `repository` 와 `queryRunner` 를 함께 사용하면 2개의 커넥션이 생성된다.

## 투두 리스트

- 각각의 api에 커넥션 생성이 제대로 되고 있는지 커넥션 누수가 발생하고 있진 않은지 확인.
- `queryRunner, repository` 따로 따로 커넥선을 생성하기 때문에 이부분을 어떻게 해결 하면 좋을지 생각 해보자.

```ts
// create a new query runner
const queryRunner = dataSource.createQueryRunner()

// establish real database connection using our new query runner
await queryRunner.connect()

// now we can execute any queries on a query runner, for example:
await queryRunner.query("SELECT * FROM users")

// we can also access entity manager that works with connection created by a query runner:
const users = await queryRunner.manager.find(User)

// lets now open a new transaction:
await queryRunner.startTransaction()

try {
    // execute some operations on this transaction:
    await queryRunner.manager.save(user1)
    await queryRunner.manager.save(user2)
    await queryRunner.manager.save(photos)

    // commit transaction now:
    await queryRunner.commitTransaction()
} catch (err) {
    // since we have errors let's rollback changes we made
    await queryRunner.rollbackTransaction()
} finally {
    // you need to release query runner which is manually created:
    await queryRunner.release()
}
```

- 커넥션을 추적할 수 있는 방법을 고민 해봐야한다. 매번 실행 할때마다 커넥션이 올바르게 생성 되었는지 수동으로 확인 하는것은 굉장히 번거롭다.
- *queryRunner.connect()* 이부분을 어떻게 잘 활용하면 괜찮을것 같은데

# TypeORM 해당 동작은 맞다

- `Promise.all` 안의 쿼리들을 병렬적으로 처리 하기 위해서 해당 하는 커넥션 풀 개수를 생성하여 동작하는게 맞다. 하나의 커넥션을 사용하게 작성 했으니 지금 나는 `Promise.all` 을 쓸 필요가 없는거네.

## 동작은 맞으나 치명적 문제가 있다

- 정말로 의문점은 왜 유휴상태의 커넥션을 다시 재사용 하지 않는거지???
- 데드락 걸린다.

```
Waiting for table level lock
```

# 참고

- 키워드 : connection metric, connect tracing, OpenTelemetry
- [스택오버플로우에 히카리는 총 연결 활성 연결 유휴 연결 풀에서 연결 기다리는 대기중인 스레드 같은 메트릭을 노출 한다고 한다 이런 히카리와 비슷한것이 필요할것 같다](https://stackoverflow.com/questions/70106343/metrics-for-typeorm-postgres-connection-pool) 
- 커넥션 풀 공부 다시 딮하게 필요하다.
- 트랜잭션 공부가 딮하게 필요하다.
- [prisma는 커넥션풀 메트릭을 제공한다...](https://www.prisma.io/docs/orm/prisma-client/observability-and-logging/metrics) 
- [TypeORM에서 트레싱이나 매트릭에 대한 제안 이슈](https://github.com/typeorm/typeorm/issues/7406) 
- [TypeORM tracing을 위한 opentelemetry-instrunmentation-typeorm 라이브러리](https://www.npmjs.com/package/opentelemetry-instrumentation-typeorm) 
- [opentelemetry nestjs Instrumentation 라이브러리](https://www.npmjs.com/package/@opentelemetry/instrumentation-nestjs-core) 
- [네이버 커넥션풀 이해하기](https://d2.naver.com/helloworld/5102792) 

## TypeORM 버리는게 나을지도 모르겠다

- [Prisma Metrics 공식문서 제공](https://www.prisma.io/docs/orm/prisma-client/observability-and-logging/metrics) 
	- 프로메테우스와 연동도 제공.
- [Prisma OpenTelemetry tracing 공식 문서 제공](https://www.prisma.io/docs/orm/prisma-client/observability-and-logging/opentelemetry-tracing) 

### TypeORM에서 직접 만들어야 된다.

- `prisma` 에서 제공하는 메트릭을 참고하여서 직접 만들어야 한다.
- `pg` 를 사용중이라면 그나마 [pg-pool 라이브러리](https://jojoldu.tistory.com/634) 를 사용해볼 시도를 할 수 있다.

```ts
constructor(
	private readonly participationsService: ParticipationsService,
	private readonly articlesService: ArticlesService,
	private readonly dataSource: DataSource,
) {}

const driver: any = this.dataSource.driver; // TypeORM의 드라이버 접근
const pool = driver.pool; // MySQL2의 연결 풀 가져오기

console.log("MySQL2 Connection Pool:", {
	total: pool._allConnections.length, // 총 커넥션 수
	idle: pool._freeConnections.length, // 대기 중인 커넥션 수
	waitingClients: pool._connectionQueue.length, // 대기 중인 요청
});
```

- [TypeORM mysql connectionoptions](https://github.com/typeorm/typeorm/blob/master/src/driver/mysql/MysqlConnectionOptions.ts) 

- 결론이 나왔다~ 커넥션 누수는 없었다요~~~
- `Promise.all` 도 문제 없다
- *커넥션풀 개수랑 Vus랑 잘 조절 해야한다* 
- `multipleStatements` 를 이용하면 typeorm과 mysql과 promise.all로 병렬 실행 할 수 있지 않을까?
- https://github.com/typeorm/typeorm/issues/9905 
- Promise.all을 사용하면 부하가 많이 발생했을때 커넥션 부족 현상이 발생할 수 있다. 병렬 쿼리 개수 만큼 커넥션을 사용하기 때문이다.
- *Promise.all* 등과 같은 병렬 실행 함수들을 쿼리와 함께 쓰는것은 안티 패턴인것 같다.
- `Promise.all` 여러번 썼을때 커넥션풀 어떻게 생성 되는지 확인 필요.
# 공부 레퍼런스

- [히카리CP 최적화된 Pool Size를 구하는 공식](https://github.com/brettwooldridge/HikariCP/wiki/About-Pool-Sizing) 
- [풀 사이즈에 따른 TPS 연관성](https://keydo.tistory.com/26) 
- 네이버 커넥션풀
- 쉬운 코드 커넥션풀
- 기억보다 기록을 커넥션풀
- [기록보다 기억을 Promise.all과 커넥션풀로 병렬처리가 안된다](https://jojoldu.tistory.com/639) 
- [Promise.all을 사용하면 트랜잭션을 지원 안한다고?](https://www.answeroverflow.com/m/1177409434000031775) 
- Promise.all을 사용해도 DB수준에서 병렬이 아니라고?
- [우아한 기술 블로그](https://techblog.woowahan.com/2664/) 



