---
title: mokakbab-issue
permalink: /wating/마이그레이션
---


```
query: SELECT 1 AS `row_exists` FROM (SELECT 1 AS dummy_column) `dummy_table` WHERE EXISTS (SELECT 1 FROM `member` `MemberEntity` WHERE ((`MemberEntity`.`email` = ?))) LIMIT 1 -- PARAMETERS: ["test12345@test.com"]
query: START TRANSACTION
query: INSERT INTO `verification_code`(`id`, `code`, `createdAt`, `updatedAt`) VALUES (DEFAULT, ?, DEFAULT, DEFAULT) -- PARAMETERS: ["17314E"]
query: SELECT `VerificationCodeEntity`.`id` AS `VerificationCodeEntity_id`, `VerificationCodeEntity`.`createdAt` AS `VerificationCodeEntity_createdAt`, `VerificationCodeEntity`.`updatedAt` AS `VerificationCodeEntity_updatedAt` FROM `verification_code` `VerificationCodeEntity` WHERE `VerificationCodeEntity`.`id` = ? -- PARAMETERS: [121015]
query: COMMIT
query: START TRANSACTION
query: INSERT INTO `member`(`id`, `name`, `nickname`, `password`, `email`, `profileImage`, `isEmailVerified`, `createdAt`, `updatedAt`, `refreshTokenId`, `verificationCodeId`) VALUES (DEFAULT, ?, ?, ?, ?, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, ?) -- PARAMETERS: ["sisi","nunu","$2b$10$9VrIGytz0SU9ccElxvSNE.GSqiHbiobnM5OclaJDB0G2er9g7I3pC","test12345@test.com",121015]
query: SELECT `MemberEntity`.`id` AS `MemberEntity_id`, `MemberEntity`.`isEmailVerified` AS `MemberEntity_isEmailVerified`, `MemberEntity`.`createdAt` AS `MemberEntity_createdAt`, `MemberEntity`.`updatedAt` AS `MemberEntity_updatedAt` FROM `member` `MemberEntity` WHERE `MemberEntity`.`id` = ? -- PARAMETERS: [121013]
query: COMMIT
query: SELECT DISTINCT `distinctAlias`.`MemberEntity_id` AS `ids_MemberEntity_id` FROM (SELECT `MemberEntity`.`id` AS `MemberEntity_id`, `MemberEntity`.`name` AS `MemberEntity_name`, `MemberEntity`.`nickname` AS `MemberEntity_nickname`, `MemberEntity`.`password` AS `MemberEntity_password`, `MemberEntity`.`email` AS `MemberEntity_email`, `MemberEntity`.`profileImage` AS `MemberEntity_profileImage`, `MemberEntity`.`isEmailVerified` AS `MemberEntity_isEmailVerified`, `MemberEntity`.`createdAt` AS `MemberEntity_createdAt`, `MemberEntity`.`updatedAt` AS `MemberEntity_updatedAt`, `MemberEntity`.`refreshTokenId` AS `MemberEntity_refreshTokenId`, `MemberEntity`.`verificationCodeId` AS `MemberEntity_verificationCodeId`, `MemberEntity__MemberEntity_refreshToken`.`id` AS `MemberEntity__MemberEntity_refreshToken_id`, `MemberEntity__MemberEntity_refreshToken`.`token` AS `MemberEntity__MemberEntity_refreshToken_token`, `MemberEntity__MemberEntity_refreshToken`.`createdAt` AS `MemberEntity__MemberEntity_refreshToken_createdAt`, `MemberEntity__MemberEntity_refreshToken`.`updatedAt` AS `MemberEntity__MemberEntity_refreshToken_updatedAt` FROM `member` `MemberEntity` LEFT JOIN `refresh_token` `MemberEntity__MemberEntity_refreshToken` ON `MemberEntity__MemberEntity_refreshToken`.`id`=`MemberEntity`.`refreshTokenId` WHERE ((`MemberEntity`.`id` = ?))) `distinctAlias` ORDER BY `MemberEntity_id` ASC LIMIT 1 -- PARAMETERS: [121013]
query: SELECT `MemberEntity`.`id` AS `MemberEntity_id`, `MemberEntity`.`name` AS `MemberEntity_name`, `MemberEntity`.`nickname` AS `MemberEntity_nickname`, `MemberEntity`.`password` AS `MemberEntity_password`, `MemberEntity`.`email` AS `MemberEntity_email`, `MemberEntity`.`profileImage` AS `MemberEntity_profileImage`, `MemberEntity`.`isEmailVerified` AS `MemberEntity_isEmailVerified`, `MemberEntity`.`createdAt` AS `MemberEntity_createdAt`, `MemberEntity`.`updatedAt` AS `MemberEntity_updatedAt`, `MemberEntity`.`refreshTokenId` AS `MemberEntity_refreshTokenId`, `MemberEntity`.`verificationCodeId` AS `MemberEntity_verificationCodeId`, `MemberEntity__MemberEntity_refreshToken`.`id` AS `MemberEntity__MemberEntity_refreshToken_id`, `MemberEntity__MemberEntity_refreshToken`.`token` AS `MemberEntity__MemberEntity_refreshToken_token`, `MemberEntity__MemberEntity_refreshToken`.`createdAt` AS `MemberEntity__MemberEntity_refreshToken_createdAt`, `MemberEntity__MemberEntity_refreshToken`.`updatedAt` AS `MemberEntity__MemberEntity_refreshToken_updatedAt` FROM `member` `MemberEntity` LEFT JOIN `refresh_token` `MemberEntity__MemberEntity_refreshToken` ON `MemberEntity__MemberEntity_refreshToken`.`id`=`MemberEntity`.`refreshTokenId` WHERE ( ((`MemberEntity`.`id` = ?)) ) AND ( `MemberEntity`.`id` IN (121013) ) -- PARAMETERS: [121013]
query: START TRANSACTION
query: INSERT INTO `refresh_token`(`id`, `token`, `createdAt`, `updatedAt`) VALUES (DEFAULT, ?, DEFAULT, DEFAULT) -- PARAMETERS: ["$2b$10$U9PJ6BIQRLj.HCHDp7d8u.6PNc7KRrRrj9begrNuKxC.zwHCKkG5G"]
query: SELECT `RefreshTokenEntity`.`id` AS `RefreshTokenEntity_id`, `RefreshTokenEntity`.`createdAt` AS `RefreshTokenEntity_createdAt`, `RefreshTokenEntity`.`updatedAt` AS `RefreshTokenEntity_updatedAt` FROM `refresh_token` `RefreshTokenEntity` WHERE `RefreshTokenEntity`.`id` = ? -- PARAMETERS: [120533]
query: COMMIT
query: UPDATE `member` SET `refreshTokenId` = ?, `updatedAt` = CURRENT_TIMESTAMP WHERE `id` = ? -- PARAMETERS: [120533,121013]
```


