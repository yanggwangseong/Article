---
title: Lock
permalink: /study/Lock
tags: 
layout: note
image: /assets/cat01.png
---
![](/assets/812.jpg)

## Lock

**Lock이란?**

데이터마다 락이 있어서 그 데이터를 변경하거나 읽으려면 그 락을 취득을 해야하는데 만약 락을 취득하지 못하면 그 락을 취득할 때까지 기다려야 한다.

즉, OS에서의 Lock개념이 맞고 Race Condition 문제를 해결하기 위한 방법이다.



---

## 1. Lock

### 1.1 Lock이 왜 필요할까?

- 같은 데이터에 또 다른 read / write가 있다면 예상치 못한 동작을 할 수 있다.

### 1.2 write-lock (exclusive lock)

- read / write 할때 사용한다.
- 다른 tx가 같은 데이터를 read / write 하는 것을 허용하지 않는다.

### 1.3 read-lock (shared lock)

- read 할 때 사용한다.
- 다른 tx가 같은 데이터를 read 하는 것은 허용한다.

### 1.4 lock 호환성

![](/assets/lock01.png)

- **CASE1 허용됨**
	- 어떤 트랜잭션 A가 **read-lock**을 가지고 있는데 같은 데이터에 대해서 또 다른 트랜잭션 B가 **read-lock**을 획득하려고 시도할때
- **CASE2 허용안됨**
	- 어떤 트랜잭션 A가 **write-lock**을 가지고 있는데 같은 데이터에 대해서 또 다른 트랜잭션 B가 **read-lock**을 획득하려고 시도할때
- **CASE3 허용안됨**
	- 어떤 트랜잭션 A가 **read-lock**을 가지고 있는데 같은 데이터에 대해서 또 다른 트랜잭션 B가 **write-lock**을 획득하려고 시도할때
- **CASE4 허용안됨**
	- 어떤 트랜잭션 A가 **write-lock**을 가지고 있는데 같은 데이터에 대해서 또 다른 트랜잭션 B가 **write-lock**을 획득하려고 시도할때


![](/assets/lock02.png)

예시) lock으로만은 serializable을 보장할 수 없을 수 도 있다
Nonserializable
serializable
(해당 케이스 그림을 그려가며 이해가 필요)

- 2PL protocol (two-phase locking)
	- tx에서 모든 locking operation이 최초의 unlock operation보다 먼저 수행되도록 하는것
	- serializable가 보장된다.
- Expanding phase (growing phase)
	- lock을 취득하기만 하고 반환하지 않는 phase
- Shrinking phase (contracting phase)
	- lock을 반환만 하고 취득하지는 않는 phase


---

## Reference

- 쉬운코드 LOCK을 활용한 concurrency control https://www.youtube.com/watch?v=0PScmeO3Fig
