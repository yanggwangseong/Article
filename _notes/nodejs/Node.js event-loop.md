---
title: Node.js event-loop
permalink: /nodejs/event-loop
---

# Node.js Event Loop

## Node.js 구조

이벤트 루프 순서
1. 이벤트 루프를 초기화합니다.
2. 제공된 입력 스크립트(JS파일)을 실행합니다.
3. 이벤트 루프가 시작되면 아래와 같은 순서로 각 단계들을 처리합니다.

- timers - setTimeout, setInterval로 예약된 콜백을 실행
- pending callbacks - TCP와 연결이 끊긴 경우 에러와 관련된 콜백들
- idle, prepare - 내부적으로 사용되는 단계. 
- poll - 새로운 I/O 이벤트를 가져오고 처리
- check - 여기서는 setImmediate()로 예약된 콜백들이 실행.
- close callbacks - 닫기 이벤트 콜백을 처리하는 단계, socket.on('close', ...)

> 각 단계에는 실행할 콜백의 FIFO큐가 있다.
> 큐가 소진되거나 콜백 제한에 도달하면 이벤트 루프가 다음 단계로 이동.

timers
- 사용자가 원하는 정확한 콜백 실행 시간이 아니라 제공된 콜백이 실행 될 수 있는 임계값을 지정한다.

# Reference
- [https://www.korecmblog.com/blog/node-js-event-loop](https://www.korecmblog.com/blog/node-js-event-loop) 
- https://www.digitalocean.com/community/tutorials/node-js-architecture-single-threaded-event-loop
- https://www.youtube.com/watch?v=P9csgxBgaZ8&t=1s
