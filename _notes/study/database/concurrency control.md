---
title: concurrency control
permalink: /database/concurrency-control
tags: []
layout: note
image: /assets/812.jpg
category: 
description: Schedule이란 여러 transaction들이 동시에 실행될때 각 transaction에 속한 operation들의 실행 순서 Serial schedule란 transaction들이 겹치지 않고 한번에 하나씩 실행되는 schedule NonSerial schedule란transaction들이 겹쳐서(interleaving) 실행되는 schedule
---

![](/assets/812.jpg)

## 1. concurrency control

concurrency control이란 ㄹㄹㄹㄹㄹㄹ뭐라뭐라



---

## 2. Lost Update

Lost Update란 

## 3. Schedule

- Schedule이란
	- 여러 transaction들이 동시에 실행될때 각 transaction에 속한 operation들의 실행 순서
	- **각 transaction 내의 operations들의 순서는 바뀌지 않는다** 

## 3.1 Serial schedule

transaction들이 겹치지 않고 한번에 하나씩 실행되는 schedule

### 3.1.1 Serial schedule 성능


## 3.2 NonSerial schedule

transaction들이 겹쳐서(interleaving) 실행되는 schedule

### 3.2.1 NonSerial schedule 성능



## 4. 정리

a schedule -> equivalent -> a serial schedule -> serializable

어떤 schedule이 임의의 serial schedule과 동일(equivalent) 하다면 이 schedule이 serializable 하다고 말한다.

a schedule -> conflict equivalent -> a serial schedule -> conflict serializability

어떤 schedule이 어떤 serial schedule과 conflict equivalent하다면 이 schedule이 conflict serializability 하다고 말한다.

a schedule -> view equivalent -> a serial schedule -> view serializable

concurrency control -> makes -> any schedule -> serializable

어떤 스케줄이라도 serializable하게 만드는게 concurrency control 이다
이것과 밀접한 관계가 있는 트랜잭션의 속성이 Isolation이다

Isolation을 너무 엄격하게 serializable을 추구하게 되면 성능이 저하되게 된다.

동시성이 떨어지게 된다.

Isolation level -> provide -> relaxed -> isolation

Isolation을 조금 완화 시켜서(relaxed) 개발자들이 컨트롤 할 수 있게 제공 하는게 Isolation level이다.

롤백을 했을때 중요한 개념이 recoverability이다.


## recoverable schedule

## cascadeless schedule

## strict schedule




---

## Reference

- [쉬운코드 concurrency control 1](https://www.youtube.com/watch?v=DwRN24nWbEc) 
- [쉬운코드 concurrency control 2](https://www.youtube.com/watch?v=89TZbhmo8zk) 

