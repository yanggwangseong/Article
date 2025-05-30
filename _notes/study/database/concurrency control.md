---
title: concurrency control
permalink: /database/concurrency-control
tags: []
layout: note
image: /assets/812.jpg
category: 
description: Schedule이란 여러 transaction들이 동시에 실행될때 각 transaction에 속한 operation들의 실행 순서 Serial schedule란 transaction들이 겹치지 않고 한번에 하나씩 실행되는 schedule NonSerial schedule란transaction들이 겹쳐서(interleaving) 실행되는 schedule
---

![](/assets/812.jpg)

## 1. concurrency control

- 🐙 **[해당 본문 코드(GitHub)](https://github.com/yanggwangseong/implementation/tree/main/concurrency-control)** 

---

### 1.1 CASE1

![](/assets/concurrency-control01.png)

```ts

  // Case 1: K가 H에게 20만원 이체, H가 ATM에서 30만원 입금
  async case1Example(): Promise<void> {
    // Transaction 1: K -> H 20만원 이체
    await this.dataSource.transaction(async (manager) => {
      // K의 잔고 읽기
      const k = await manager.findOne(Account, { where: { owner: 'K' } });
      // H의 잔고 읽기
      const h = await manager.findOne(Account, { where: { owner: 'H' } });

      if (!k || !h) throw new Error('Account not found');
      if (k.balance < 200000) throw new Error('Insufficient funds');

      // K -20만원
      k.balance -= 200000;
      // H +20만원
      h.balance += 200000;

      await manager.save([k, h]);
      // Transaction 1 commit
    });

    // Transaction 2: H가 ATM에서 30만원 입금
    await this.dataSource.transaction(async (manager) => {
      // H의 잔고 읽기
      const h = await manager.findOne(Account, { where: { owner: 'H' } });
      if (!h) throw new Error('Account not found');

      // H +30만원
      h.balance += 300000;
      await manager.save(h);
      // Transaction 2 commit
    });
  }

```

### 1.2 CASE2

![](/assets/concurrency-control02.png)

```ts
// Case 2: H가 ATM에서 30만원 입금 후, K가 H에게 20만원 이체
  async case2Example(): Promise<void> {
    // Transaction 2: H가 ATM에서 30만원 입금
    await this.dataSource.transaction(async (manager) => {
      // H의 잔고 읽기
      const h = await manager.findOne(Account, { where: { owner: 'H' } });
      if (!h) throw new Error('Account not found');

      // H +30만원
      h.balance += 300000;
      await manager.save(h);
      // Transaction 2 commit
    });

    // Transaction 1: K -> H 20만원 이체
    await this.dataSource.transaction(async (manager) => {
      // K의 잔고 읽기
      const k = await manager.findOne(Account, { where: { owner: 'K' } });
      // H의 잔고 읽기
      const h = await manager.findOne(Account, { where: { owner: 'H' } });

      if (!k || !h) throw new Error('Account not found');
      if (k.balance < 200000) throw new Error('Insufficient funds');

      // K -20만원
      k.balance -= 200000;
      // H +20만원
      h.balance += 200000;

      await manager.save([k, h]);
      // Transaction 1 commit
    });
  }
```

### 1.3 CASE3

![](/assets/concurrency-control03.png)

```ts
// Case 3: 트랜잭션이 겹쳐서 H의 입금이 먼저 커밋되고, 그 후 K의 이체가 H의 잔고에 반영됨
  async case3Example(): Promise<void> {
    // Transaction 1: K -> H 20만원 이체 (커밋은 나중에)
    await this.dataSource.transaction(async (manager1) => {
      // K의 잔고 읽기
      const k = await manager1.findOne(Account, { where: { owner: 'K' } });
      if (!k) throw new Error('Account not found');
      if (k.balance < 200000) throw new Error('Insufficient funds');
      // K -20만원
      k.balance -= 200000;
      // Transaction 2: H가 ATM에서 30만원 입금
      await this.dataSource.transaction(async (manager2) => {
        // H의 잔고 읽기
        const h = await manager2.findOne(Account, { where: { owner: 'H' } });
        if (!h) throw new Error('Account not found');
        // H +30만원
        h.balance += 300000;
        await manager2.save(h);
        // Transaction 2 커밋

        // Transaction 1에서, H의 잔고를 읽을때 H의 잔고는 230만원인 상태
        const hAfter = await manager1.findOne(Account, {
          where: { owner: 'H' },
        });
        if (!hAfter) throw new Error('Account not found');
        hAfter.balance += 200000;
        // Transaction 1 H잔고 커밋 (Transaction 2 커밋 후)
        await manager1.save(hAfter);
      });
      // Transaction 1 K잔고 커밋
      await manager1.save(k);
    });
  }
```

### 1.4 CASE4 (Lost Update 케이스)

![](/assets/concurrency-control04.png)

```ts
// Case 4: 트랜잭션이 겹쳐서 H의 입금이 먼저 커밋되고, 그 후 K의 이체가 H의 잔고에 반영되지만, 마지막에 H의 잔고가 덮어써짐
  async case4Example(): Promise<void> {
    // Transaction 1: K -> H 20만원 이체 (H의 잔고는 아직 반영X)
    await this.dataSource.transaction(async (manager1) => {
      // K의 잔고 읽기
      const k = await manager1.findOne(Account, { where: { owner: 'K' } });
      // H의 잔고 읽기
      const h = await manager1.findOne(Account, { where: { owner: 'H' } });
      if (!k || !h) throw new Error('Account not found');
      if (k.balance < 200000) throw new Error('Insufficient funds');
      // K -20만원
      k.balance -= 200000;
      await manager1.save(k);
      // H의 잔고를 읽어두지만, 아직 write하지 않음
      // Transaction 1은 아직 커밋하지 않음 (논리적 시뮬레이션)
    });

    // Transaction 2: H가 ATM에서 30만원 입금
    await this.dataSource.transaction(async (manager2) => {
      // H의 잔고 읽기
      const h = await manager2.findOne(Account, { where: { owner: 'H' } });
      if (!h) throw new Error('Account not found');
      // H +30만원
      h.balance += 300000;
      await manager2.save(h);
      // Transaction 2 커밋
    });

    // Transaction 1의 H 잔고 write (덮어쓰기)
    await this.dataSource.transaction(async (manager1) => {
      const h = await manager1.findOne(Account, { where: { owner: 'H' } });
      if (!h) throw new Error('Account not found');
      // Transaction 1에서 읽었던 값에 +20만원만 반영 (실제로는 200만원에서 +20만원)
      h.balance = 2200000;
      await manager1.save(h);
      // Transaction 1 커밋
    });
  }
```

#### 1.4.1 Lost Update

**Lost Update란?**

서로 다른 트랜잭션에서 아직 커밋 하지 않은 칼럼 데이터에 대해서 write를 발생 했을때 데이터의 일관성을 잃어 버리는것을 말합니다.

**operation이란?** 

트랜잭션에서 `read` 와 `write` 를 **operation** 이라고 합니다.

## 3. Schedule

### 3.1 Schedule이란

- Schedule이란
	- 여러 transaction들이 동시에 실행될때 각 transaction에 속한 operation(read, write)들의 실행 순서
	- **각 transaction 내의 operations들의 순서는 바뀌지 않는다** 

#### 3.1.1 Schedule 표현식

위의 예제에서 `read(K_balance)` `write(K_balance)` `commit` 해당 부분을 간소화 시켜서 가로 표현식으로 나타낼 수 있다.

- **CASE1** : r1(K) w1(K) r1(H) w1(H) c1 r2(H) w2(H) c2
- **CASE2** : r2(H) w2(H) c2 r1(K) w1(K) r1(H) w1(H) c1
- **CASE3** : r1(K) w1(K) r2(H) w2(H) c2 r1(H) w1(H) c1
- **CASE4** : r1(K) w1(K) r1(H) r2(H) w2(H) c2 w1(H) c1

### 3.2 Serial schedule

transaction들이 겹치지 않고 한번에 하나씩 실행되는 schedule

**예시)**

