---
title: ch-11-file-system
permalink: /cs/os/operation-system/ch-11-file-system
tags:
  - OS
layout: page
---

# Section

- *Disk System*
- *File System*
	- Partition
	- Directory
	- File
- Directory Structure
- File Protection
- Allocation Methods
- Free Space Management

# Disk System

## Disk pack

![](/assets/os-file-system-image01.png)

![](/assets/os-file-system-image02.png)

- Disk pack
	- 데이터 영구 저장 장치 (비휘발성)
	- 구성
		- **Sector** 
			- 데이터 저장 / 판독의 물리적 단위
		- **Track**
			- Platter 한 면에서 중심으로 같은 거리에 있는 sector들의 집합
		- **Cylinder** 
			- 같은 반지름을 갖는 track의 집합
		- **Platter** 
			- 양면에 자성 물질을 입힌 원형 금속판
			- 데이터의 기록/판독이 가능한 기록 매체
		- **Surface**
			- Platter의 윗면과 아랫면

## Disk drive

![](/assets/os-file-system-image03.png)

- Disk drive
	- Disk pack에 데이터를 기록하거나 판독할 수 있도록 구성된 장치
		- EX) HDD
	- 구성
		- **Head**
			- 디스크 표면에 데이터를 기록/판독
		- **Arm** 
			- Head를 고정/지탱
		- **Positioner (boom)** 
			- Arm을 지탱
			- Head를 원하는 track으로 이동
		- **Spindle** 
			- Disk pack을 고정 (회전축)
			- 분당 회전 수 (RPM, Revolutions Per Minute)

## Disk Address

- **Physical disk address**
	- Sector (물리적 데이터 전송 단위)를 지정

![](/assets/os-file-system-image04.png)

- **Logical disk address: relative address**
	- Disk system의 데이터 전체를 block들의 나열로 취급
		- Block에 번호 부여
		- 임의의 block에 접근 가능
	- Block 번호 -> physical address 모듈 필요 (disk driver)

![](/assets/os-file-system-image05.png)

**디스크의 Logical address (B0, B1 등)을 Physical address로 누가 바꿔줄까?** 

- **disk driver** 
	- Logical disk address를 Physical disk address로 변경 해준다.
	- EX) 그래픽카드 샀을때 그래픽 카드 Driver 설치

![](/assets/os-file-system-image06.png)

## Data Access in Disk System

1. Seek time
	- 디스크 head를 필요한 cylinder로 이동 하는 시간
2. Rotational delay
	- 필요한 sector가 head 위치로 도착하는 시간
3. Data transmission time
	- 해당 sector를 읽어서 전송 (or 기록) 하는 시간

# File System

- File System이란?
	- 사용자들이 사용하는 파일들을 관리하는 운영체제의 한 부분
- File System의 구성
	- **Files** 
		- 연관된 정보의 집합
	- **Directory structure**
		- 시스템 내 파일들의 정보를 구성 및 제공
		- EX) 파일 디렉토리
	- **Partitions**
		- Directory들의 집합을 논리적/물리적으로 구분
		- EX) C드라이버, D드라이버

## File Concept

- 보조 기억 장치에 저장된 연관된 정보들의 집합
	- 보조 기억 장치 할당의 최소 단위
	- Sequence of bytes (물리적 정의)
- 내용에 따른 분류
	- Program file
		- Source program, object program, executable files
	- Data file
- 형태에 따른 분류
	- Text (ascii) file
	- Binary file
- File Attribute
- File operations
	- Create
	- Write
	- Read
	- Reposition
	- Delete
	- Etc.
- OS는 file operation들에 대한 system call을 제공해야 함

## File Access Methods

- **Sequential access (순차 접근)** 
	- File을 record(or bytes) 단위로 순서대로 접근
		- `E.g., fgetc()` 
- **Directed access (직접 접근)** 
	- 원하는 Block을 직접 접근
		- `E.g., lseek(), seek()` 
- **Indexed access**
	- Index를 참조하여, 원하는 block를 찾은 후 데이터에 접근

## File System Organization

![](/assets/os-file-system-image12.png)

![](/assets/os-file-system-image13.png)

- **Partitions(minidisks, volumes)** 
	- Virtual disk
- **Directory** 
	- File들을 분류, 보관하기 위한 개념
	- Operations on directory
		- Search for a file
		- Create a file
		- Delete a file
		- List a directory
		- Rename a file
		- Traverse the file system


![](/assets/os-file-system-image14.png)

- **Mounting** 
	- 현재 FS에 다른 FS를 붙이는 것
	- EX) Android -> "SD카드"

# Directory Structure

- **Logical directory structure** 
	- Flat (single-level) directory structure
	- 2-level directory structure
	- Hierarchical (tree-structure) directory structure
	- Acyclic graph directory structure
	- General graph directory structure

## Flat Directory Structure

- **FS내에 하나의 directory만 존재** 
	- Single-level directory structure
- Issues
	- File naming
	- File protection
	- File management
	- 다중 사용자 환경에서 문제가 더욱 커짐


# File Protection

- **File Protection이란?**
	- File에 대한 부적절한 접근 방지
		- 다중 사용자 시스템에서 더욱 필요
- **접근 제어가 필요한 연산들**
	- Read (R)
	- Write (W)
	- Execute (X)
	- Append (A)

## File Protection Mechanism

- 파일 보호 기법은 system size 및 응용 분야에 따라 다를 수 있음.

1. Password 기법
	- 각 file들에 PW 부여
	- 비현실적
		- 사용자들이 파일 각각에 대한 PW를 기억 해야함.
		- 접근 권할 별로 서로 다른 PW를 부여 해야함.
2. Access Matrix 기법
	- (TODO)




