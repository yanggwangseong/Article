---
title: Typeorm의 findOne 메서드 사용시 중복 쿼리 문제
permalink: /project/mokakbab/trouble-shooting/3
tags:
  - Troubleshooting
  - mokakbab
  - nestjs
  - typeorm
layout: page
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

TypeORM 과 findOne메서드 예시 코드
쿼리 로그 기록

`TypeORM` 에서 `findOne` 메서드와 `relation` 옵션 사용시에 2개의 중복쿼리가 발생 하였습니다.

#### 왜 TypeORM에서 쿼리를 2개씩 날리는걸까?


---

### 문제

**[TypeORM findOne 관련 오픈된 이슈](https://github.com/typeorm/typeorm/issues/5694)** 

**중복 데이터를 위해서 2개의 쿼리를 보내는 방식으로 구현되어 있는것은 이해가 되었으나 사실 One to One 릴레이션 관계에서는 필요 없는 기능입니다** 

하지만 `TypeORM` 에서는 현재 **OnetoOne** 관계에서 불필요한 중복쿼리를 날리는 문제에 대해서 아직 해결되지 않았고 해당 이슈는 아직 오픈 되어 있는 상태입니다.

---

### 문제 해결 및 결과

- 📘 **노션 결과 리포트**: [노션 결과 리포트 링크](노션 결과 링크)
- 🔗 **PR #123 이슈**: [해당 PR#123 이슈 링크](해당 Pr 이슈 링크)