- **CASE1** : r1(K) w1(K) r1(H) w1(H) c1 r2(H) w2(H) c2
- **CASE2** : r2(H) w2(H) c2 r1(K) w1(K) r1(H) w1(H) c1

#### 3.2.1 Serial schedule 성능
장점으로는 **Lost Update** 같은 데이터 정합성이 깨지는 일은 없다.
단점으로는 한번에 하나의 **transaction** 만 실행되기 때문에 좋은 성능을 낼 수 없고 현실적으로 사용할 수 없는 방식이다.

#### 3.2.2 왜 좋은 성능을 낼 수 없을까?

트랜잭션끼리 겹치지 않는 Schedule이기 때문에 동시성이 없는 스케줄이라고도 부르고 그렇기 때문에 효율적으로 병렬처리 할 수 없다.

Serial Schedule은 **모든 트랜잭션을 순차적으로 실행**하므로, **CPU 코어가 여러 개 있어도 동시에 처리하지 못하고, 자원 활용률이 극히 낮아집니다.**

I/O, CPU 사용률, DB 커넥션 등 자원을 효율적으로 사용할 수 없어 **낮은 처리량(throughput)** 을 가집니다.

#### 3.2.3 왜 현실적으로 사용 할 수 없는 방법일까?

Serial Schedule은 이상적으로는 데이터 정합성을 100% 보장하지만, **모든 트랜잭션을 순차적으로 처리**해야 하므로 **현실적인 동시 사용자 환경에선 처리량이 극단적으로 낮아집니다.** 

