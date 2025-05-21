---
title: concurrency control
permalink: /database/concurrency-control
tags:
  - post
layout: note
image: /assets/cat01.png
category: Database
description: Schedule이란 여러 transaction들이 동시에 실행될때 각 transaction에 속한 operation들의 실행 순서 Serial schedule란 transaction들이 겹치지 않고 한번에 하나씩 실행되는 schedule NonSerial schedule란transaction들이 겹쳐서(interleaving) 실행되는 schedule
---

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




---

## Reference

- 쉬운코드 concurrency control 1 https://www.youtube.com/watch?v=DwRN24nWbEc
- 쉬운코드 concurrency control2 https://www.youtube.com/watch?v=89TZbhmo8zk

***

## Series

[[_notes/study/database/Isolation level|Isolation level]] 
