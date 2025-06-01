---
title: recoverability
permalink: /database/recoverability
tags: 
layout: note
image: /assets/812.jpg
category: Database
description: recoverability
---

![](/assets/812.jpg)

## 1. recoverability

**recoverability란?**

**Recoverability** 이란, 트랜잭션 실행 중 장애가 발생했을 때 **데이터의 일관성을 유지하며 복구할 수 있는 특성**을 의미합니다.

- 🐙 **[해당 본문 코드(GitHub)](https://github.com/yanggwangseong/implementation/tree/main/concurrency-control)** 

>  K가 H에게 20만원을 이체할때 H도 본인 계좌에 30만원을 입금한다면 여러 형태의 실행이 가능할 수 있다.

---

### 1.1 CASE1

![](/assets/recoverability01.png)

- **CASE1** : r1(K) w1(K) r2(H) w2(H) r1(H) w1(H) c1 a2(rollback)

트랜잭션2에서 rollback 하는 상황

- abort : rollback(H_balance = 200만원)
- tx2는 더이상 유효하지 않으므로 tx2가 write 했던 H_balance를 읽은 tx1도 rollback 해야한다.

**tx2 write(H_balance = 230만원)** 했기 때문에 **tx1 read(H_balance) => 230만원** 도 함께 **rollback** 해줘야 한다.

하지만 tx1은 이미 commit된 상태이므로 **durability** 속성 때문에 rollback 할 수 없다. 이러한 schedule을 **unrecoverable schedule** 이라고 한다.

#### 1.1.1 unrecoverable schedule

**schedule 내에서 commit된 transaction이 rollback된 transaction이 write 했었던 데이터를 읽은 경우** 

**rollback을 해도 이전 상태로 회복 불가능할 수 있기 때문에 이런 schedule은 DBMS가 허용하면 안된다** 

---

## 2. recoverable schedule

### 2.1 CASE2

![](/assets/recoverability02.png)

- **CASE2** : r1(K) w1(K) r2(H) w2(H) r1(H) w1(H) c2 c1

#### 2.1.1 recoverable schedule

- **schedule 내에서 그 어떤 transaction도 자신이 읽은 데이터를 write한 transaction이 먼저 commit/rollback 전까지는 commit 하지 않는 경우** 이를 **recoverable schedule** 이라고 한다.
- rollback 할 때 이전 상태로 온전히 돌아갈 수 있기 때문에 DBMS는 이런 schedule만 허용해야 한다.

#### 2.1.2 cascading rollback

**정의 : 하나의 transaction이 rollback하면 의존성이 있는 다른 transaction도 rollback 해야한다** 

**단점 : 여러 transaction의 rollback이 연쇄적으로 일어나면 처리하는 비용이 많이 든다** 

#### 2.1.3 cascadeless schedule

- cascading rollback의 단점을 어떻게 해결할까?
	- **데이터를 write한 transaction이 commit/rollback 한 뒤에 데이터를 읽는 schedule만 허용하자!**

**정의 : schedule내에서 어떤(any) transaction도 commit 되지 않은 transaction들이 write한 데이터는 읽지 않는 경우** 

- 종종 avoid cascading rollback이라고 부르기도 한다.

---

## 3. strict schedule

**정의: schedule내에서 어떤(any) transaction도 commit 되지 않은 transaction들이 write한 데이터는 `쓰지도,` 읽지 않는 경우**

### 3.1 CASE3

상황 (pizza schedule)

> H사장님이 3만원이던 피자가격을 2만원으로 낮추려는데 K직원도 동일한 피자의 가격을 실수로 1만원으로 낮추려 했을때 이런 schedule도 생길 수 있습니다.

![](/assets/recoverability03.png)

- **CASE3** : w1(pizza) w2(pizza) c2 a1(rollback)

**pizza schedule** 은 **cascadeless schedule** 이다. 하지만 **strict schedule은 아니다** 

cascadeless schedule의 정의는 **schedule내에서 어떤(any) transaction도 commit 되지 않은 transaction들이 write한 데이터는 읽지 않는 경우** 이것인데 해당 조건을 만족하지만 **현재 tx2 트랜잭션2 결과가 사라졌다!**

이를 해결 하기위해서 하나의 조건이 더 추가 되면 해결 할 수 있다.

**schedule내에서 어떤(any) transaction도 commit 되지 않은 transaction들이 write한 데이터는 `쓰지도,` 읽지 않는 경우**

이러한 Schedule을 **strict schedule** 이라고 한다.

### 3.2 CASE4

**cascadeless schedule** 이면서 **strict schedule** 

![](/assets/recoverability04.png)

- **CASE3** : w1(pizza) c1 or a1 w2(pizza) c2

- cascadeless schedule
	- **schedule내에서 어떤(any) transaction도 commit 되지 않은 transaction들이 write한 데이터는 읽지 않는 경우**
- strict schedule
	**schedule내에서 어떤(any) transaction도 commit 되지 않은 transaction들이 write한 데이터는 `쓰지도,` 읽지 않는 경우**

#### 3.3 strict schedule 장점

- rollback 할 때 recovery가 쉽다.
- transaction 이전 상태로 돌려 놓기만 하면 된다.



---


- **Isolation** : 동시성 제어를 위한 트랜잭션 속성
- concurrency control providers **serializability & recoverability** 

**concurrency control(동시성 제어) 는 serializability와 recoverability** 를 제공한다(provider)

이것과 관련된 트랜잭션 속성이 **Isolation** 이다.

---

## Reference

- [쉬운코드 concurrency control 2](https://www.youtube.com/watch?v=89TZbhmo8zk) 
