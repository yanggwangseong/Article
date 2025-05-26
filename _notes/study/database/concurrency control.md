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

![[Pasted image 20250523175957.png]]

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

![[Pasted image 20250523180656.png]]

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

![[Pasted image 20250523191231.png]]

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
      await manager1.save(k);
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
      // Transaction 2 커밋 후, H의 잔고를 다시 읽고 +20만원
      const hAfter = await manager2.findOne(Account, { where: { owner: 'H' } });
      if (!hAfter) throw new Error('Account not found');
      hAfter.balance += 200000;
      await manager2.save(hAfter);
    });
    // Transaction 1 커밋 (논리적 시뮬레이션)
  }
```

### 1.4 CASE4 (Lost Update 케이스)

![[Pasted image 20250523191718.png]]

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

- Lost Update란?

## 3. Schedule

- Schedule이란
	- 여러 transaction들이 동시에 실행될때 각 transaction에 속한 operation들의 실행 순서
	- **각 transaction 내의 operations들의 순서는 바뀌지 않는다** 

## 3.1 Serial schedule

transaction들이 겹치지 않고 한번에 하나씩 실행되는 schedule

### 3.1.1 Serial schedule 성능


## 3.2 NonSerial schedule

transaction들이 겹쳐서(interleaving) 실행되는 schedule

### 3.2.1 NonSerial schedule 성능


## 4. 정리

a schedule -> equivalent -> a serial schedule -> serializable

어떤 schedule이 임의의 serial schedule과 동일(equivalent) 하다면 이 schedule이 serializable 하다고 말한다.

a schedule -> conflict equivalent -> a serial schedule -> conflict serializability

어떤 schedule이 어떤 serial schedule과 conflict equivalent하다면 이 schedule이 conflict serializability 하다고 말한다.

a schedule -> view equivalent -> a serial schedule -> view serializable

concurrency control -> makes -> any schedule -> serializable

어떤 스케줄이라도 serializable하게 만드는게 concurrency control 이다
이것과 밀접한 관계가 있는 트랜잭션의 속성이 Isolation이다

Isolation을 너무 엄격하게 serializable을 추구하게 되면 성능이 저하되게 된다.

동시성이 떨어지게 된다.

Isolation level -> provide -> relaxed -> isolation

Isolation을 조금 완화 시켜서(relaxed) 개발자들이 컨트롤 할 수 있게 제공 하는게 Isolation level이다.

롤백을 했을때 중요한 개념이 recoverability이다.

## recoverable schedule

## cascadeless schedule

## strict schedule




---

## Reference

- [쉬운코드 concurrency control 1](https://www.youtube.com/watch?v=DwRN24nWbEc) 
- [쉬운코드 concurrency control 2](https://www.youtube.com/watch?v=89TZbhmo8zk) 

