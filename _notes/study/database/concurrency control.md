---
title: concurrency control
permalink: /study/concurrency-control
tags: 
layout: page
image: /assets/cat01.png
---

## concurrency control

---

### 📚 Contents

1. 개요
2. 문제
3. 문제 해결 및 결과

---

## Lost Update

## Schedule

- Schedule이란
	- 여러 transaction들이 동시에 실행될때 각 transaction에 속한 operation들의 실행 순서
	- **각 transaction 내의 operations들의 순서는 바뀌지 않는다** 

## Serial schedule

transaction들이 겹치지 않고 한번에 하나씩 실행되는 schedule

### Serial schedule 성능


## NonSerial schedule

transaction들이 겹쳐서(interleaving) 실행되는 schedule





---

## Reference

- 쉬운코드 concurrency control 1 https://www.youtube.com/watch?v=DwRN24nWbEc
- 쉬운코드 concurrency control2 https://www.youtube.com/watch?v=89TZbhmo8zk

