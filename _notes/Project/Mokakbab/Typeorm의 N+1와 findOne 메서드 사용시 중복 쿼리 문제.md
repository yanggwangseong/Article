---
title: Typeorm의 N+1와 findOne 메서드 사용시 중복 쿼리 문제
permalink: /project/mokakbab/trouble-shooting/3
tags:
  - Troubleshooting
  - mokakbab
  - nestjs
  - typeorm
  - post
layout: page
image: /assets/Mokakbab06.png
category: NestJS
---

![](/assets/Mokakbab06.png)

## Typeorm의 findOne 메서드 사용시 중복 쿼리 문제

- 🐙 **[모각밥 프로젝트(GitHub)](https://github.com/f-lab-edu/Mokakbab)** 
- 🔗 **[PR #79 이슈 링크](https://github.com/f-lab-edu/Mokakbab/pull/79)** 

---

### 📚 Contents

1. 개요
2. 문제
3. 문제 해결 및 결과

---

### 개요

- N+1 문제 
- Eager Loading
- Lazy Loading
- `relation` 옵션

**N+1문제란?**

어떤 테이블의 참조된 데이터를 가져오기 위해 해당 (테이블 조회(1) + 참조된 데이터 조회(N)) 회의 쿼리를 날리는 문제를 말합니다.

```ts
// author와 book은 OneToMany와 ManyToOne 관계
const authors = await Author.find();

for (const author of authors) {
	const authorName = author.name;
	const books = await Book.find({ author: author })
}
```

![](/assets/Mokakbab08.png)

처음 author를 전부 가져오는 쿼리(1) 와 각각의 author에 대한 books를 가저오는 쿼리(5) 해서 총 6번의 쿼리를 보내는 로그를 확인 할 수 있습니다.

`이러한 상황을 N+1 문제` 라고 합니다.

---

**이를 해결 하는 방법으로 TypeORM에서는 3가지 방법을 제공합니다**   

1. **Eager Loading**   

```ts
// eager 옵션을 true로 설정 
@OneToMany(() => Book, (book) => book.author, {
	eager: true,
})
books!: Book[];
```

TypeORM에서 `eager` 옵션을 `true` 로 설정하게 된다면 상위 엔티티를 로드 했을때, 그 하위 엔티티까지 모두 로드 할 수 있습니다.

즉, `Eager Loading` 이란 두개의 엔티티의 관계를 설정 해두었다면 상위 엔티티를 로드 할때 하위 엔티티를 함께 로드 해주는 방식입니다.

![](/assets/Mokakbab09.png)

**하지만 해당 방식은 하위 엔티티를 무조건 가져오기 때문에 하위 엔티티가 필요하지 않은 경우에도 무조건 가져오기 때문에 선호되지 않은 방식입니다**

2. **Lazy Loading**   

```ts
// TypeORM에서 Lazy Loading 사용
@OneToMany(() => Book, (book) => book.author)
books!: Promise<Book[]>
```

```ts
const authors = await Author.find();

console.log("--- books 접근 전 ---");
const books = await author.books;
console.log("--- books 접근 후 ---");

console.log(books);
```

![](/assets/Mokakbab10.png)

TypeORM은 `Lazy Loading` 을 `Promise` 기반으로 해당 Promise가 resolved 되었을때 관련 릴레이션을 호출하는 방식을 지원합니다.

즉, `Lazy Loading` 이란 필요할 때 디멘드 방식으로 하위 엔티티를 호출하는 Eager Loading을 개선한 방식입니다.

> Note: if you came from other languages (Java, PHP, etc.) and are used to use lazy relations everywhere - be careful. Those languages aren't asynchronous and lazy loading is achieved different way, that's why you don't work with promises there. In JavaScript and Node.JS you have to use promises if you want to have lazy-loaded relations. This is non-standard technique and considered experimental in TypeORM.

**하지만 해당 방식은 TypeORM공식문서에서는 해당 LazyLoading기능이 아직 실험적 기능이기 때문에 Java나 PHP등에서 사용하는것처럼 사용하면 안되고 주의가 필요하다고 말합니다** 

3. `relation` **옵션 사용**


```ts
// relation 옵션 사용
const authors = await Author.find({
	relations: {
		books: true,
	},
});
```

**`TypeORM` 에서는 `relation` 옵션을 통해서 `Join` 기능을 제공 합니다.** 

![](/assets/Mokakbab11.png)

### 후기

**개인적인 생각으로 relations 옵션을 통해서 기본적인 간단한 쿼리들을 처리하고 복잡한 쿼리 같은 경우에는 Raw Query 사용 및 쿼리빌더를 통해서 사용하는것이 좋은 방법인것 같습니다** 

---

### 문제

```ts
const foundMember = await this.membersRepository.findOne({
	...
	...
	...
	where: {
		id: memberId,
	},
	relations: {
		refreshToken: true,
	},
});
```

`member` 테이블과 `refreshToken` 테이블과 `relations` 옵션을 통해서 `findOne` 메서드를 사용 했을때 쿼리 로그를 보면 쿼리를 2개를 요청하는것을 알 수 있었다.

```ts
SELECT DISTINCT `distinctAlias`.`memberentity_id` AS `ids_MemberEntity_id`  
FROM   (SELECT `MemberEntity`.`id`                               AS  
               `MemberEntity_id`,  
               `MemberEntity`.`email`                            AS  
                      `MemberEntity_email`,  
               `MemberEntity__MemberEntity_refreshToken`.`id`    AS  
               `MemberEntity__MemberEntity_refreshToken_id`,  
               `MemberEntity__MemberEntity_refreshToken`.`token` AS  
               `MemberEntity__MemberEntity_refreshToken_token`  
        FROM   `member` `MemberEntity`  
               LEFT JOIN `refresh_token`  
                         `MemberEntity__MemberEntity_refreshToken`  
                      ON `MemberEntity__MemberEntity_refreshToken`.`id` =  
                         `MemberEntity`.`refreshtokenid`  
        WHERE  (( `MemberEntity`.`email` = ? ))) `distinctAlias`  
ORDER  BY `memberentity_id` ASC  
LIMIT  1

SELECT `MemberEntity`.`id`                               AS `MemberEntity_id`,  
       `MemberEntity`.`email`                            AS `MemberEntity_email`  
       ,  
       `MemberEntity__MemberEntity_refreshToken`.`id`    AS  
       `MemberEntity__MemberEntity_refreshToken_id`,  
       `MemberEntity__MemberEntity_refreshToken`.`token` AS  
       `MemberEntity__MemberEntity_refreshToken_token`  
FROM   `member` `MemberEntity`  
       LEFT JOIN `refresh_token` `MemberEntity__MemberEntity_refreshToken`  
              ON `MemberEntity__MemberEntity_refreshToken`.`id` =  
                 `MemberEntity`.`refreshtokenid`  
WHERE  ((( `MemberEntity`.`email` = ? )))  
       AND ( `MemberEntity`.`id` IN ( 1 ) )
```

`TypeORM` 에서 `findOne` 메서드와 `relation` 옵션 사용시에 2개의 중복 쿼리가 발생 하였습니다.

**[TypeORM findOne 관련 오픈된 이슈](https://github.com/typeorm/typeorm/issues/5694)** 

하지만 `TypeORM` 에서는 현재 **OnetoOne** 관계에서 `relation` 옵션을 사용하면 `findOne` 과 `findOne` 과 비슷한 메서드에서 2개의 쿼리를 날리는 문제가 있고 현재 아직까지 수정 되지 않았습니다.

#### 왜 2개의 쿼리를 사용할까?

TypeORM이슈들에서 말하는 가장 큰 이유는 `findOne` 을 통한 릴레이션 쿼리에서 그룹핑 작업을 위한 중복 데이터를 검증하기 위한 일종의 안전 장치라고 얘기하고 있습니다.

**하지만 최소한 OnetoOne 관계에서의 relations 옵션** 을 사용 했을때는 중복문제가 없기 때문에 2개의 쿼리를 날리는 불필요한 중복 쿼리는 제거 되어야 합니다. 이는 이슈에서도 언급 되듯이 아직까지 `TypeORM` 에서 최적화 되어 있지 않은 부분인것 같습니다.

---

### 문제 해결 및 결과

1. **쿼리 빌더 사용** 

```ts
findMemberWithRefreshTokenByEmail(email: string) {
	return this.repository
		.createQueryBuilder("member")
		.leftJoinAndSelect("member.refreshToken", "refreshToken")
		.select(["member.id", "member.email", "refreshToken.token"])
		.where("member.email = :email", { email })
		.getOne();
}
```

---

## Reference

- **[TypeORM findOne 관련 오픈된 이슈](https://github.com/typeorm/typeorm/issues/5694)** 
- [TypeORM eager-and-lazy-relations](https://typeorm.io/eager-and-lazy-relations) 
