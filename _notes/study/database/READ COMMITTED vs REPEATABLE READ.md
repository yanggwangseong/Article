---
title: READ COMMITTED vs REPEATABLE READ 차이
permalink: /database/READ COMMITTED-vs-REPEATABLE READ
tags: 
layout: note
image: /assets/812.jpg
category: 
description:
---

![](/assets/812.jpg)

## 1. READ COMMITTED vs REPEATABLE READ

---

### 1.1 READ COMMITTED vs REPEATABLE READ 차이 흐름

**예시**

| 시점  | 트랜잭션 A (조회)                                  | 트랜잭션 B (수정)                                  |
| --- | -------------------------------------------- | -------------------------------------------- |
| T1  | BEGIN                                        |                                              |
| T2  | `SELECT * FROM user WHERE id = 1;` → 이름: Kim |                                              |
| T3  |                                              | BEGIN                                        |
| T4  |                                              | `UPDATE user SET name = 'Lee' WHERE id = 1;` |
| T5  |                                              | COMMIT                                       |
| T6  | `SELECT * FROM user WHERE id = 1;` → ❓       |                                              |

#### 1.1.1 결과 비교

| 격리 수준           | T6에서 보이는 name 값 | 설명                                                  |
| --------------- | --------------- | --------------------------------------------------- |
| READ COMMITTED  | `'Lee'`         | 트랜잭션 B가 COMMIT한 최신 데이터를 읽음 (Non-Repeatable Read 발생) |
| REPEATABLE READ | `'Kim'`         | 트랜잭션 A가 처음 SELECT한 시점의 스냅샷 데이터를 계속 유지함              |

---

## 2. MVCC 기반 동작

### 2.1 MVCC(Multi-Version Concurrency Control)이란?

- 동시에 여러 트랜잭션이 데이터를 읽고 쓰는 상황에서도 **락 없이 일관된 읽기**를 제공하기 위한 메커니즘입니다.
- **하나의 데이터에 대해 여러 버전(스냅샷)** 을 유지하고, 트랜잭션 시작 시점의 버전을 기준으로 데이터를 조회합니다.

#### 2.1.1 Isolation Level에 따른 MVCC 동작

| 격리 수준           | MVCC 관점 동작 요약                                       |
| --------------- | --------------------------------------------------- |
| READ COMMITTED  | **매 쿼리마다 최신 커밋된 버전**의 데이터를 읽음                       |
| REPEATABLE READ | **트랜잭션 시작 시점의 스냅샷**을 고정해서 읽음 (→ snapshot isolation) |

## 3. 정리

| 항목                  | READ COMMITTED              | REPEATABLE READ             |
| ------------------- | --------------------------- | --------------------------- |
| 조회 일관성              | 매 쿼리마다 최신 데이터               | 트랜잭션 시작 시점 고정               |
| Non-Repeatable Read | 발생함                         | 발생 안 함                      |
| Phantom Read        | 발생함                         | InnoDB에서는 **Gap Lock**으로 방지 |
| 사용 용도               | 대부분의 시스템에서 기본값 (PostgreSQL) | MySQL InnoDB의 기본값           |

---

## Reference