오늘날의 시스템은 수백~수천 개의 트랜잭션을 동시에 처리해야 하며, **병렬성과 자원 효율을 확보하지 않으면 심각한 성능 저하**가 발생하기 때문에 **Serial Schedule은 이론적인 기준일 뿐 현실적으로는 사용되지 않습니다.** 

### 3.3 NonSerial schedule

transaction들이 겹쳐서(interleaving) 실행되는 schedule

**예시)**

- **CASE3** : r1(K) w1(K) r2(H) w2(H) c2 r1(H) w1(H) c1
- **CASE4** : r1(K) w1(K) r1(H) r2(H) w2(H) c2 w1(H) c1

#### 3.3.1 NonSerial schedule 성능

- Serial Schedule : r2(H) w2(H) c2 r1(K) w1(K) r1(H) w1(H) c1
- NonSerial Schedule : r2(H) r1(K) w2(H) w1(K) c2 r1(H) w1(H) c1

장점

**transaction들이 겹쳐서 실행되기 때문에 동시성이 높아져서 같은 시간 동안 더 많은 transaction들을 처리할 수 있다.**

단점

**transaction들이 어떤 형태로 겹쳐서 실행되는지에 따라 이상한 결과가 나올 수 있다** 

## 4. 현대 개선 방법

#### 4.1.1 고민거리

nonserial schedule로 실행해도 이상한 결과가 나오지 않을 수 있는 방법을 연구하기 시작

성능을 위해서 nonserial schedule로 동작 하면서 데이터 정합성까지 유지하고 싶다.

#### 4.1.2 아이디어

serial schedule과 동일한(equivalent) nonserial schedule을 실행하면 되겠다!

**schedule이 equivalent(동일하다)** 의 의미가 무엇인지 정의하는것이 필요했다.

### 4.2 Conflict

**of two operations** 2개의 오퍼레이션에서 사용하는 개념

세가지 조건을 모두 만족하면 **conflict** 

1. 서로 다른 transaction 소속
2. 같은 데이터에 접근
3. 최소 하나는 write operation

#### 4.2.1 Conflict 종류

- **CASE3** : r1(K) w1(K) r2(H) w2(H) c2 r1(H) w1(H) c1

- **read-write conflict** 
	- `r2(H)` 와 `w1(H)` 처럼 3가지 조건을 만족하는 케이스를 **read-write conflict** 라고 한다.
- **write-write conflict** 
	- `w2(H)` 와 `w1(H)` 처럼 3가지 조건을 만족하는 케이스를 **write-write conflict** 라고 한다.

**Conflict Operation은 순서가 바뀌면 결과도 바뀌기 때문에 중요하다** 

### 4.3 Conflict equivalent

**for two schedules** 

2개의 schedule이 두 조건 모두 만족하면 **Conflict Equivalent** 

1. 두 schedule은 같은 transaction들을 가진다.
2. 어떤(any) conflicting operations의 순서도 양쪽 schedule 모두 동일하다.

**예시)**

- **CASE2** : `r2(H)` `w2(H)` c2 r1(K) w1(K) r1(H) `w1(H)` c1
- **CASE3** : r1(K) w1(K) `r2(H)` `w2(H)` c2 r1(H) `w1(H)` c1

**조건1 두 스케줄은 같은 트랜잭션들을 가진다를 만족한다.**

**조건2 conflicting operations의 순서가 양쪽 스케줄 모두 동일한가**

EX1)

- CASE2 `r2(H)` `w1(H)` 
- CASE3 `r2(H)` `w1(H)` 

EX2)

- CASE2 `w2(H)` `w1(H)` 
- CASE3 `w2(H)` `w1(H)` 

이처럼 operation 순서가 양쪽 스케줄 모두 동일한것을 알 수 있고 즉, 해당 2개의 Schedule은 조건 1과 2를 둘다 만족하는 **Conflict equivalent** 

#### 4.3.1 ⭐️ Conflict serializable

위의 예제에서 **CASE2 Schedule은 serial schedule** 이다.

즉, **serial schedule과 conflict equivalent일때 이를 Conflict serializable** 이라고 한다.

**⭐️ 결론**

**CASE3 nonserial Schedule은 conflict serializable하다!**

