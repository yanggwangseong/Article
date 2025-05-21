---
title: TypeORM과 mysql 사용시 Insert 최적화
permalink: /project/mokakbab/trouble-shooting/4
tags:
  - Troubleshooting
  - mokakbab
  - nestjs
  - typeorm
  - post
layout: page
image: /assets/Mokakbab06.png
category: NestJS
description: TypeORM에서 MySQL 사용 시, save 및 insert 메서드를 통한 다량의 데이터 삽입 과정에서 불필요한 SELECT 쿼리가 자동 실행되어 성능 병목이 발생했습니다. 특히 AutoIncrement 방식의 기본 키 값을 가져오기 위한 SELECT가 문제였고, QueryBuilder의 updateEntity(false) 옵션과 함께 insert 쿼리를 사용해 SELECT 생략이 가능했으나, 필요한 필드만 조회하는 별도 로직이 필요했습니다. 최종적으로 insertId를 통해 id만 추출하는 방식으로 SELECT 비용을 줄이면서도 필요한 데이터를 안전하게 처리할 수 있었습니다.
---

![](/assets/Mokakbab06.png)

## TypeORM과 mysql 사용시 Insert 최적화

- 🐙 **[모각밥 프로젝트(GitHub)](https://github.com/f-lab-edu/Mokakbab)** 
- 🔗 **[PR #79 이슈 링크](https://github.com/f-lab-edu/Mokakbab/pull/79)** 

---

### 📚 Contents

1. 개요
2. 문제
3. 문제 해결 및 결과

---

### 개요

`TypeORM` 에서 `insert` 쿼리를 실행하기 위해서 제공하는 메서드들은 다음과 같습니다.

- `save` 메서드
- `insert 메서드` 
- `쿼리빌더를 통한 insert()` 
- `query 메서드를 통한 직접 Raw 쿼리를 작성` 

**query 메서드를 사용하여 INSERT하게 되면 affectedRows만 반환하기 때문에 선택지에서 제외 시켰습니다** 

### 1. `save` 메서드

```ts
const rows = [
	User.create({ name: '홍길동' }),
	User.create({ name: '박민수' })
];

await User.save(rows)

INSERT INTO user(id, name) VALUES (DEFAULT, '홍길동')
SELECT User.id AS User_id, User.name AS User_name FROM user User WHERE User.id = 101
INSERT INTO user(id, name) VALUES (DEFAULT, '박민수')
SELECT User.id AS User_id, User.name AS User_name FROM user User WHERE User.id = 102

// save option
export interface SaveOptions {
		...
    transaction?: boolean;  // TRANSACTION을 하지 않을 수 있습니다.
    chunk?: number;      // 데이터가 배열일때, chunk 개수를 설정할 수 있습니다.
    reload?: boolean;    // Entity를 Reload 합니다.
}
```

`save` 메서드는 단일 생성은 괜찮으나 여러 데이터를 생성할 때 매번 `INSERT INTO` 를 반복하게 되는 부분이 발생 합니다.

Insert후 Select시에 **reload** 옵션을 통해서 생성된 데이터를 가져올 수 있으나 **모든 필드를 다 가져오게** 됩니다.

모든 필드를 다 가져오지 않는 방법은 쿼리내에서는 방법이 따로 없습니다.

### 2. `insert` 메서드

```ts
await User.insert(rows)
INSERT INTO user(id, name) VALUES (DEFAULT, '홍길동'), (DEFAULT, '박민수')
SELECT User.id AS User_id, User.name AS User_name FROM user User WHERE User.id = 111
```

`insert` 메서드를 사용하면 VALUES값을 한번에 모아서 INSERT를 실행 할 수 있습니다.

하지만 **응답값(InsertResult.generatedMaps)** 을 채우기 위해 SELECT를 하고 있습니다

이는 `TypeORM` 의 내부적인 동작으로 이를 막을 방법은 현재 없습니다.

### 3.  QueryBuilder 

```ts
await User.createQueryBuilder()
          .insert()
          .values(rows)
          .updateEntity(false)
          .execute()
          
INSERT INTO user(id, name) VALUES (DEFAULT, '홍길동'), (DEFAULT, '박민수')
```

`QueryBuilder` 를 사용하여 `updateEntity(false)` 설정을 하게 되면 SELECT하지 않을 수 있습니다.

하지만 현재 프로젝트에서 `AutoIncrement` 로 동작하는 `Primary Key` 를 `INSERT` 후에 `id` 값을 가져와야 하는 상황에서는 문제가 발생합니다. 

---

### 문제

1. TypeORM에서 `INSERT` 후 `SELECT` 쿼리 발생
2. `AutoIncrement` 로 동작하는 `Primary Key` 를 `INSERT` 후에 `id` 값을 가져와야 하는 상황

---

### 문제 해결 및 결과

1. `RETURNING` 사용

```ts
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

쿼리빌더 사용시 `returning` 을 통해서 필드를 지정해서 가져올 수 있게 제공 합니다.

`Exception: OUTPUT or RETURNING clause only supported by Microsoft SQL Server or PostgreSQL or MariaDB databases.`

하지만 TypeORM의 공식문서에서 `mysql` 에서는 지원하지 않습니다.

2. `InsertResult` 에서 `id` 값을 가져와서 필요한 필드만 쿼리

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
```

**즉, TypeORM에서 mysql을 사용시에 필요한 필드를 다시 가져오는 쿼리를 보내는 방법밖에 없습니다** 

다만, TypeORM에서 `reload` 옵션을 사용하게 되면 모든 필드를 가져오기 때문에 필요한 필드만 가져오고 싶다면 해당 방법이 더 좋은 방법 입니다.

#### 어떻게 Primary Key인 id값을 가져 올 수 있을까?

mysql driver가 mysql과 통신할때, 응답패킷에 **last-insert-id** 를 넘겨 주게 됩니다. 이를 통해서 `InsertResult` 에 id값을 알 수 있게 됩니다.


### 후기

`QueryBuilder` 를 통해서 `Insert` 를 실행 하고 `updateEntity(false)` 옵션을 주고 데이터를 저장하는 `INSERT` 를 실행하는 방법이 가장 효율적인것 같습니다.

