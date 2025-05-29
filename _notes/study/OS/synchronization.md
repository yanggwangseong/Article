---
title: synchronization
permalink: /os/synchronization
tags: 
layout: note
image: /assets/812.jpg
category: 
description: synchronization
---

## synchronization

**OS에서 등장하는 synchronization(동기화)과 concurrency control 개념을 확실하게 구분해야한다** 


---


- Race condition 이란?
	- critical section 이란?
	- critical section 해결을 위한 세가지 조건
		- mutual exclusion ( 상호 배제 )
		- progress ( 진행 )
		- bounded waiting (한정된 대기)
	- Busy waiting vs Block-wakeup vs Lock-Free vs Monitor
	- 소프트웨어적인 해결 방법
		- 피터슨 알고리즘(Peterson's Algorithm)
	- 하드웨어적인 해결 방법
		- Atomic Variable
			- 정수나 부울과 같은 기본 데이터 타입에 대해 원자적(atomic) 연산을 제공하는 변수
		- Test-and-Set
		- Compare and Swap,(CAS)
			- CAS의 사용
				- 락-프리(lock-free)와 wait-free 알고리즘 구현에 사용된다.
			- CAS 기반의 락-프리 알고리즘
				- "충돌이 드물 것"이라고 가정하고, 락을 걸지 않고 **낙관적으로 처리**함.
				- 어떻게 구현?
					- CPU의 **원자적 CAS 명령어**를 사용하여 메모리 값을 비교-갱신
				- 왜 사용?
					- 멀티스레딩 환경에서 동기화 비용을 줄이기 위해
				- EX) Java의 `AtomicInteger`, Redis 분산락에서 Redlock 구현 시 `SET NX PX` 방식
- 세마포어, 뮤텍스, 모니터, 스핀락
- Classic 동기화 문제들
	- 3가지 문제
		- 유한 버퍼 문제 (The Bounded-Buffer Problem)
		- Readers-Writers 문제
		- 식사하는 철학자들 문제
	- 해결방법
		- 세마포어 해결 방법
		- 모니터 해결방법
- DeadLock



---

## Reference


