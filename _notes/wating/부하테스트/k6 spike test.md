---
title: mokakbab-issue
permalink: /wating/k6-spike-test
---

- [k6 공식문서 spike 테스트](https://grafana.com/blog/2024/01/30/spike-testing/) 
- [그라파 공식문서 부하 테스트 종류 정리](https://grafana.com/load-testing/) 


# Plateau(고원지대) 와 RPS

- Plateau란 높은 트래픽이 발생 했을 때 시스템이 처리하는 트래픽(RPS)가 일정하게 유지되지만 대신 에러율과 응답시간이 증가하는 상태 입니다.

## 질문

- Plateau를 찾을 때 api의 파라미터는 고정된 파라미터를 사용하는게 맞을까?
- 높은 response data사이즈로 인해서 클라우드 아웃바운드 네트워크 초과 과금이 발생 할것 같은데 어떻게 하면 좋을까요?
## Plateau 확인 지표

- 처리량 유지 : RPS(Requests Per Second) 또는 Throughput이 일정하게 유지 됩니다.
- 에러율 증가 : HTTP 에러율이 증가 합니다.
- 응답 시간 증가 : P95, P99 평균 응답 시간이 점진적으로 늘어남.
- 리소스 고갈 : CPU, 메모리, I/O 대역폭 등 리소스가 한계에 도달한 상태.

## Plateau를 찾기 위해서는 그라파나가 필요하다

### 그라파나 대시보드 설정

- 응답 시간(P50, P90, P99)
- 에러율(HTTP 에러율 비율)
- RPS(Requests Per Second)

#### 3. 고원지대 탐지 기준

Grafana에서 다음 패턴을 관찰하며 고원지대를 탐지합니다:

1. **처리량(RPS)**:
    - 고원지대에서는 처리량이 일정하게 유지.
    - 부하를 더 증가시켜도 RPS가 증가하지 않음.
2. **응답 시간 증가**:
    - P95, P99 응답 시간이 급격히 증가하거나, 평균 응답 시간이 선형적으로 증가.
    - 일반적으로 특정 지점에서 비례적으로 증가하는 경향.
3. **에러율 상승**:
    - HTTP 5xx 에러 비율이 급증.
    - 이 시점이 시스템의 병목 또는 한계를 나타냄.


## 의문점

- 테스트를 진행하기 위햐서 고정된 파라미터를 사용하는게 좋을까?

# Load test type

- [k6 Spike testing](https://grafana.com/docs/k6/latest/testing-guides/test-types/spike-testing/) 

- Smoke testing
- Average-load testing
- Stress testing
- Soak testing
- Spike testing
- Breakpoint testing


# spike test

- 테스트가 너무 관대한 것 같아요. 최대치를 봐야해서 그냥 spike 치면 언제부터 고원지대가 생기는지 볼 수 있도록 세팅하는 게 좋을 것 같습니다.
- 스파이크 테스트로 변경

- `Dockerfile.clinic-flame` [브랜치 수정](https://github.com/f-lab-edu/Mokakbab/pull/69) 
- [k6 spike 테스트 비기너 블로그](https://grafana.com/blog/2024/01/30/spike-testing/) 

## 고려 사항

스파이크 테스트를 준비할 때 다음 사항을 고려하세요.

- **이 테스트 유형의 핵심 프로세스에 집중하세요.**  
    트래픽 급증이 다른 테스트 유형과 같은 프로세스 또는 다른 프로세스를 트리거하는지 평가하세요. 그에 따라 테스트 로직을 만드세요.
- **테스트가 종종 끝나지 않습니다.**  
    이런 시나리오에서는 오류가 흔합니다.
- **실행, 조정, 반복.**  
    시스템이 스파이크 이벤트의 위험에 처해 있을 때, 팀은 스파이크 테스트를 실행하고 시스템을 여러 번 조정해야 합니다.
- **모니터.**  
    백엔드 모니터링은 이 테스트의 성공적인 결과를 위해 필수입니다.



# 플레임 그래프

- [flamebearer](https://github.com/mapbox/flamebearer?tab=readme-ov-file) 
- [Flame Graphs](https://www.brendangregg.com/flamegraphs.html) 


스파이크 테스트의 핵심은 **“어디까지 버틸 수 있는지, 그리고 언제부터 빠르게 응답이 느려지거나 오류가 급증하는지”** 를 찾아내는 데 있습니다.

- **고원 지대(Plateau)**: 갑작스러운 트래픽 증가 이후에도 어느 정도 수준까지는 처리가 가능하지만, 그 수준을 넘어서면 장애(오류, 타임아웃 등)가 일어나는 지점이 생기죠.
- 이 지점을 찾고, 시스템을 튜닝하거나 스케일링해서 해당 ‘고원 지대’를 최대한 높여주는 것이 스파이크 테스트의 주요 목적이라고 할 수 있습니다.

즉, **스파이크 테스트는 단순한 ‘과부하 테스트’가 아니라, 짧은 시간에 극단적인 상황을 만들고 그때부터 언제 ‘한계’가 오는지** 확인하는 과정입니다.


# 순서

1. `spike` 테스트를 통해서 어디까지 지점까지 처리가 가능한지 고원지대를 찾는것이다.
	- 고원지대라는것이 결국 시스템이 잘 돌아가는 RPS를 찾는게 아니네...
2. 즉, spike 테스트를 그냥 과부하가 걸리게 던져야한다.
3. `flamebearer` 를 통해서 플레임 그래프 만들고 이슈 부분 찾기.

- 오케이 node --prof로 프로젝트 돌리고 난 후에 스파이크 테스트 치고 오류나 타임아웃이 당연히 생기는거지 그대로 끝날때까지 둔다음에
- flamebearer를 통해서 플레임 그래프 시각화 한다음에 분석 개선점 찾고 개선 개선 다시 테스트 개선
- AWS RDS 성능 개선 도우미 활용
- Amazon CloudWatch 활용

# 클라우드 환경

## 1. AWS 기본 모니터링 도구 활용

### 1) Amazon CloudWatch (기본 지표)

- **Free Tier 한도**:
    - 10개 지표와 10개 알람 등에 대해 일정 수준까지는 무료로 이용 가능합니다.
    - EC2, ECS, RDS 각각에서 제공되는 **기본 메트릭**(CPU, Network In/Out, Free Storage Space 등)은 별도 과금 없이 확인 가능합니다.
- **어떻게 사용하나?**
    - ECS(Task, Service), EC2(Instance) 차원의 **NetworkIn, NetworkOut** 메트릭을 모니터링
    - RDS(DBInstance)의 CloudWatch 지표(Free Tier에서 CPUUtilization, DatabaseConnections, NetworkReceive, NetworkTransmit 등)를 확인
    - 어느 시점에 **네트워크 사용량(Throughput)이 급증**하거나, **DB 접속 수가 급증**하는지 추적 가능

### 3) AWS X-Ray (분산 트레이싱)

- **Free Tier 한도**:
    - X-Ray는 월 **100,000 트레이스 처리**(또는 5백만 트랜잭션?)까지 무료로 이용 가능(정책이 바뀌거나 지역별로 다를 수 있으니 공식 문서 참고).
- **어떻게 네트워크 I/O 병목을 보나?**
    - 어플리케이션(컨테이너) → RDS 호출 구간이 **“DB 쿼리 지연”** 때문인지, **“네트워크 지연”** 때문인지, 혹은 **다른 외부 API** 때문인지 트레이스 맵으로 시각화 가능
    - 실제로 “RDS 호출이 N ms 걸린다”는 트레이스 결과를 보고, DB 레벨 문제인지 네트워크 레이턴시 문제인지 가늠할 수 있습니다.

## 3. RDS Performance Insights

- RDS를 **MySQL, PostgreSQL** 등으로 쓰고 있다면, **Performance Insights**에서 DB 차원 지표(쿼리 시간, Wait 이벤트, CPU/메모리, 세션 수 등)를 무료로 확인할 수 있습니다(7일 기본 보관).
- 네트워크 자체보다는 **쿼리 지연**이나 **DB 내부 병목**을 파악하는 데 유용합니다.
- **Free Tier** 환경에서도 MySQL/PostgreSQL RDS 인스턴스가 t2.micro/t3.micro라면 Performance Insights를 활성화할 수 있고, **7일 이력**은 추가 과금 없이 볼 수 있는 경우가 많습니다.


1. **CloudWatch 지표/알람**
    
    - ECS에서 **NetworkIn, NetworkOut** 모니터링 → 특정 시점에 갑자기 Spike가 있는지
    - RDS에서 **NetworkReceive, NetworkTransmit** 지표 (각각 MB/s) → DB와의 통신량이 과도하게 늘었는지
    - (필요 시) CloudWatch Container Insights에서 **각 컨테이너별 네트워크 지표**를 상세하게 볼 수도 있음
2. **X-Ray(또는 OpenTelemetry) 트레이싱**
    
    - 요청 단위로 어디에서 지연이 발생하는지 추적
    - DB 호출에 대한 응답 시간이 비정상적으로 길어지면, 그것이 DB 쿼리 자체 문제인지, 네트워크 지연인지, RDS IOPS 한계인지 등을 추적(Performance Insights와 함께 확인)
3. **부하 테스트 + 로그 분석**
    
    - k6, Locust 등의 툴로 ECS 서비스에 부하를 주고, CloudWatch 혹은 자체 로그에서 **응답 시간, 에러율** 추이 관찰
    - network I/O 부하가 큰 시점에 **RDS CPU나 세션이 급증**한다면, DB 병목 가능성.
    - 반면 RDS CPU는 낮은데 네트워크만 과도하게 사용된다면, **대량의 데이터 전송**(예: 무거운 응답)일 가능성.

## 5. 결론 및 추천 시나리오

1. **가장 간단한 방법**:
    
    - **CloudWatch 기본 지표**(ECS, EC2, RDS)와 **RDS Performance Insights**, 그리고 **CloudWatch 로그**만으로도
        - 트래픽 증가 시 네트워크 사용량, DB 쿼리 성능, 에러율 등을 상당 부분 추적 가능합니다.
    - 이는 **AWS Free Tier** 범위 안에서 대부분 무료로 가능하며, 지표 대량 수집만 하지 않는다면 과금은 미미합니다.
2. **조금 더 심층적인 분석**:
    
    - **AWS X-Ray**를 켜서 ECS 서비스(애플리케이션) ↔ RDS 사이의 트랜잭션을 추적
    - 특정 API 호출이 100ms 이상 지연된다면, X-Ray 상에서 DB 쿼리 시간이 90ms를 차지하는지, 아니면 네트워크 DNS Lookup이나 TLS 핸드셰이크가 오래 걸리는지 파악
3. **오픈 소스 APM/모니터링 도입**:
    
    - 더 세부적인 모니터링과 커스텀 대시보드를 원한다면, **Prometheus + Grafana**를 작은 EC2 t3.micro(Free Tier) 인스턴스에 올려 사용
    - 필요에 따라 **Jaeger/Zipkin**으로 트레이싱 시각화
    - 다만 초기 세팅 및 운영 부담이 있고, EC2 자원 제한이 있으니 트래픽이 많다면 신중하게 계획해야 함



# 스파이크 테스트시에 아웃 바운드 트래픽 문제

```
 checks.........................: 99.99% 168822 out of 168824
     data_received..................: 1.5 GB 6.2 MB/s
     data_received_size.............: avg=8.33s    min=8.23s    med=8.36s   max=8.38s    p(90)=8.38s    p(95)=8.38s   
     data_sent......................: 64 MB  267 kB/s
     http_req_blocked...............: avg=206.17µs min=1.12µs   med=3.87µs  max=3.52s    p(90)=13.04µs  p(95)=21.62µs 
     http_req_connecting............: avg=188.02µs min=0s       med=0s      max=3.52s    p(90)=0s       p(95)=0s      
     http_req_duration..............: avg=252.83ms min=361.91µs med=79.95ms max=12.46s   p(90)=674.24ms p(95)=787.24ms
       { expected_response:true }...: avg=252.83ms min=2.27ms   med=79.96ms max=12.46s   p(90)=674.24ms p(95)=787.24ms
     http_req_failed................: 0.00%  2 out of 168824
```

- 한번에 매우 큰 부하를 테스트 해서 그런지 `data_received` 크기가 너무 크다.

```
export const options = {
    discardResponseBodies: true, // 응답 본문 무시
    stages: [
        { duration: "1m", target: 500 },
        { duration: "1m", target: 1000 },
        { duration: "1m", target: 2000 },
        { duration: "1m", target: 0 },
    ],
};
```

- 응답 본문을 무시하고 테스트 할 수 있지만 이는 정확한 부하 테스트라고 보기 어려울것 같다.
- `response` 데이터를 압축해서 리턴하면 어떻게 될까