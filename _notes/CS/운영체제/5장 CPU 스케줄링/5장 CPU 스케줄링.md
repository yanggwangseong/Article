---
title: 5장 CPU 스케줄링
permalink: /cs/os/operation-system/ch-5장 CPU 스케줄링
tags:
  - OS
layout: page
---
# CPU 스케줄링이 왜 필요할까?

- 코어가 하나인 시스템에서는 한순간에 오직 하나의 프로세스만 실행할 수 있습니다. 하지만, Multi Programming의 목적은 CPU 이용률을 최대화하여 항상 실행 중인 프로세스를 유지하는 데 있습니다. 즉, CPU가 idle(유휴) 상태에 놓이지 않도록 하는 것이 목표입니다.
- Multi Programming 환경에서 어떤 프로세스가 I/O 요청 등으로 인해 대기 상태로 전환되면, 운영체제는 CPU를 그 프로세스로부터 회수하여 다른 준비된 프로세스에 할당합니다. 이를 통해 대기 중인 프로세스가 발생할 때마다 다른 프로세스가 CPU를 사용할 수 있도록 하며, 이렇게 CPU 사용을 효율적으로 관리하는 것이 CPU 스케줄링입니다.
- 최신 운영체제에서는 실질적으로 프로세스가 아니라 kernel level thread를 스케줄 한다.
- 프로세스 스케줄링과 스레드 스케줄링 용어는 상호 교환적으로 사용된다.

# CPU 버스트, I/O 버스트, 타임 슬라이스

- 프로세스 실행은 CPU 실행과 I/O 대기의 Cycle로 구성된다.
	- CPU Burst : 프로세스가 CPU에서 연산을 수행하는 시간 구간을 말합니다.
	- I/O Burst : 프로세스가 입출력(I/O) 작업을 수행하기 위해 대기하는 시간 구간입니다.
	- Time Slice (타임 슬라이스)/ Time Quantum (타임 퀀텀)
		- 라운드 로빈(Round Robin) 스케줄링에서 사용되는, 프로세스가 CPU를 점유할 수 있는 최대 시간입니다.

# Preemptive와 Non-Preemptive

## Preemptive
- 특정 프로세스에 CPU를 할당한 상태라도 운영체제가 필요에 따라 강제로 CPU를 빼앗아 다른 프로세스에 할당할 수 있는 방식입니다.
- 프로세스가 실행 상태에서 준비완료 상태로 전환될 때 (예를 들어, 인터럽트가 발생할 때)
- 프로세스가 대기 상태에서 준비 완료 상태로 전환될 때 (예를 들어, I/O의 종료 시)

## Non-Preemptive
- 프로세스가 CPU를 할당받으면 그 프로세스가 작업을 완료하여 terminated 상태가 되거나, I/O 작업 등을 위해 스스로 CPU를 반납할 때까지 다른 프로세스가 CPU를 강제로 빼앗지 않는 방식입니다.
- 한 프로세스가 실행 상태에서 대기 상태로 전환될 때 (예를 들어, I/O 요청이나 자식 프로세스가 종료되기를 기다리기 위해 wait()를 호출할 때)
- 프로세스가 종료할 때

# Dispatcher

- CPU 코어의 제어를 CPU 스케줄러가 선택한 프로세스에 주는 모듈이다.
- 한 프로세스에서 다른 프로세스로 context-switch 하는 일
- User mode로 전환하는 일
- 프로그램을 다시 시작하기 위해서 사용자 프로그램의 적절한 위치로 jump(이동)하는 일

# Scheduling Criteria (스케줄링 기준)

## Turnaround time (총처리 시간)
- 준비 큐에서 대기한 시간, CPU에서 실행하는 시간, 그리고 I/O 시간을 합한 시간이다.
- CPU 버스트가 다 끝나고 나가는 시간을 Turn Around Time

## Waiting time (대기 시간)
- Ready Queue에서 대기하면서 보낸 시간의 합

## Response time (응답 시간)
- Ready Queue에 들어와서 처음으로 CPU를 얻기까지 걸린 시간.

## Utilization
- CPU 이용률
## throughput
- 단위 시간당 완료된 프로세스의 개수


# Scheduling Algorithms

## FCFS
- Non-Preemptive 스케줄링
- convoy effect : 모든 다른 프로세스들이 하나의 긴 프로세스가 CPU를 양도하기를 기다리는 것을 말한다.
	- 짧은 프로세스들이 먼저 처리되도록 허용될 떄보다 CPU와 장치 이용률이 저하되는 결과를 낳는다.


## SJF

- Preemptive
	- 더 짧은 CPU 버스트를 가진 프로세스가 오면 CPU를 빼앗아 CPU 버스트가 더 짧은 프로세스에게 할당
- Non-Preemptive
	- 더 짧은 CPU 버스트를 가진 프로세스가 오면 CPU를 빼앗지 않고 현재 실행중인 프로세스를 실행
- Preemptive SJF 스케줄링
	- SRTF(Shortest Remaining Time First) 스케줄링이라고도 부릅니다.

### 문제점

