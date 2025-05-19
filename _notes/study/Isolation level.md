---
title: Isolation-level
permalink: /study/Isolation-level
tags:
  - study
layout: study
image: /assets/cat01.png
timepoint: 2h
realtimepoint:
---

## 비관적 락 낙관적 락


---

### 📚 Contents

1. 개요
2. 문제
3. 문제 해결 및 결과

---

**낙관적 락(Optimistic Lock)** 은 데이터 충돌이 적을 것으로 가정하고, 데이터를 읽을 때 락을 설정하지 않고 트랜잭션이 데이터를 수정할 때 충돌이 발생하지 않았는지 확인하는 방식입니다. 보통 version과 같은 별도의 구분 컬럼을 사용해서 데이터가 변경되었는지 확인하며, 충돌이 발생하면 데이터베이스가 아닌 애플리케이션에서 직접 롤백하거나 재시도 처리를 해야 합니다.

**비관적 락(Pessimistic Lock)** 은 데이터 충돌이 많을 것으로 가정하고, 트랜잭션이 시작될 때 공유락(Shared Lock, S-Lock) 또는 베타락(Exclusive Lock, X-Lock)을 설정하여 다른 트랜잭션이 해당 데이터에 접근하지 못하도록 하는 방식입니다.

**'READ UNCOMMITTED', 'READ COMMITTED', 'REPEATABLE READ', 'SERIALIZABLE'** 

https://amenable.tistory.com/144 

- 현상 - DIRTY READ, NON-REPEATABLE READ, PHANTOM READ

1. ACID 중 Isolation(격리성)을 깊이 이해하고 있다
2. DB 동시성 제어와 관련된 문제를 식별하고, 적절한 격리 수준을 선택할 수 있다
3. RDB의 다중 트랜잭션 환경에서 발생할 수 있는 대표적인 문제들을 알고 있다


## 3. TypeOrm의 비관적 락 방식들

typeOrm에서 비관적 락을 설정할려고 할때 다음과 같은 방식들을 사용할 수 있다.

**pessimistic_read** (비관적인 읽기 락)

트랜잭션이 읽은 데이터를 해당 트랜잭션이 종료될 때까지 다른 트랜잭션이 읽는 것을 허용하면서, 쓰기 또는 수정하는 것을 방지합니다.

**pessimistic_write** (비관적인 쓰기 락)

트랜잭션이 읽은 데이터를 해당 트랜잭션이 종료될 때까지 다른 트랜잭션이 읽기, 쓰기, 수정하는 것을 방지하며 접근하지 못하도록 합니다.

**dirty_read** (더티 리드)

SERIALIZABLE isolation level에서 사용되는 Lock 모드로, 다른 트랜잭션이 커밋되지 않은 데이터를 읽는 것을 허용합니다.  
다른 트랜잭션이 롤백할 경우, 읽은 데이터는 실제로 존재하지 않았던 것으로 간주됩니다.

**pessimistic_partial_write** (비관적인 부분 쓰기 락)

엔티티의 일부분에 대한 쓰기 작업에만 강력한 Lock을 적용합니다.  
부분적인 쓰기 락을 설정하여 특정 필드만 다른 트랜잭션이 수정하지 못하도록 합니다.

**pessimistic_write_or_fail** (비관적인 쓰기 락 또는 실패)

쓰기 작업을 시도하고 실패할 경우 예외를 발생시킵니다.  
다른 트랜잭션이 해당 데이터에 쓰기 작업을 수행 중이면 예외가 발생합니다.

**for_no_key_update** (키 업데이트 없음)

엔티티의 키에 대한 업데이트를 허용하지 않습니다.  
키 필드가 변경되면 해당 엔티티의 저장이 실패합니다.

**for_key_share** (키 공유)

읽기 작업에 대한 Lock을 걸지 않고, 엔티티의 키만을 공유 Lock으로 설정합니다.  
다른 트랜잭션이 해당 엔티티를 읽는 것을 허용하지만, 키에 대한 수정을 막습니다.




---

## Reference

- https://github.com/LandazuriPaul/nest-react
