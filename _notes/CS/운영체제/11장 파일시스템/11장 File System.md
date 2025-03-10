---
title: ch-11-file-system
permalink: /cs/os/operation-system/ch-11-file-system
tags:
  - OS
layout: page
---

# Section

- *Disk System*
- File System
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