# TypeORM 이슈

- `save` 메서드 사용 금지
- `insert` 메서드 사용금지


- [직방 타입오알엠](https://medium.com/zigbang/typeorm-%EC%82%AC%EC%9A%A9%EC%82%AC%EB%A1%80-3%EA%B0%80%EC%A7%80-6a3c2bcd6cff) 
- 리터닝으로 해결이 안된다.
- `Exception: OUTPUT or RETURNING clause only supported by Microsoft SQL Server or PostgreSQL or MariaDB databases.` 

```
saveVerificationCode(code: string) {
        return this.repository
            .createQueryBuilder()
            .insert()
            .into(VerificationCodeEntity)
            .values({ code })
            .returning("id")
            .execute();
    }
```

- Mysql에서 *리터닝이 안되네* 사용불가 지원 안함.

```
 saveVerificationCode(code: string) {
        return this.repository
            .createQueryBuilder()
            .insert()
            .into(VerificationCodeEntity)
            .updateEntity(false)
            .values({ code })
            .execute();
    }
```

- 현재로써 `.updateEntity(false)` 넣어 주지 않으면 insert 할때 무조건 전체 select 다시함.

- [MySQL 드라이버 Insert후 리턴 코드 위치](https://github.com/typeorm/typeorm/blob/9d1d3f1008e9c1f3488fc223a7853605df7f00dc/src/driver/mysql/MysqlDriver.ts#L945) 
- [쿼리빌더 insert 리터닝 코드 위치](https://github.com/typeorm/typeorm/blob/9d1d3f1008e9c1f3488fc223a7853605df7f00dc/src/query-builder/ReturningResultsEntityUpdator.ts#L137) 
- [insert 쿼리빌더 생성시 발생하는 작업](https://github.com/typeorm/typeorm/blob/9d1d3f1008e9c1f3488fc223a7853605df7f00dc/src/query-builder/InsertQueryBuilder.ts#L407) 
- 이래서 `id` 값을 정하는게 매우 중요 한거군요
- 어떻게 시퀄스한 값을 이용할지 진짜 어렵군요.
- `매우매우 개뻘짓했다` 오픈 소스를 여러방면으로 까보는 경험이 되긴 했다.
- 결론부터 말하면 리터닝 부분을 구할 필요가 없다.
- 그래도 오픈소스를 까보면서 어떻게 `insert` 를 하고 난 이후에 바로 해당 아이디 값으로 `select` 를 날릴 수 있는것인가? 라는 의문점에서 시작하여서 분명히 그 `insert` 후의 아이디 값을 가지고 있을것 같았다.

```
return this.repository
	.createQueryBuilder()
	.insert()
	.into(VerificationCodeEntity)
	.updateEntity(false)
	.values({ code })
	.execute();
```

- `.updateEntity(false)` 이게 가장 중요한 옵션이고 `insert` 후에 다시 select 하지 않는다.
- 그런 상태에서 insert만 실행되고 위의 오픈소스에서 본것처럼 내부적으로 `insertID` 를 가지고 있게 구현 된다.

```
// 이전 쿼리
$ INSERT INTO `verification_code`(`id`, `code`, `createdAt`, `updatedAt`) VALUES (DEFAULT, ?, DEFAULT, DEFAULT) -- PARAMETERS: ["3F8146"]
$ SELECT `VerificationCodeEntity`.`id` AS `VerificationCodeEntity_id`, `VerificationCodeEntity`.`createdAt` AS `VerificationCodeEntity_createdAt`, `VerificationCodeEntity`.`updatedAt` AS `VerificationCodeEntity_updatedAt` FROM `verification_code` `VerificationCodeEntity` WHERE `VerificationCodeEntity`.`id` = ? -- PARAMETERS: [121049]

// 개선된 쿼리
query: START TRANSACTION
query: INSERT INTO `verification_code`(`id`, `code`, `createdAt`, `updatedAt`) VALUES (DEFAULT, ?, DEFAULT, DEFAULT) -- PARAMETERS: ["23438E"]
query: COMMIT
```


- 최종 코드
- 핵심은 `insert` 만 실행 시킨후 생성된 AI pk 값을 반환한다.

```ts
async saveVerificationCode(code: string) {
	const insertResult = await this.repository
		.createQueryBuilder()
		.insert()
		.into(VerificationCodeEntity)
		.updateEntity(false)
		.values({ code })
		.useTransaction(true)
		.execute();

	return insertResult.raw.insertId;
}

// 트랜잭션을 적용하고자 한다면 useTransaction 넣어주면 된다.
```