1. Starvation(기아 현상)
	- 실행 준비는 되어 있으나 우선순위가 더 높은 프로세스들로 인해서 CPU를 사용하지 못하는 프로세스는 CPU를 기다리는 현상
	- 해결방법
		- aging(노화) : 오랫동안 시스템에서 대기하는 프로세스들의 우선순위를 점진적으로 증가시킨다.
2. CPU Burst Time을 알 방법이 없다
	- 해결방법 : 과거의 CPU Burst Time을 통해서 예측 해서 선택 합니다.

### Priority Scheduling

- Preemptive
	- 우선 순위가 더 높은 프로세스가 오면 CPU를 빼앗아 우선순위가 더 높은 프로세스에게 할당
- Non-Preemptive
	- 우선 순위가 더 높은 프로세스가 오더라도 CPU를 빼앗지 않고 현재 실행중인 프로세스를 실행

#### 문제점

1. Starvation(기아 현상)
	- 실행 준비는 되어 있으나 우선순위가 더 높은 프로세스들로 인해서 CPU를 사용하지 못하는 프로세스는 CPU를 기다리는 현상
	- 해결방법
		- aging(노화) : 오랫동안 시스템에서 대기하는 프로세스들의 우선순위를 점진적으로 증가시킨다.

## Round Robin

- **Preemptive(선점형)** 이다
- 각 프로세스는 동일한 크기의 time quantum 또는 time slice를 가집니다.
- Ready Queue는 Circular Queue(원형 큐)로 동작한다.
- 새로운 프로세스들은 Ready Queue의 꼬리에 추가된다.
- CPU 스케줄러는 Ready Queue에서 첫번째 프로세스를 선택해 one time quantum 할당량 이후에 인터럽트를 걸도록 timer(타이머)를 설정한 후, 프로세스를 dispatch 한다.

1. 프로세스의 CPU Burst가 one time quantum보다 작을 수 있다.
	- 해당 경우에는 프로세스가 terminated 된 후 CPU를 반납 할 것이다.
2. 현재 실행중인 프로세스의 CPU Burst가 one time quantum보다 긴 경우, timer가 끝나고 운영체제에 인터럽트를 발생할 것이다. Context Switching 발생. 해당 프로세스는 Ready Queue의 꼬리에 추가된다.

### 성능

- time quantum의 크기에 매우 많은 영향을 받는다.
- time quantum이 매우 크다면 FCFS과 같다.
- time quantum이 매우 작다면 매우 많은 Context Switching이 발생하여 오버헤드를 일으킨다.
- turnaround time도 time quantum 크기에 좌우된다.

## Multilevel Queue Scheduling

- Priority Scheduling과 Round Robin의 개념을 결합한 경우다.
- 다단계 큐에서 우선순위에 따라 4개의 큐로 우선순위를 나누고 우선순위 순서대로 큐가 실행 된다.
	1. real-time processes (실시간 프로세스)
	2. system processes (시스템 프로세스)
	3. interactive processes (대화형 프로세스)
	4. batch processes (배치 프로세스)
- 우선순위가 높은 큐에 여러 프로세스가 있는경우 이때 라운드 로빈 순서로 실행된다.


## Multilevel Feedback Queue (MLFQ)

- MLQ 스케줄링을 사용하게 되면 문제가 우선순위가 높은 큐들이 계속 실행 될 경우에 우선순위가 낮은 큐들이 오랫동안 실행되지 못하고 있는 경우가 발생한다 (Starvation, 기아현상)
- MLFQ 알고리즘은 프로세스들을 CPU 버스트 성격에 따라서 구분한다. (aging, 노화)
	- 즉, 어떤 프로세스가 CPU 시간을 너무 많이 사용하면, 낮은 우선순위의 큐로 이동된다.
	- 낮은 우선순위의 큐에서 너무 오래 대기하는 프로세스는 높은 우선순위의 큐로 이동 할 수 있다.


# Thread Scheduling

- **최신 운영체제에서는 스케줄 되는 대상은 프로세스가 아니라 Kenel-Level Thread** 이다.

# Real-Time CPU Scheduling

- Soft Realtime
	- 중요한 실시간 프로세스가 스케줄 되는 시점에 관해 아무런 보장을 하지 않는다.
	- 오직 중요 프로세스가 그렇지 않은 프로세스들에 비해 우선권을 가진다는 것만 보장한다.
	- ex) 전화 통화 할때 전화 내용이 중간에 한 단어정도 빠지더라도 듣는데 큰 지장이 없다.
- Hard Realtime
	- 태스크는 반드시 마감시간까지 서비스를 받아야 하며 마감시간이 지난 이후에 서비스를 받는 것은 서비스를 전혀 받지 않는 것과 동일한 결과를 낳는다.
	- ex) 로켓을 발사한다고 가정 했을 때 좌표 계산은 정확한 시점에 완료되어야 하며, 지연되면 로켓이 잘못된 방향으로 이동하거나 목표 지점에 도달하지 못하게 됩니다.


# Reference

- [쉬운코드의 CPU스케줄러](https://www.youtube.com/watch?v=LgEY4ghpTJI&t=77s) 

