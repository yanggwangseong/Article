
### **1. N+1 문제란?**

- **N+1 문제**는 한 번의 주요 쿼리(N=1)를 실행한 뒤, 관련 데이터를 가져오기 위해 추가로 N개의 쿼리가 발생하는 문제입니다.
- 관계형 데이터베이스에서 데이터 관계를 조회할 때 **연관된 데이터**를 가져오기 위해 반복적으로 쿼리를 실행할 경우 발생합니다.

### **2. Lazy Loading (지연 로딩)**

- **Lazy Loading**은 관계형 데이터를 조회할 때 **필요할 때만** 연관 데이터를 가져오는 방식입니다.
- N+1 문제를 발생할 가능성이 높다.


### **3. Eager Loading (즉시 로딩)**

- **Eager Loading**은 데이터를 조회할 때 **연관된 데이터를 한 번에** 가져오는 방식입니다.
- 모든 데이터를 한 번의 쿼리로 가져옵니다.
- **N+1 문제 방지**: 연관 데이터를 한꺼번에 로딩하므로 추가 쿼리를 실행하지 않습니다.
- **사용시에는 조건 WHERE절을 잘 추가해줘야 한다** 

### **4. 언제 Lazy Loading과 Eager Loading을 선택해야 하나요?**

- **Lazy Loading**:
    - 연관된 데이터가 반드시 필요하지 않은 경우.
    - 데이터 크기가 크고, 필요할 때만 로딩이 적합한 경우.
- **Eager Loading**:
    - 연관된 데이터가 항상 필요하고, **N+1 문제가 예상될 경우**.
    - 데이터 크기가 적고, 쿼리를 최소화하고 싶을 때.

# TypeORM에서 N+1

- 디펄트는 Lazy Loading으로 설정 된다.
- `relations` 프로퍼티를 통해서 관계 설정을 하게 되면 Eager Loading으로 조회 해준다.
- 그래서 일반적으로는 join 쿼리를 통해서 가져와주기 때문에 N+1 문제가 발생 하지 않는다.

```ts
// oneToMany ManyToOne 관계
this.membersRepository.find({
	relations: {
		articles: true,
	},
	where: {
		id: 1,
	},
});
```

```sql
SELECT `MemberEntity`.`id`                        AS `MemberEntity_id`,
       `MemberEntity__MemberEntity_articles`.`id` AS
       `MemberEntity__MemberEntity_articles_id`
FROM   `member` `MemberEntity`
       LEFT JOIN `articles` `MemberEntity__MemberEntity_articles`
              ON
`MemberEntity__MemberEntity_articles`.`memberid` = `MemberEntity`.`id`
WHERE  (( `MemberEntity`.`id` = ? )) 
```


## TypeORM findOne 메서드 치명적 문제

- [2024-12-27일 기준 findOne은 2개의 쿼리를 수행](https://github.com/typeorm/typeorm/issues/5694) 
- 왜 `OneToOne` 에서 고정쿼리로 2개를 던지는걸까?

```sql
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


> Note: if you came from other languages (Java, PHP, etc.) and are used to use lazy relations everywhere - be careful. Those languages aren't asynchronous and lazy loading is achieved different way, that's why you don't work with promises there. In JavaScript and Node.JS you have to use promises if you want to have lazy-loaded relations. This is non-standard technique and considered experimental in TypeORM.

- TypeORM에서 LazyLoading은 실험적 기능이군.