**그래서 nonserial Schedule임에도 불구하고 데이터 정합성이 깨지지않고 정상적인 결과를 낼 수 있게된다!** 

#### 4.3.2 아닌 케이스 Schedule4

**예시)**

- **CASE4** : r1(K) w1(K) r1(H) r2(H) w2(H) c2 w1(H) c1 (nonserial)
- **CASE2** : r2(H) w2(H) c2 r1(K) w1(K) r1(H) w1(H) c1 (serial)

#### 4.3.3 Schedule4와 2는 conflict equivalent 할까?

1. 두 schedule은 같은 transaction들을 가진다.
2. 어떤(any) conflicting operations의 순서도 양쪽 schedule 모두 동일하다.

조건 1은 만족한다.

조건2

CASE4에서  `r1(H)` 와 `w2(H)` 의 순서와 CASE2에서 `w2(H)` 와 `r1(H)` 순서로 순서가 같지 않다!

즉, `CASE2(schedule2)` 는 **NOT conflict equivalent** 이다.

#### 4.3.4 Schedule4와 1은 conflict equivalent 할까?

**예시)**

- **CASE4** : r1(K) w1(K) r1(H) r2(H) w2(H) c2 w1(H) c1 (nonserial)
- **CASE1** : r1(K) w1(K) r1(H) w1(H) c1 r2(H) w2(H) c2 (serial)

1. 두 schedule은 같은 transaction들을 가진다.
2. 어떤(any) conflicting operations의 순서도 양쪽 schedule 모두 동일하다.

조건 1은 만족한다.

조건2

- CASE4 `r1(H)` 와 `w2(H)` 순서와 CASE1 `r1(H)` 와 `w2(H)` (순서가 동일하다 ✅)
- CASE4 `r2(H)` 와 `w1(H)` 순서와 CASE1 `w1(H)` 와 `r2(H)` (순서가 다르다 ❌)

즉, `CASE1(schedule1)` 는 **NOT conflict equivalent** 이다.

#### 4.3.5 ⭐️ 결론

**결론적으로 CASE4(schedule4)은 어떤 serial schedule과도 conflict equivalent** 하지 않다.

**즉, CASE4(schedule4)은 NOT conflict serializable이다.**  

### 4.4 결론

#### 4.4.1 문제

- 성능 때문에 여러 transaction들을 겹쳐서 실행 할 수 있으면 좋다 (nonserial schedule)
- 하지만 데이터 정합성이 깨질 수 있다.

#### 4.4.2 해결책

- **conflict serializable한 nonserial schedule을 허용하자!**

#### 4.4.3 구현

- ❌ 여러 transaction이 실행될때마다 해당 schedule이 conflict serializable인지 확인
	- 실제로는 사용하지 않는데 많은 요청이 몰려오면 동시에 실행될 수 있는 트랜잭션의 수가 너무 많기 때문에 어떤 schedule이 conflict serializable한지 확인하는것이 비용이 많이 들기 때문에
- ✅ 여러 transaction을 동시에 실행해도 schedule이 conflict serializable 할 수 있도록 보장하는 **프로토콜** 을 적용한다.

## 5. 정리

- a schedule -> equivalent -> a serial schedule -> **serializable**
	- 어떤 schedule이 임의의 serial schedule과 동일(equivalent) 하다면 이 schedule이 serializable 하다고 말한다.
- a schedule -> conflict equivalent -> a serial schedule -> **conflict serializability**
	- 어떤 schedule이 어떤 serial schedule과 conflict equivalent하다면 이 schedule이 conflict serializability 하다고 말한다.
- a schedule -> **view equivalent** -> a serial schedule -> **view serializable**
	- 어떤 schedule이 어떤 serial schedule과 view equivalent 하다면 이 schedule이 view serializable 하다고 말한다.
- serializable -> any schedule -> makes -> concurrency control
	- 어떤 스케줄이라도 serializable하게 만드는게 concurrency control 이다. 이것과 밀접한 관계가 있는 트랜잭션의 속성이 Isolation이다
- Isolation을 너무 엄격하게 serializable을 추구하게 되면 성능이 저하되게 된다.
	- 동시성이 떨어지게 된다.
- isolation -> relaxed -> provide -> isolation level
	- Isolation을 조금 완화 시켜서(relaxed) 개발자들이 컨트롤 할 수 있게 제공 하는게 Isolation level이다.
- **여러 트랜잭션들이 동시에 실행될때 중요한 개념이 serializability이다.**
- **롤백을 했을때 중요한 개념이 recoverability이다.**


---

## Reference

- [쉬운코드 concurrency control 1](https://www.youtube.com/watch?v=DwRN24nWbEc) 
