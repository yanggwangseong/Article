
1. 고정길이 윈도 방식 문제 (Late Limit 구현 방법)
2. 근데 고정길이 윈도방식 하면 바로 이전 윈도 종료 시점과 이후 윈도 시작 시점에 몰려들어오면 어떻게 할것인가?
3. 로그 기반 처리로 구현
4. 근데 로그 기반으로 처리하면 메모리 사용량 감당 가능하냐고 할건가?


## 1. 고정 길이 윈도 방식의 문제

고정 윈도는 구조적으로 **시간을 일정 간격으로 단순히 나누는 방식**이라 다음과 같은 근본적인 문제가 발생합니다:

### ❗ 주요 문제
- **경계 문제 (Boundary problem)**
    - 이벤트가 윈도 경계 시점(예: 12:00:00, 12:01:00)에 걸쳐 들어오면 정확한 집계가 어려워짐.
- **Late data 문제**
    - 이미 닫힌 윈도에 속하는 늦은 이벤트는 집계에 반영 불가.
- **하드 컷오프(Hard cutoff)**
    - `Late Limit` 같은 유예 기간(grace period)이 없으면 늦게 도착한 이벤트는 그냥 무시됨.

> ✅ 예: `2025-06-05 12:00:00`에 윈도가 닫히면, `12:00:01`에 도착한 해당 윈도 이벤트는 폐기됨.

## 2. 경계 몰림(Traffic Spike at Boundary)의 문제

말씀하신 이 두 번째 질문은 실무적으로 아주 중요합니다.

> ❓ "고정 길이 윈도 방식에서 바로 직전 윈도 종료 시점과 다음 윈도 시작 시점에 이벤트가 몰리면 어떻게 할것인가?

### 🔥 발생 원인

- 시스템 또는 사용자가 주기적으로 보내는 이벤트 (ex: 크론 잡, 센서 신호, 사용자 동기화 등)
- 트래픽이 **정각**, **1분 간격**, **10초 간격**에 집중

### 💣 문제

- **이전 윈도**는 과밀 → 처리 지연 / 유실 가능
- **다음 윈도**는 비어 있음 → 통계적 왜곡
- Late 처리 없이 하드 컷오프면 **데이터 유실**
- 타임존 오차, 클럭 지연, 네트워크 지연까지 겹치면 심각

## 3. 해결 방법

| 전략                     | 설명                                                                   |
| ---------------------- | -------------------------------------------------------------------- |
| **Grace Period 추가**    | Kafka Streams 등에서 `grace(period)` 설정 → 닫힌 윈도도 일정 시간 유예하며 late 이벤트 수용 |
| **Watermark 기반 지연 허용** | Apache Flink, Beam 등에서는 watermark를 기준으로 윈도 닫기 시점 결정                  |
| **Sliding Window 도입**  | 윈도가 겹쳐지므로 경계 근처 이벤트가 중복되면서 집계 보완 가능                                  |
| **Session Window 전환**  | 유저 세션, 이벤트 덩어리를 기준으로 유동적인 윈도 생성하여 경계 문제 해소                           |
| **Duplicate Handling** | late data 처리 시 deduplication 전략 필요                                   |

|상황|처리 방법|
|---|---|
|고정된 시간 단위로 집계 필요|Fixed Window + Grace|
|경계 집중 트래픽 존재|Sliding Window or Session Window로 전환|
|유입 지연 허용 필요|Watermark 또는 Grace로 유예 시간 부여|
|정확한 집계 필요|Deduplication, checkpointing, 정확한 타임스탬프 기준 필요|


## 로그 기반 처리 방법

### 1. 로그 기반 이벤트 스트림 시스템 (Kafka 등)에서의 Late Limit 처리

Kafka, Kinesis 등 **로그 스트리밍 시스템**을 기반으로 처리하는 경우에는 다음과 같은 방식으로 Late 이벤트 제한(Late Limit)을 구현할 수 있습니다:

#### Event Timestamp + Watermark 기반 처리

- 각 이벤트에는 `event_time` 필드가 있고, 처리 시스템(Flink, Kafka Streams 등)은 `processing_time`과 비교하여 **얼마나 늦은 이벤트인지 판단**합니다.
    
- 예: 이벤트가 `2024-06-04T12:00:00`이고 현재 watermark가 `2024-06-04T12:05:00`이면, 이 이벤트는 5분 Late
    

✅ 처리 조건:

- `allowed_lateness` (예: 2분) 설정
- `lateness > allowed_lateness`인 경우 이벤트 **드롭**


## Reference

- [Rate Limit 알고리즘 여러 종류](https://news.hada.io/topic?id=14869) 
- **GCRA 알고리즘**: rate limiting에 더 나은 알고리즘이라고 생각함. 더 널리 알려지고 사용되었으면 좋겠음.
	- [GCRA 구현 예제](https://medium.com/smarkets/implementing-gcra-in-python-5df1f11aaa96)
	- [GCRA 위키피디아](https://en.m.wikipedia.org/wiki/Generic_cell_rate_algorithm)
