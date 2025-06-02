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

- 동시성(Concurrency)과 병렬성(Parallelism)
	- 동시성(Concurrency)란?
		- 여러 작업이 **논리적으로 동시에 실행되는 것처럼 보이는 성질** 실제로는 **하나의 코어에서 빠르게 번갈아가며 수행**되거나, 여러 코어에서 동시에 일어날 수도 있음
		- **논리적인 개념** 
	- 병렬성(Parallelism)
		- 여러 작업을 **물리적으로 동시에 실행하는 것** 즉, 여러 CPU 코어가 실제로 **각기 다른 작업을 동시에 처리** 
		- **물리적인 개념** 
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
- 세마포어, 뮤텍스, 스핀락, 모니터
- Classic 동기화 문제들
	- 3가지 문제
		- 유한 버퍼 문제 (The Bounded-Buffer Problem)
		- Readers-Writers 문제
		- 식사하는 철학자들 문제
	- 해결방법
		- 세마포어 해결 방법
		- 모니터 해결방법
- DeadLock
	- DeadLock이란?
		- 여러 프로세스나 스레드가 자원을 요청할 때 각 프로세스가 다른 프로세스가 보유한 자원을 기다리면서, 그 자원들이 동시에 다른 프로세스에 의해 요구되어 아무도 진행하지 못하고 영원히 기다리는 상태를 말합니다.
	- DeadLock 발생조건 4가지
		- mutual exclustion (상호배제)
		- hold-and-wait (점유하며 대기)
		- non preemption (비선점)
		- circular wait (순환 대기)
	- DeadLock 처리 방법
		- Deadlock Prevention (교착 상태 예방)
		- Deadlock Avoidance (교착 상태 회피)
		- Detection & Recovery (탐지와 회복)



---

## Reference


