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
