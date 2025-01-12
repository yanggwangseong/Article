---
title: mokakbab-issue
permalink: /wating/find-one
---

```ts
const foundMember = await this.membersRepository.findOneOrFail({
	where: {
		id: memberId,
	},
	relations: {
		refreshToken: true,
	},
});
```

- 흔하디 흔한 코드인데 `TypeORM` 에서 `one to one` 관계이더라도 중복 확인이 필요 없어도 중복을 체크 하기 위한 쿼리를 날려서 총 쿼리를 2번 무조건 날리게 된다.

