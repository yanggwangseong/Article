---
title: Isolation-level
permalink: /study/2
tags: 
layout: note
image: /assets/cat01.png
---
![](/assets/812.jpg)

## Isolation level

**Isolation level이란?** 

일부 이상한 현상은 허용하는 몇가지 level을 만들어서 사용자가 필요에 따라서 적절하게 선택할 수 있도록 하는 방법

---

## 1. Isolation level

### 1.1 Isolation level이 왜 필요할까?

- Dirty read
- Non-repeatable read
- Phantom read

이런 이상한 현상들이 모두 발생하지 않게 만들 수 있으나

제약사항이 많아져서 동시 처리 가능한 트랜잭션 수가 줄어들어

결국 DB의 전체 처리량(throughput)이 하락하게 된다.

### 1.2 Isolation level 종류와 이상현상

![](/assets/isolation-level01.png)

- **READ UNCOMMITTED** : 커밋되지 않은 데이터를 읽을 수 있어 Dirty Read 발생 가능
- **READ COMMITTED**: 커밋된 데이터만 읽음 → Non-Repeatable Read 발생 가능
- **REPEATABLE READ**: 같은 트랜잭션 내에서는 같은 데이터를 읽음 → Phantom Read 가능
- **SERIALIZABLE**: 트랜잭션을 직렬화하여 완전한 고립 → 가장 안전하지만 성능 저하
- **Dirty Read**: 다른 트랜잭션에서 아직 커밋되지 않은 데이터를 읽음
- **Non-Repeatable Read**: 동일 쿼리를 두 번 실행했을 때 결과가 달라짐
- **Phantom Read**: 조건은 같지만 범위에 포함되는 레코드 수가 달라짐 (INSERT/DELETE)

### 1.3 3가지외 이상현상

- **Dirty write** : commit 안된 데이터를 write함.
	- rollback 시 정상적인 recovery는 매우 중요해서 모든 isolation level에서 dirty write를 허용하면 안된다.
- **Lost update**
- **Dirty read(다른 케이스)** 
	- abort가 발생하지 않아도 **dirty read** 가 될 수 있다.
- **Read skew** 
	- inconsistent(불일치)한 데이터 읽기
- **Write skew**
	- inconsistent(불일치)한 데이터 쓰기
- **Phantom Read(다른 케이스)** 
	- 꼭 같은 조건을 2번 읽는 경우가 아닐지라도 서로 연관된 데이터가 있는 경우에는 중간에 데이터가 추가나 삭제가 되었을때 이상한 현상이 발생할 수 있다.

---

## 2. SNAPSHOT ISOLATION

concurrency control이 어떻게 동작할지 그 구현을 바탕으로 정리된 Isolation level

어떻게 concurrency control을 구현을 할것인가에 기반해서 레벨이 정의가 되었다.

SNAPSHOT ISOLATION에서 write write conflict가 발생 했을때 먼저 commit된 트랜잭션만 인정을 해준다. 뒤의 write 하려는 트랜잭션은 abort로 처리된다.

**사실 이러한 방식은 MVCC의 한 종류다 (type of MVCC)**

- tx 시작 전에 commit된 데이터만 보임
- First-comitter win

---

## 3. 실무에서 isolation level

### 3.1 MySQL (InnoDB)

![](/assets/isolation-level02.png)

표준에서 정의한 Isolation level을 그대로 사용한다.

### 3.2 Oracle

![](/assets/isolation-level03.png)

오라클에서는 REPEATABLE READ와 SERIALIZABLE 둘다 SERIALIZABLE로 사용하라고 권고 하고 있습니다.

즉, 오라클에서 실제 사용하는것은 READ UNCOMMITTED와 READ COMMITTED 2가지인걸 알 수 있습니다.

실제로 오라클의 SERIALIZABLE은 **SNAPSHOT ISOLATION LEVEL** 로 동작한다.

### 3.3 SQL Server

![](/assets/isolation-level04.png)

SQL Server도 표준 Isolation Level을 따른다.

### 3.4 Postgresql

![](/assets/isolation-level05.png)

- Postgresql은 기본은 표준 Isolation Level을 따른다.
- 이상 현상중 Serialization Annomaly를 따로 다룬다.
- **Postgresql에서는 REPEATABLE READ가 SNAPSHOT ISOLATION LEVEL** 로 동작한다.


---

## Reference

- 10x 개발자 트랜잭션 격리수준 - https://www.youtube.com/watch?v=sDSU8KrOcxc
- 쉬운코드 Isolation level https://www.youtube.com/watch?v=bLLarZTrebU
- Isolation level https://code-run.tistory.com/72
