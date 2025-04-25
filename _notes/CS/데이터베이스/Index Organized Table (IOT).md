---
title: Index Organized Table (IOT)
permalink: /cs/database/Index-organized-table
tags:
  - Database
  - Oracle
layout: page
---

## Index Organized Table(IOT)란?

- 데이터에 일반적으로 사용되는 Heap Organized 테이블과 달리 IOT의 데이터는 기본 키 정렬된 방식으로 B-Tree 인덱스 구조에 저장 됩니다.
- 인덱스 구조의 각 Leaf 블록은 Key 및 Non-Key 튜플을 모두 저장합니다.
- 쉽게 말해서 데이터 자체를 인덱스 구조내에 포함하여 파일을 구성하는 방식을 말합니다.

## IOT를 왜 사용할까?

1. 빠른 기본 키 검색
	- 데이터가 기본 키 순으로 정렬되어 저장되어 있으므로, **기본 키를 조건으로 하는 검색 속도가 매우 빠릅니다.** 
	- Heap 테이블에서는 인덱스를 통해 ROWID를 찾고, 다시 테이블에서 데이터를 조회해야 하지만, IOT는 **인덱스만으로도 데이터 전체를 조회(index-only scan)** 할 수 있습니다.
2. 범위 조건 검색에 최적화
	- 기본 키 정렬 덕분에 **범위 조건** 에 대한 성능도 뛰어납니다.
	- B-Tree의 구조상 연속된 키 값을 빠르게 순회할 수 있어, 순차 조회나 페이지네이션 등에 효과적입니다.
3. 공간 효율성
	- 일반 테이블은 인덱스에 키를 저장하고, 본 테이블에도 다시 저장해야 하기 때문에 **데이터 중복이 발생**합니다.
	- 반면, IOT는 **인덱스가 곧 테이블이기 때문에 중복이 사라지고 저장 공간이 절감**됩니다.
4. 갱신 효율성
	- 데이터 변경(Insert, Update, Delete)이 있을 때, Heap 테이블은 테이블과 인덱스를 **각각 갱신**해야 하지만,
	- IOT는 **단일 인덱스 구조만 갱신**하면 되므로 갱신 작업이 더 간단하고 빠릅니다.


# Reference

- [Oracle Docs](https://docs.oracle.com/cd/B28359_01/server.111/b28310/tables012.htm#ADMIN01506) 

