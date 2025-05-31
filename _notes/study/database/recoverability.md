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

![[Pasted image 20250530232646.png]]

- **CASE1** : r1(K) w1(K) r2(H) w2(H) r1(H) w1(H) c2 c1

## cascadeless schedule

## strict schedule


unrecoverable schedule

DBMS에서 허용을 하면 안된다.

recoverable schedule

- cascadeless schedule
- strict schedule

Isolation

- concurrency control providers **serializability & recoverability** 


---

## Reference

- [쉬운코드 concurrency control 2](https://www.youtube.com/watch?v=89TZbhmo8zk) 
