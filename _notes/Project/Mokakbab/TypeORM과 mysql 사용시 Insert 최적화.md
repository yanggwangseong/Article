---
title: TypeORM과 mysql 사용시 Insert 최적화
permalink: /project/mokakbab/trouble-shooting/4
tags:
  - Troubleshooting
  - mokakbab
  - nestjs
  - typeorm
layout: page
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

`TypeORM` 에서 

`TypeORM` 에서 `insert` 쿼리를 실행하기 위해서 제공하는 메서드들은 다음과 같습니다.

- `save` 메서드
- `insert 메서드` 
- `쿼리빌더를 통한 insert()` 
- `query 메서드를 통한 직접 Raw 쿼리를 작성` 

**query 메서드를 사용하여 INSERT하게 되면 affectedRows만 반환하기 때문에 선택지에서 제외 시켰습니다** 

---

### 문제

1. TypeORM에서 `Insert` 쿼리를 실행한 후 생성된 데이터값을 알기 위해서 `SELECT` 쿼리 발생
2. `mysql` 사용시 해당 `SELECT` 쿼리시에 `Returning` 문법을 지원하지 않기 때문에 모든 필드를 가져오는 문제


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

다만, TypeORM에서 load 할 수 있는 옵션을 사용하게 되면 모든 필드들을 가져오기 때문에 필요한 필드만 가져오고 싶다면 해당 방법이 더 좋은 방법 입니다.

[[TypeORM에서 insert 최적화]]

