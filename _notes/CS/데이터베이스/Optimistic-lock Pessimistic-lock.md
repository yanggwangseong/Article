---
title: Optimistic-lock-Pessimistic-lock
permalink: /Optimistic-lock-Pessimistic-lock
tags:
  - post
  - Database
  - typeorm
layout: page
category:
---

## Optimistic-lock-Pessimistic-lock

- 🐙 **[Github 예제 코드](https://github.com/yanggwangseong/implementation)**

---

### 📚 Contents

1. 11
2. 22
3. 33

---

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


