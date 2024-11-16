---
title: Javascript EventLoop
permalink: /javascript/event-loop/event-loop
---

# 이벤트 루프
1. 콜 스택에서 재귀 함수 실행
    - 재귀 함수가 계속해서 호출되면서 콜 스택이 채워지고, 끝까지 실행되어 콜 스택이 비워집니다.
2. 마이크로 태스크 큐의 작업 실행:
    - Promise의 `.then()`이나 `.catch()` 같은 마이크로 태스크가 콜 스택으로 이동하여 실행됩니다.
3. Animation Frames
	- ex) 사용자가 마우스로 글을 드래그 한다던지 그런것들
4. 매크로 태스크 큐의 작업 실행:
    - 그 다음, `setTimeout`이나 I/O 작업 같은 매크로 태스크가 콜 스택으로 이동하여 실행됩니다.
## 우선 순위
- Call Stack < Micro Task Queue < Animation Frames < Macro Task Queue
# Web API
- 네트워크 요청 (HTTP Requests):
    - `fetch()`, `XMLHttpRequest` 등과 같은 네트워크 요청은 Web API를 통해 관리됩니다.
    - 브라우저는 이러한 요청을 보내고 응답이 올 때까지 기다리는 동안, JavaScript 스레드를 차단하지 않고 다른 작업을 처리할 수 있게 합니다.
- 타이머 API:
    - `setTimeout()`, `setInterval()` 등은 Web API를 사용하여 일정 시간이 지난 후에 콜백 함수를 호출하도록 관리합니다.
    - 예를 들어, `setTimeout()`의 콜백은 지정된 시간이 지난 후 매크로 태스크 큐에 추가되고, 그 후에 이벤트 루프에 의해 실행됩니다.

# 로드맵

1. [[Execution Context]]

# Reference

- [링크1](https://developer.mozilla.org/ko/docs/Web/JavaScript/Event_loop) 
- [링크2](https://ko.javascript.info/event-loop) 
- [링크3](https://www.youtube.com/watch?v=8aGhZQkoFbQ) 
- [링크4](https://jakearchibald.com/2015/tasks-microtasks-queues-and-schedules/) 



