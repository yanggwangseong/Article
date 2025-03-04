---
title: Node.js 이벤트루프
permalink: 
tags:
  - Nodejs
  - event-loop
---

# 잘못된 개념

- 이벤트 루프는 자바스크립트 엔진 내부에 있다
- 이벤트 루프는 하나의 스택 또는 하나의 큐로만 동작한다
- 이벤트 루프는 여러개의 스레드에서 실행된다
- setTimeout은 일부 비동기 OS API와 관련있다
- setImmediate의 콜백은 작업 큐의 가장 첫번째에 위치한다


# 이벤트 루프 구조

![[Pasted image 20250227154433.png]]

- nextTickQueue와 microTaskQueue는 이벤트 루프의 일부가 아니다.
- 이벤트 루프 사이클과 독립적으로 실행되는 우선순위 높은 큐이다.
- 즉, 이벤트 루프의 다음 Phase로 넘어갈때 해당 Phase의 큐를 실행하기 전에 먼저 nextTickQueue와 microTaskQueue를 먼저 확인하고 있다면 실행한다.
- 이벤트 루프가 Phase를 진행 할때
	- `timers` → `I/O callbacks` → `idle/prepare` → `poll` → `check` → `close callbacks`
- 각 Phase 내부에서도 다시 `nextTickQueue` → `microTaskQueue` 실행 확인!
- 쉽게 이해하면 각각의 Phase는 macro TaskQueue인것이고 nextTickQueue와 microTaskQueue는 micro TaskQueue인것이다.
- 그래서 콜스택 -> micro taskqueue -> macro taskqueue로 실행되는 브라우저 이벤트루프 메커니즘과 비슷하다.


## Timer phase

## Pending i/o callback phase

## Idle, Prepare phase

## Poll phase

## Check phase

## Close callbacks

## nextTickQueue와 microTaskQueue


https://evan-moon.github.io/2019/08/01/nodejs-event-loop-workflow/#%EC%9D%B4%EB%B2%A4%ED%8A%B8-%EB%A3%A8%ED%94%84%EC%9D%98-%EC%9E%91%EC%97%85-%ED%9D%90%EB%A6%84


- [NodeConf EU deep dive libuv](https://www.youtube.com/watch?v=sGTRmPiXD4Y) 

# Reference

- https://evan-moon.github.io/2019/08/01/nodejs-event-loop-workflow/
- https://www.korecmblog.com/blog/node-js-event-loop
- https://nodejs.org/ko/learn/asynchronous-work/event-loop-timers-and-nexttick
