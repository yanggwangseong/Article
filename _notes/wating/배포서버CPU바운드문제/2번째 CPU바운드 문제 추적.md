---
title: mokakbab-issue
permalink: /wating/issue
---

1. 토큰 검증 CPU 병목 가능성
2. 높은 RPS를 수행하기 위한 DB 커넥션풀 부족
3. CPU 사용률은 낮으니 I/O 병목 가능성이 높아보임.
4. 초기 데이터베이스 커넥션풀 생성이 오래걸리는 문제

- **Connection Pool 조정**:
    - `connectionLimit`을 더 높은 값으로 설정(예: 500).
    - `queueLimit`을 줄이거나 제거하여 초과된 연결 요청을 빠르게 거부하도록 설정.

서버 리소스 부족

- **스케일 아웃** 

Flame Graph에서 확인된 CPU 사용률(2.1%, 0.3%)은 높지 않으므로, **I/O 병목(DB, 네트워크 대기)** 이 주요 원인일 가능성이 높습니다.

- RPS를 시작하자마자 높게 올려서 커넥션풀이 생성 되는데 매우 큰 비용이 필요해서 문제가 발생하고 CPU 사용률도 급격히 증가하는데 시간이 지날수록 해당 커넥션풀을 재사용하기 때문에 시스템이 안정화 상태가 된다?


# 커넥션 풀 생성 비용 문제 추적

- 커넥션 풀 생성 초기 비용이 비싸고 CPU/메모리 부족을 추적

## 1. **Connection Pool 생성의 초기 비용**

MySQL에서 Connection Pool을 생성할 때 발생하는 주요 초기 비용은 다음과 같습니다:

### 1.1 **네트워크 연결 비용**

- Connection Pool 생성 시, 각 커넥션이 MySQL 서버와 네트워크 연결을 수립합니다.
- 각 연결은 TCP 핸드셰이크와 인증 과정을 포함하며, 이 과정은 CPU와 메모리에 부담을 줍니다.

### 1.2 **인증 및 권한 확인**

- MySQL은 연결 생성 시 사용자 인증과 권한 확인을 수행합니다.
- 특히 TLS/SSL을 사용하는 경우, 추가적인 암호화/복호화 연산이 발생합니다.

### 1.3 **리소스 할당**

- 각 커넥션은 메모리, 스레드, 파일 디스크립터 등 시스템 자원을 할당받습니다.
- **커넥션 1개당 약 256KB~1MB**의 메모리를 소모할 수 있습니다(MySQL 설정에 따라 다름).

### 1.4 **Connection Pool 관리 오버헤드**

- Connection Pool은 연결 상태(Idle, Active)를 관리하며, 풀 초기화 시 내부적으로 여러 데이터를 설정합니다.
- MySQL에서 `performance_schema`가 활성화된 경우, 추가적인 메모리 및 CPU 오버헤드가 발생할 수 있습니다.

## 완화 방법
- 커넥션 풀 Pre-Warming
- **사전 생성**: 애플리케이션 시작 시 Connection Pool을 미리 생성하여 초기 부하를 분산합니다.
- NestJS 애플리케이션 시작시 커넥션풀을 미리 생성 해두는 전략
- Mysql 서버 설정 스레드 풀 활성화

```ini
[mysqld]
thread_pool_size=4
```

- **DB 서버 로그(General Log)에서 “Connect”/“Quit”** 를 모니터링


# 모니터링 대상

1. *배포서버의 CPU 이용률과 메모리* 
2. mysql 로그 3개
3. mysql SHOW STATUS 와 SHOW PROCESSLISE


```
// 로그에 요청마다 커넥션을 계속 생성하는지 체크
$ tail -f mysql/logs/general.log | grep -i "Connect"
```

```bash
docker logs backend_prod
docker logs mysql_prod
docker stats
```

```sql
SHOW STATUS WHERE Variable_name IN (
  'Threads_connected',
  'Threads_running',
  'Connections',
  'Aborted_connects',
  'Max_used_connections'
);
```


```sql
SELECT * FROM performance_schema.events_waits_summary_global_by_event_name
WHERE EVENT_NAME LIKE 'wait/synch/%' AND SUM_TIMER_WAIT > 0;
```

```bash
SHOW FULL PROCESSLIST
```

```bash
grep "Connect" mysql/logs/general.log | wc -l
grep "Quit" mysql/logs/general.log | wc -l
grep "Aborted connection" mysql/logs/error.log | wc -l
grep "wait_timeout" mysql/logs/error.log | wc -l
```

```
truncate -s 0 mysql/logs/error.log
truncate -s 0 mysql/logs/general.log
truncate -s 0 mysql/logs/slow.log
```

```
// 스토리지 병목 확인
SHOW ENGINE INNODB STATUS;
```


1. mysql 현재 커넥션 상태 확인

```sql
SHOW STATUS WHERE Variable_name IN ('Threads_connected', 'Threads_running');
```

- `Threads_connected`: 현재 열려 있는 커넥션 수.
- `Threads_running`: 현재 실행 중인 커넥션 수.


# 네트워크 병목인거 아닐까

```
제 예측으로는 아무리 생각해도 초기 서버를 띄우면 디스크 I/O를 읽어오는 부분의 mysql CPU 부하가 발생하고 그다음에 초기 생성된 디비 커넥션풀이 없기 때문에 그것을 생성하는데 큰 오버헤드가 발생하여서 처음 부하 테스트를 시도 할때 VUs를 늘려도 drop_iterations가 발생한다고 생각이 듭니다.
결국 이는 백엔드 서버와 mysql 서버간의 네트워크 I/O 병목인거죠. 맞나요?
```

# 메모리 부족 문제인가?

- `free -m` 메모리 부족인가?

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```


- 스왑 메모리를 사용하면 조금 개선 될까?


# 실패의 주요 원인

### 1. **MySQL 초기 연결 생성 오버헤드**

- **로그 분석**
    
    bash
    
    코드 복사
    
    `grep "Connect" mysql/logs/general.log | wc -l # 600개 연결 생성 grep "Aborted connection" mysql/logs/error.log | wc -l # 532개 연결 중단`
    
    - MySQL이 `600`개의 초기 연결을 생성하려 했지만, `532`개의 연결이 중단되었습니다. 이는 커넥션 풀이 초기화되는 동안 연결이 너무 많아 CPU와 디스크 I/O에 병목이 발생했음을 보여줍니다.
    - `wait_timeout`으로 인해 연결이 강제 중단되었을 가능성도 있습니다 (`wait_timeout` 로그 확인).
- **커넥션 풀의 초기화**
    
    - 첫 번째 부하 테스트 시 MySQL이 새로 연결을 생성하고, 커넥션 풀을 채우는 과정에서 오버헤드가 발생합니다.
    - 두 번째 테스트에서는 이미 커넥션 풀이 초기화되어 있으므로 부하를 잘 처리합니다.

### 2. **네트워크 I/O 병목**

- **`http_req_blocked`**
    
    - 첫 번째 테스트 실패 시 `http_req_blocked`의 평균 시간이 `50ms`, 최대 `2초`로 매우 높았습니다. 이는 네트워크 연결 병목과 관련이 있습니다.
    - 두 번째 테스트에서는 `http_req_blocked`의 평균이 `19ms`로 줄어들며 네트워크 연결이 안정화되었습니다.
- **원인 추정**
    - MySQL 서버와 백엔드 서버 간의 네트워크 I/O가 초기 연결 생성 및 디스크 I/O로 인해 병목이 발생한 것으로 보입니다.


# 문제 결론은 네트워크 I/O와 초기 커넥션 풀 생성

