---
title: mokakbab-issue
permalink: /wating/CPU/결론
---

# 문제점의 결론

- 백엔드 서버와 MySQL 서버 사이의 네트워크 I/O 병목 현상
- **CPU 바운드 작업**
    - MySQL은 새 커넥션을 생성할 때 사용자 인증, 권한 검증, 세션 초기화 등의 작업을 수행합니다. 이 과정은 **CPU 리소스를 많이 사용**합니다.
    - 특히 초기에 많은 RPS 요청이 들어오면 MySQL 서버가 **빠르게 많은 스레드를 생성**해야 하므로 CPU 사용률이 급증합니다.
- **디스크 I/O 바운드 작업**
    - 새로운 커넥션이 생성되면 MySQL은 InnoDB의 데이터 및 인덱스를 디스크에서 읽어와 버퍼 풀에 적재합니다.
    - **초기에는 InnoDB 버퍼 풀이 비어 있으므로, 모든 요청이 디스크 I/O에 의존**하게 됩니다. 이로 인해 디스크 병목이 발생할 가능성이 큽니다.
- MySQL 컨테이너가 재시작되며 기존의 InnoDB 버퍼 풀이 비워지고, 모든 데이터를 디스크에서 다시 읽어와야 합니다.
- **MySQL의 초기화 작업과 커넥션 풀 생성 작업이 동시에 발생**하여 CPU와 디스크 I/O 사용량이 급격히 증가합니다.
- *컨테이너 안에서 백엔드와 MySQL 간의 다른 도커 네트워크를 사용했던 문제를 발견* 


## MySQL 서버 최적화

### **4.1 MySQL 서버 최적화**

1. **InnoDB 버퍼 풀 크기 조정**

```sql
SET GLOBAL innodb_buffer_pool_size = 2G; -- 예: 4GB RAM 기준
```
    
2. **InnoDB 버퍼 풀 쓰레드 최적화**

```sql
SET GLOBAL innodb_buffer_pool_instances = 2;
```
    
3. **스레드 캐시 활성화**
    
```sql
SET GLOBAL thread_cache_size = 4; -- CPU 코어 수의 2배 추천
```
    
4. **max_connections 증가**

```sql
SET GLOBAL max_connections = 500;
```



# 부하테스트시에 점진적 증가 방식을 채택해야한다.

```js
scenarios: {
    ramp_up_test: {
        executor: 'ramping-arrival-rate',
        startRate: 50,
        timeUnit: '1s',
        stages: [
            { target: 300, duration: '1m' },
            { target: 700, duration: '2m' },
        ],
        preAllocatedVUs: 500,
        maxVUs: 1000,
    },
}
```


# 커넥션 문제 해결을 위한 설정

1. Threads_connected 유지문제
2. Threads_created 증가 문제



# 결론

- 배포 서버의 한정된 자원으로 CPU 2코어 RAM 4GB 부하 테스트시에 점진적으로 증가한후에 RPS를 올려서 고원지대를 찾을 수 있게 k6 테스트 환경을 변경
- TypeORM 설정과 Mysql 설정을 테스트 환경에 최적화 하여 커넥션 풀과 MySQL 새로운 연결을 위한 스레드를 재활용 하지 못하는 문제.

## 설정

- MySQL의 wait_timeout 을 테스트 하면서 적절한 값을 찾아 설정

```sql
SET GLOBAL wait_timeout = 120;
SET GLOBAL interactive_timeout = 120;
```

- TypeORM 설정을 테스트를 진행 하면서 최적화 해야한다.

```ts
extra: {
    connectionLimit: 300, // MySQL max_connections의 50%로 설정 이전에 500
    queueLimit: 1500, // 대기열 크기를 조정 이전에 2000
    waitForConnections: true,
    connectTimeout: 30000, // 연결 타임아웃
    acquireTimeout: 30000, // 풀에서 커넥션 획득 타임아웃
},
```

- MySQL max_connections 증가

```sql
SET GLOBAL max_connections = 1500;
```

- MySQL 스레드 캐시 사이즈 증가

```sql
SET GLOBAL thread_cache_size = 32;
[mysqld]
thread_cache_size = 32
```

- MySQL InnoDB 버퍼풀을 증가시키기

```sql
[mysqld]
innodb_buffer_pool_size = 3G
innodb_buffer_pool_instances = 2
```

```ini
// 변경전
[mysqld]
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 1
innodb_buffer_pool_size = 2G
log_error = /var/log/mysql/error.log
log_error_verbosity = 3
max_connections = 1000
wait_timeout = 300
interactive_timeout = 300
general_log = 1
general_log_file = /var/log/mysql/general.log
performance_schema=ON
performance_schema_show_processlist = ON

```


