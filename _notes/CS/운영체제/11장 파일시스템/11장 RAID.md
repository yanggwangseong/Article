---
title: RAID
permalink: /cs/os/operation-system/ch-11-RAID
tags:
  - OS
layout: page
---

# Section

- RAID

# RAID

- **redundant arrays of independent disk (RAID)란?**
	- 여러개의 물리 disk를 하나의 논리 disk로 사용
		- OS support, RAID controller
- Disk system의 성능 향상을 위해 사용
	- Performance (access speed)
	- Reliability

## RAID 0

> **목적 : Parallel access로 Performance 향상**

![](/assets/os-file-system-image07.png)

- **Disk striping** 
	- 논리적인 한 block을 일정한 크기로 나누어 각 disk에 나누어 저장
- **모든 disk에 입출력 부하 균등 분배** 
	- Parallel access
	- Performance 향상
- **한 Disk에서 장애 시, 데이터 손실 발생** 
	- Low reliability

## RAID 1

> **목적 : High reliability 향상**

![](/assets/os-file-system-image08.png)

- **Disk mirroring** 
	- 동일한 데이터를 **mirroring** disk에 중복 저장
- **최소 2개의 disk로 구성** 
	- 입출력은 둘 중 어느 disk에서도 가능
- **한 disk에 장애가 생겨도 데이터 손실 X** 
	- High reliability
- **가용 disk 용량 = (전체 disk 용량/2)** 


## RAID 3

![](/assets/os-file-system-image09.png)

- **RAID 0 + parity disk** 
	- Byte 단위 분할 저장
	- 모든 disk에 입출력 부하 균등 분배
		- Parallel access, Performance 향상
- **한 disk에 장애 발생 시, parity 정보를 이용하여 복구**
	- 해밍코드
- **Write 시 parity 계산 필요** 
	- Overhead
	- Write가 몰릴 시, 병목현상 발생 가능.

## RAID 4

![](/assets/os-file-system-image10.png)

- **RAID 3과 유사, 단 Block 단위로 분산 저장** 
	- **독립된 access 방법**
	- **Disk간 균등 분배가 안될 수 도 있음**
	- 한 disk에 장애 발생 시, parity 정보를 이용하여 복구
	- Write 시 parity 계산 필요
		- Overhead / Write가 몰릴 시 병목현상 발생 가능
- **병목 현상으로 성능 저하 가능** 
	- 한 disk에 입출력이 몰릴때
- RAID3와 차이점은 바이트 단위가 아닌 Block 단위로 저장을 하여서 독립된 access를 할 수 있다.
	- RAID3는 A0에 접근 하기위해서 A0, A1, A2, A3를 다 access 해야한다.
	- RAID4는 블록 단위로 저장 하여서 A0에 access할 때 A0만 access 가능하다.
		- Disk간 균등 분배가 안될 수 있다.
			- EX) RAID4에서 A0, B0, C0, D0이 자주 필요한 상황이라면 블록0에만 access 된다.

## RAID 5

> **RAID3나 RAID4에서 패리티 디스크가 고장난다면 심각한 문제가 발생한다** 

![](/assets/os-file-system-image11.png)

- **RAID 4와 유사** 
	- 독립된 access 방법
- **Parity 정보를 각 disk들에 분산 저장** 
	- Parity disk의 병목현상 문제 해소
- **현재 가장 널리 사용 되는 RAID level중 하나** 
	- High performance and reliability

## RAID 6

- **RAID 5와 유사** 
- **P + Q 중복 방법** 
- Reed-Solomon 코드
	- 에러 정정 코드
