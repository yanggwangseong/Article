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

> 타이머가 최소 힙으로 관리 될까?

1. [PriorityQueue](const timerListQueue = new PriorityQueue(compareTimersLists, setPosition);) 는 타이머 리스트들을 우선순위에 따라 관리하며, 해당 우선순위는 `compareTimersLists` 함수에 의해 결정 됩니다.
2. [compareTimersLists](https://github.com/nodejs/node/blob/6af5c4e2b4034a7721ebaffd939f14923f382ede/lib/internal/timers.js#L442) 
	- 두 타이머 리스트 `a` 와 `b` 의 만료시간 `expiry` 을 비교합니다.
		- `expiryDiff`가 음수이면 (`a.expiry < b.expiry`), 함수는 음수를 반환합니다.
		- `expiryDiff`가 양수이면 (`a.expiry > b.expiry`), 함수는 양수를 반환합니다.
		- `expiryDiff`가 0이면, `id`를 비교하여 순서를 결정합니다.
3. [PriorityQueue내부동작](https://github.com/nodejs/node/blob/6af5c4e2b4034a7721ebaffd939f14923f382ede/lib/internal/priority_queue.js#L13)  으로 요소들을 정렬하여 가장 우선위가 높은 요소를 빠르게 접근 할 수 있게 합니다. `compareTimersLists(a, b)`가 음수를 반환하면 `a`가 `b`보다 우선순위가 높다는 뜻입니다.
4. 타이머의 처리 순서
	- [타이머를 처리할 때 processTimers함수](https://github.com/nodejs/node/blob/6af5c4e2b4034a7721ebaffd939f14923f382ede/lib/internal/timers.js#L534)  의 `timerListQueue.peek()` 는 우선순위가 가장 높은 타이머 리스트를 반환 합니다. 이때, 만료 시간이 가장 작은 타이머 리스트가 반환 됩니다.

**결론적으로 만료 시간이 가장 작은 타이머 리스트가 우선적으로 처리되기 때문에, 최소 힙을 사용하는것이라고 볼 수 있다** 

### 그럼 왜 최소힙을 사용 할까?

- 타이머 시스템에서 가장 중요한것은 **가장 빨리 만료되는 타이머를 찾아 처리** 하는 것입니다.
- 여기서 최소힙은 **가장 작은값** (만료 시간이 가장 작은 타이머) 을 가진 요소를 루트에 둬서 **O(1)** 으로 가장 빨리 만료되는 타이머를 찾을 수 있게 됩니다.
- 삽입과 삭제는 `O(log n)` 시간이 소요 됩니다.

## Pending i/o callback phase

- 이 phase에서는 이벤트 루프의 `pending_queue` 에 들어 있는 콜백들을 실행한다.
- 해당 큐에 들어와 있는 콜백들은 현재 돌고 있는 루프 이전에 한 작업에서 이미 큐에 들어와있던 콜백들이다.
- 예시) TCP 핸들러 콜백 함수에서 파일에 뭔가를 썼다면 TCP 통신이 끝나고 파일 쓰기도 끝나고 나서 파일 쓰기의 콜백이 이 큐에 들어오는 것이다.
- 에러 핸들러 콜백도 `pending_queue` 로 들어오게 된다.

## Idle, Prepare Phase

- 두 Phase는 Node.js의 내부 동작을 위해 존재하는 phase이다.

## Poll Phase

- 일정시간동안 대기(blocking) 하면서 새로운 I/O operation이 들어오는지 `polling(watching)` 한다.



# Reference

- [https://www.korecmblog.com/blog/node-js-event-loop](https://www.korecmblog.com/blog/node-js-event-loop) 
- https://www.digitalocean.com/community/tutorials/node-js-architecture-single-threaded-event-loop
- https://www.youtube.com/watch?v=P9csgxBgaZ8&t=1s
- https://docs.libuv.org/en/v1.x/loop.html#c.uv_run
- https://nodejs.org/en/learn/asynchronous-work/event-loop-timers-and-nexttick#timers
- https://blog.insiderattack.net/event-loop-and-the-big-picture-nodejs-event-loop-part-1-1cb67a182810
- https://blog.insiderattack.net/handling-io-nodejs-event-loop-part-4-418062f917d1