---
title: Node.js event-loop
permalink: /nodejs/event-loop
---

## Node.js Event Loop 란?

1. 이벤트 루프는 JS엔진의 일부이다. 이벤트 루프는 단지 JS 코드를 실행하기 위해 JS엔진을 이용하는거 뿐이며 실제로 V8 엔진에는 이벤트 루프를 관리하는 코드가 없다. Node.js나 브라우저가 이벤트 루프를 담당하는것이다. [Node.js에서 이벤트 루프가 구현된 코드](https://github.com/nodejs/node/blob/c61870c376e2f5b0dbaa939972c46745e21cdbdd/deps/uv/src/unix/core.c#L369) 
2. 이벤트 루프가 작동하는 과정은 여러 개의 큐를 사용하는 복잡한 과정이다.
3. 이벤트 루프는 **메인 싱글 스레드로 처리된다** 
- 이벤트 루프란 Node.js가 싱글 스레드로 동작함에도 불구하고 **I/O** 동작들을 **non-blocking** 방식으로 처리할 수 있게 해주는 녀석이다.
- 이벤트 루프는 `libuv` 라이브러리를 사용해 다수의 비동기 작업을 스케줄링 합니다. 이를 통해 I/O 작업이나 타이머, 콜백 등이 관리 됩니다.
- 주로 operation들을 커널에 맡기는 방식으로 진행 하는데, 대부분의 현대 운영체제들은 멀티 스레드이므로 백그라운드에서 여러 operation들을 동시에 실행시키는 것이 가능하다.
- 이렇게 백그라운드에서 operation을 처리하다가 해당 작업을 완료하면 커널이 Node.js에게 작업이 완료되었다고 알리고, 알림을 받은 Node.js는 적절한 핸들러(콜백)를 `poll queue` 에 등록하여 이 콜백을 (추후에) 실행한다.

## Event Loop 주요 단계

> 실제로는 7~8 단계가 있지만, Node.js에서 실제로 사용하는 단계는 아래 6가지 단계를 통해 작업을 처리합니다. <br>
> 각 단계는 일정한 작업을 수행하며 순환 구조로 실행 됩니다.

![](/assets/image09.png)

### Phase (페이즈)

- 이벤트 루프의 각 단계를 `phase` 라고 하며, 각각의 phase마다 콜백을 실행 할 **FIFO 구조의 큐** 를 가지고 있어서 이벤트 루프가 각 phase에서 수행해야 할 operation들을 수행한 후 해당 phase 큐에 있는 모든 콜백 (혹은 일정한 수의 콜백)을 실행한다.
- 모든 콜백을 처리하고 나면 이벤트 루프는 다음 phase로 이동하여 위 동작들을 반복한다. 이때 어떤 phase에서 다음 phase로 넘어가는 과정을 **trick** 이라고 한다.
 
1. **Timers**
	- `setTimeout` 과 `setInterval` 을 사용하는 타이머 콜백이 실행 됩니다.
	- 타이머의 실행은 대기 시간보다 **더 긴 시간이 소요될 수 있음** 을 주의해야 합니다.
2. **Pending Callbacks** 
	- 일부 I/O 작업의 콜백이 실행 됩니다. 예를 들어, TCP 오류 핸들러와 같은 작업들이 이 단계에서 실행됩니다.
3. **Idle, Prepare**
	- 내부적으로 Node.js에서 사용하는 단계로, 주로 이벤트 루프가 **다음 작업을 준비** 하는 단계 입니다.
4. **Poll** 
	- 대기 중인 **I/O 이벤트를 처리** 하는 단계입니다. 대부분의 비동기 콜백이 여기서 실행됩니다.
	- 이 단계는 **이벤트가 있으면 처리하고, 없으면 대기** 하는 특성이 있습니다.
5. **Check**
	- `setImmediate` 콜백이 이 단계에서 실행 됩니다. 이는 Poll 단계 이후에 실행되므로, 빠른 실행이 보장됩니다.
6. **Close Callbacks** 
	- `close` 이벤트가 발생한 콜백이 실행됩니다. 예를 들어, 소켓 연결 종료 시 호출되는 핸들러가 여기서 실행 됩니다.


![](/assets/image10.png)

- 각 Phase들은 **각자 하나의 큐** 를 가지고 있으며, JS 실행은 이 Phase들중 `Idle, prepare` 페이즈를 제외한 어느 단계에서나 할 수 있다.
- `nextTickQueue` 와 `microTaskQeue` 를 볼 수 있는데, 이 큐들은 이벤트 루프의 일부가 아니며, 이 큐들에 들어 있는 작업 또한 어떤 Phase에서든 실행 될 수 있다.
	- **이 큐들에 들어 있는 작업은 가장 높은 실행 우선 순위를 가지고 있다** 

## Timer phase

- `Timer phase` 는 이벤트 루프의 시작을 알리는 페이즈이다.
- 이 페이즈가 가지고 있는 큐에는 `setTimeout` 과 `setInterval` 과 같은 타이머들의 콜백을 저장하게 된다.
- 이 페이즈에서 바로 **타이머들의 콜백** 이 큐에 들어가는것은 아니다.
- `타이머` 들을 `min-heap` 으로 유지하고 있다가 실행될 때가 된 타이머들의 콜백을 큐에 넣고 실행하는 것이다.
- 기술적으로 **poll Phase** 단계는 타이머가 실행되는 시기를 제어합니다.

1. `Timer Phase` 는 [min-heap](https://github.com/nodejs/node/blob/6af5c4e2b4034a7721ebaffd939f14923f382ede/deps/uv/src/timer.c#L149)  을 이용해서 타이머를 관리한다. 이를 통해 실행 시간이 가장 이른 타이머를 효율적으로 찾을 수 있다.
2. `Timer Phase` 는 `setTimeout(fn, 1000)` 을 호출했다고 하더라도 정확하게 `1s` 가 지난후에 `fn` 이 호출됨을 보장하지 않는다.
	- `1s` 가 흐르기전에 실행되지 않는 것을 보장 합니다.
	- `1초 이상` 의 시간이 흘렀을 때 `fn` 이 실행됨을 보장 합니다.
3. 큐에 있는 모든 작업을 실행하거나 **시스템의 실행 한도** 에 다다르면 다음 페이즈인 `Pending Callbacks Phase` 로 넘어갑니다.

### 그럼 왜 최소힙을 사용 할까?

- 타이머 시스템에서 가장 중요한것은 **가장 빨리 만료되는 타이머를 찾아 처리** 하는 것입니다.
- 여기서 최소힙은 **가장 작은값** (만료 시간이 가장 작은 타이머) 을 가진 요소를 루트에 둬서 **O(1)** 으로 가장 빨리 만료되는 타이머를 찾을 수 있게 됩니다.
- 삽입과 삭제는 `O(log n)` 시간이 소요 됩니다.

## Pending i/o callback phase

- 이 phase에서는 이벤트 루프의 `pending_queue` 에 들어 있는 콜백들을 실행한다.
- 해당 큐에 들어와 있는 콜백들은 현재 돌고 있는 루프 이전에 한 작업에서 이미 큐에 들어와있던 콜백들이다.
- **대부분의 Phase는 시스템의 실행 한도의 영향을 받는다. 시스템의 실행 한도 제한에 의해 큐에 쌓인 모든 작업을 실행하지 못하고 다음 페이즈로 넘어갈 수도 있다. 이때 처리하지 못하고 넘어간 작업들을 쌓아놓고 실행하는 Phase** 다.
- 예시) TCP 핸들러 콜백 함수에서 파일에 뭔가를 썼다면 TCP 통신이 끝나고 파일 쓰기도 끝나고 나서 파일 쓰기의 콜백이 이 큐에 들어오는 것이다.
- 에러 핸들러 콜백도 `pending_queue` 로 들어오게 된다.

## Idle, Prepare Phase

- 두 Phase는 Node.js의 내부 동작을 위해 존재하는 phase이다.

## Poll Phase

- 새로운 I/O 이벤트를 다루며 `watcher_queue` 의 콜백들을 실행한다.
- `watcher_queue` 에는 `I/O` 에 대한 거의 모든 콜백들이 담긴다.
- `setTimeout` , `setImmediate` , close 콜백등을 제외한 **모든 콜백** 이 여기서 실행 된다.

> 예시

- 데이터베이스에 쿼리를 보낸 후 결과가 왔을 때 실행되는 콜백
- HTTP 요청을 보낸 후 응답이 왔을 때 실행되는 콜백
- 파일을 비동기로 읽고 다 읽었을 때 실행되는 콜백

### Poll Phase가 콜백을 관리하는 방법

#### I/O 이벤트의 처리 방식

- Poll Phase는 `watcher_queue` 에 담긴 콜백을 관리합니다.
- I/O 이벤트는 타이머와 달리 **큐에 담긴 순서대로 콜백이 실행** 된다는 보장이 없습니다.
	- 예를 들어, 데이터 베이스에 A, B 쿼리를 순서대로 날렸더라도 응답은 B, A 순서로 올 수 있습니다.
	- 따라서 **큐에 담긴 순서와 상관없이** 먼저 응답이 오는 B를 바로 실행하는 것이 올바른 방식입니다.

#### 타이머와의 차이점

- 타이머는 특정 실행 시간을 가지고 있어 Event Loop가 타이머 완료 여부를 알 수 있지만, **I/O 이벤트는 Event Loop가 단독으로 완료 여부를 알 수 없습니다** 
- 이런 문제를 해결하기 위해 `Poll Phase` 는 단순한 콜백 큐를 사용하지 않고 다른 구조를 이용합니다.

#### watcher_queue와 FD(File Descriptor)

- Event Loop는 n개의 열린 소켓과 n개의 완료되지 않은 요청을 관리합니다.
- 이러한 소켓들에 대해 `watcher` 라는 객체를 관리하고, 이 **watcher는 소켓과 메타 데이터** 를 포함 합니다.
- 각 `watcher` 는 **FD(File Descriptor)** 를 가지고 있으며, 이는 **네트워크 소켓, 파일 등** 을 가리킵니다.
- 운영체제가 특정 FD가 준비되었음을 알리면, Event Loop는 해당 `watcher` 를 찾아 그에 해당하는 콜백을 실행하게 됩니다.

#### Poll Phase의 시스템 한도 영향

- Poll Phase도 시스템 실행 한도의 영향을 받습니다. 즉, 시스템 리소스 및 성능에 따라 이 단계의 처리 시간이 제한될 수 있습니다.


### Poll Phase Blocking

- **Poll Phase** 는 이전의 타이머나 Pending Callbacks Phase 와는 다르게 **자신의 작업 큐가 비었을 경우 대기** 할 수 있습니다. 해당 과정은 다음 조건들에 따라 결정 됩니다.

1. **Poll Phase의 기본 행동** 
	- Poll Phase에 **대기 중인 I/O 요청이 없다거나** 아직 **응답이 오지 않았다면** , `watcher_queue` 의 상태에 따라 Poll Phase에서 **잠시 대기** 합니다.
	- 다른 Phase와 달리, Poll Phase는 **다음 Phase로 넘어가거나, 잠시 대기 후 다시 Poll Phase로 돌아 오는 경우에 실행할 수 있는 작업이 있는지** 를 고려합니다.
2. **Poll Phase에서 대기하는 시간 (timeout) 결정 조건** 
	- 다음 상황에서는 **timeout이 0이되어** , 즉시 다음 Phase로 넘어 갑니다.
	- 이벤트 루프가 끝난 경우
	- 처리할 비동기 작업이 없는 경우 (즉, 당장 처리해야 할 I/O 요청이 없고 기다리는 요청도 없는 경우)
	- 

# Reference

- [https://www.korecmblog.com/blog/node-js-event-loop](https://www.korecmblog.com/blog/node-js-event-loop) 
- https://www.digitalocean.com/community/tutorials/node-js-architecture-single-threaded-event-loop
- https://www.youtube.com/watch?v=P9csgxBgaZ8&t=1s
- https://docs.libuv.org/en/v1.x/loop.html#c.uv_run
- https://nodejs.org/en/learn/asynchronous-work/event-loop-timers-and-nexttick#timers
- https://blog.insiderattack.net/event-loop-and-the-big-picture-nodejs-event-loop-part-1-1cb67a182810
- https://blog.insiderattack.net/handling-io-nodejs-event-loop-part-4-418062f917d1
- https://docs.libuv.org/en/v1.x/design.html