---
title: Slotted Page Structure
permalink: /cs/database/slotted-page-structure
tags:
  - Database
  - Postgresql
layout: page
---

- **왜 슬롯페이지 구조인가?** 
	- 가변 길이 레코드의 **삽입/삭제/갱신 시 공간 낭비를 줄이고, 레코드 이동을 투명하게 처리** 
- **어디서 사용할까?** 
	- Postgresql에서 사용
		- Page Layout
		- HOT (Heap Only Tuple)
		- Single-page Vacuuming
		- Fillfactor

# PostgreSQL에서의 가변길이 레코드 관리와 공간 효율화 전략

### 1️⃣ 가변길이 레코드와 슬롯 페이지 구조

- **가변 길이 레코드**란?
    
    - 예: TEXT, VARCHAR, JSON 등 가변적인 크기를 가지는 데이터 타입
        
- **슬롯 페이지 구조(Slotted Page Structure)** 개요
    
    - 페이지 헤더 + 슬롯 테이블 + 레코드 실제 데이터
        
    - 레코드 이동 시에도 **슬롯만 갱신** → 위치 변경 투명성 확보
        
- **PostgreSQL의 실제 구현: Heap Page 구조**
    
    - 공식 문서: [Storage Page Layout](https://www.postgresql.org/docs/current/storage-page-layout.html)
        
    - 내부 구조: PageHeaderData, ItemIdData (슬롯 역할), HeapTuple

### 2️⃣ HOT(Heap-Only Tuple) — 공간 재사용 최적화

- 레코드 업데이트 시, 가능한 경우 **새 튜플을 같은 페이지 내에 체이닝하여 연결**
    
- **인덱스 수정 없이** 업데이트 가능 → 성능 및 공간 효율 개선
    
- 공식 문서: [Storage and HOT](https://www.postgresql.org/docs/current/storage-hot.html)
    
- HOT 체인으로 인한 **페이지 내부 공간 재사용**

### 3️⃣ VACUUM — 공간 회수(Garbage Collection)

- PostgreSQL의 **MVCC 기반으로 인한 dead tuple 증가**
    
- `VACUUM`의 역할: **죽은 튜플을 정리**하여 공간 회수 + 통계 정보 갱신
    
- 종류:
    
    - `VACUUM`: 단순 정리
        
    - `VACUUM FULL`: 물리적 정리 + 테이블 재정렬
        
    - `AUTOVACUUM`: 자동 트리거
        

> 💡 HOT와 VACUUM은 함께 작동하여 PostgreSQL이 **가변길이 레코드를 효율적으로 관리**할 수 있도록 도와줌


### 4️⃣ Replication Slot — WAL의 가비지 수집 보류 메커니즘

- PostgreSQL의 복제 시스템은 **WAL 로그를 기반으로 작동**
    
- **Replication Slot**이 존재하면 해당 slot에서 소비되기 전까지 **WAL을 삭제하지 않음**
    
- 공식 뷰: `pg_replication_slots`
    
- 비유: 다른 클라이언트가 "이 WAL 아직 읽고 있어!" 하고 표시해둔 것
    

> 🔄 VACUUM은 튜플을 정리하지만, Replication Slot은 **WAL 로그**를 정리할 수 없게 만들기도 하므로, 둘의 관계를 이해하는 게 중요!


```
[가변길이 레코드]
     ↓
[슬롯 페이지 구조] ──> [PostgreSQL Heap Page 구조]
                            ↓
                         [HOT] ──> [VACUUM으로 공간 회수]
                            ↓
           [Replication Slot은 WAL 회수 지연 (GC 관점에서 예외 처리 필요)]
```


# Reference

- Operating System Concepts 10th (공룡책)
- 데이터베이스 시스템 7th (돛단배책)
- [PostgreSQL Page와 관리](https://blog.ex-em.com/1764) 
- [Postgresql Docs Page Layout](https://www.postgresql.org/docs/current/storage-page-layout.html) 
- [Postgresql Docs HOT](https://www.postgresql.org/docs/current/storage-hot.html?utm_source=chatgpt.com) 
- [Postgresql Docs pg-replication-slots](https://www.postgresql.org/docs/9.4/catalog-pg-replication-slots.html) 
- [Postgresql Vacuum과 slot page 구조 우아한형제들](https://techblog.woowahan.com/9478/) 

