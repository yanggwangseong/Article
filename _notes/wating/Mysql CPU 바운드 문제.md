---
title: mokakbab-issue
permalink: /wating/issue
---

배포 서버 사양 (centos-7.8-64) 2vCPU, 4GB Mem, 50GB Disk

여기서 분명 단일 request는 0.02s 걸리는데 RPS가 로컬에서는 500RPS가 나오는데 실제 배포서버에서는 150RPS가 나옵니다. 지금 제가 추측 하는걸로는 Mysql가 CPU를 50% 점유하는걸로 보아서 로컬에서는 SSD로 동작하지만 배포 서버에서는 HDD로 동작하기 때문에 굉장히 느린걸로 추측합니다. 왜냐하면 지금 쿼리 최적화를 해두었기 때문에 단일건 request 요청은 매우 빠르거든요

# 문제 원인 추정

1. **디스크 I/O 병목**:
    - 현재 디스크가 HDD이고 읽기 속도가 약 **190 MB/s**로 확인되었습니다. 이는 다중 읽기 요청이 발생할 경우 병목을 초래할 가능성이 있습니다.
    - 특히 InnoDB의 랜덤 읽기/쓰기는 HDD에서 더 많은 대기 시간을 발생시킬 수 있습니다.
2. **MySQL 연결 문제**:
    - 플레임그래프에서 `connect` 및 `parse` 작업이 CPU를 많이 점유하고 있는 것은, **연결 수립이나 쿼리 파싱 작업이 과도하게 발생**하고 있을 가능성을 시사합니다.
    - 이는 애플리케이션이 연결 풀(Connection Pool)을 적절히 사용하지 못하거나, 과도한 쿼리 호출이 원인일 수 있습니다.
3. **버퍼풀 크기 증가 효과 제한**:
    - 버퍼풀 크기를 증가했지만, 디스크 I/O 병목이 버퍼풀로 데이터를 충분히 로드하는 것을 제한하고 있을 가능성이 있습니다.

# 나의 추측

- 실제 배포 서버에서는 HDD에서 읽어오기 때문에 지속적인 페이폴트가 일어나서 CPU 병목 현상이 발생하는게 아닐까?
- 즉, 지금 현재 스레싱이 발생하고 있는것이다!

## 페이지 폴트 발생 확인

```bash
`# 페이지 폴트 확인 vmstat 1`
```


## Mysql에서 디스크 읽어오는 I/O 작업 때문일까?

- Mysql 배포 서버의 HDD에서 읽어 오는것 같았다.
- 그래서 페이지 폴트가 발생 할때 읽어오는 I/O 작업이 오래 걸리기 떄문에 Mysql에서 CPU 이용률이 증가 하고 따라서 읽어 오는 시간이 길다는것은 node서버의 응답이 느리다는것이고 따라서 node서버도 응답을 기다리니까 자연스럽게 CPU 이용률이 증가하는것이다.
- 그리고 그 페이지 폴트 작업이 쌓이다 보면 결국 Mysql과 node 서버의 CPU 이용률이 초과하게 되버리면서 요청들이 drop 되는것이라고 추측


> 도커 환경에서 모니터링

```bash
$ docker stats
```


![[Pasted image 20250103100919.png]]

- Block I/O
	- 129MB(읽기)
	- 16.4MB(쓰기)
	- MySQL이 상대적으로 높은 디스크 읽기 작업을 수행하고 있는 것으로 보입니다. 이는 데이터가 자주 디스크에서 읽혀야 한다는 것을 의미하며, 디스크 I/O 병목 가능성을 암시합니다.
- 네트워크 I/O
	- Net I/O 
		- 4.63MB
		- 6.83MB
		- 네트워크 대역폭 문제는 없다.

### 디스크 성능 확인

```bash
iostat -x 1
```

- `await` 값이 높다면 디스크 I/O 병목

## 느린 쿼리 확인 해보기

```ini
[mysqld]
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 1
```

```sql
SHOW VARIABLES LIKE 'slow_query_log';
SHOW VARIABLES LIKE 'slow_query_log_file';
SHOW VARIABLES LIKE 'long_query_time';
```

```bash
sudo cat /var/log/mysql/slow.log
```

- 슬로우 쿼리 로그를 켰는데 슬로우 쿼리 집계를 해보니 0이다.

```
SHOW GLOBAL STATUS LIKE 'Slow_queries';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| Slow_queries  | 0     |
+---------------+-------+
```

## MySQL 디스크 I/O 상태 확인

```sql
SELECT FILE_NAME, COUNT_READ, SUM_TIMER_READ, COUNT_WRITE, SUM_TIMER_WRITE
FROM performance_schema.file_summary_by_instance
ORDER BY SUM_TIMER_READ DESC
LIMIT 10;



+-------------------------------------------+------------+----------------+-------------+-----------------+
| FILE_NAME                                 | COUNT_READ | SUM_TIMER_READ | COUNT_WRITE | SUM_TIMER_WRITE |
+-------------------------------------------+------------+----------------+-------------+-----------------+
| /var/lib/mysql/mysql.ibd                  |        285 |    17187994844 |          34 |       757671268 |
| /var/lib/mysql/undo_002                   |        317 |     8405981224 |          11 |       239057614 |
| /var/lib/mysql/#ib_16384_1.dblwr          |          1 |     4924492158 |           0 |               0 |
| /var/lib/mysql/undo_001                   |        318 |     4893180346 |          16 |       383659726 |
| /var/lib/mysql/mokakbab/participation.ibd |         81 |     2098746908 |           0 |               0 |
| /var/lib/mysql/mokakbab/refresh_token.ibd |          4 |     1512148106 |           1 |        26265618 |
| /var/lib/mysql/mokakbab/articles.ibd      |         10 |      994612972 |           0 |               0 |
| /var/lib/mysql/#innodb_redo/#ib_redo1016  |          6 |      876892514 |          37 |      9841697908 |
| /var/lib/mysql/mokakbab/member.ibd        |          8 |      740849098 |           0 |               0 |
| /var/lib/mysql/ibdata1                    |         10 |      730728376 |           3 |        85896806 |
+-------------------------------------------+------------+----------------+-------------+-----------------+
```


```
디스크 I/O가 집중되는 파일:
mysql.ibd: 가장 많은 읽기 작업(COUNT_READ)과 읽기 시간(SUM_TIMER_READ)을 차지하고 있습니다.
COUNT_READ: 285
SUM_TIMER_READ: 17187994844 (높은 읽기 작업 시간)
undo_002, undo_001: COUNT_READ와 SUM_TIMER_READ가 높은 값을 보이며, 이는 InnoDB에서 트랜잭션 롤백 작업이나 버퍼 풀 관리에 사용되는 파일입니다.
participation.ibd: 애플리케이션의 특정 테이블로 보이며, 높은 읽기 작업 시간(SUM_TIMER_READ)이 관찰됩니다.
refresh_token.ibd 및 기타 테이블 파일: 상대적으로 읽기 작업 수는 적지만, 여전히 I/O 작업이 발생하고 있습니다.

디스크 읽기 대기 시간(SUM_TIMER_READ):
mysql.ibd 및 undo 파일에서 상당히 긴 읽기 시간이 관찰됩니다.
이는 InnoDB Buffer Pool이 충분하지 않거나 디스크 I/O 병목이 발생하고 있을 가능성을 암시합니다.
```

## MySQL 상태 확인

```sql
SHOW GLOBAL STATUS LIKE 'Innodb_%';
```


![[Pasted image 20250103111858.png]]

## I/O 성능 테스트

```bash
dd if=/dev/zero of=/tmp/test bs=64k count=16k conv=fdatasync
dd if=/tmp/test of=/dev/null bs=64k

// 결과
16384+0 records in
16384+0 records out
1073741824 bytes (1.1 GB) copied, 0.240078 s, 4.5 GB/s

// 캐싱 지우기 
sync; echo 3 > /proc/sys/vm/drop_caches
dd if=/tmp/test of=/dev/null bs=64k
```

-  쓰기 속도 (of=/tmp/test)
	- 속도: 171 MB/s
	- 171 MB/s는 일반적인 HDD의 성능에 해당하며, SSD에 비해서는 낮은 속도
- 읽기 속도 (of=/dev/null)
	- 속도: 4.5 GB/s
	- 빠르지만 디스크 캐싱 때문이다.
- *디스크 캐시지운 후 테스트 읽기 결과*
	- 속도 : 190 MB/s

# 해결방법

1. Mysql 저장소 SDD로 변경하는 방법
2. InnoDB 버퍼풀 크기를 늘려서 디스크 접근 줄이기
3. 쿼리 느린쿼리 확인과 인덱스 최적화


#### **(3) 애플리케이션 최적화**

1. **Node.js 프로파일링**:
    - 이벤트 루프가 차단되는 작업 확인.
    - 워커 스레드로 CPU 집약적인 작업 분리.
2. **로드 밸런싱**:
    - 요청을 여러 서버로 분산하여 RPS를 높임.

## InnoDB 버퍼풀 크기 증가

```ini
innodb_buffer_pool_size = 2G  # 현재 사용 가능한 메모리의 70-80%로 설정
```

### 버퍼풀 효율성 확인

```sql
SHOW GLOBAL STATUS LIKE 'Innodb_buffer_pool%';

버퍼풀 히트율 = 1 - (Innodb_buffer_pool_reads / Innodb_buffer_pool_read_requests)
```

- 히트율이 90% 이상이면 버퍼풀이 잘 작동하고 있는 것입니다.
- 히트율이 낮다면 버퍼풀 크기를 늘리는 것을 고려하세요.

### 버퍼풀 최적화 확인

```sql
SHOW ENGINE INNODB STATUS\G
```

"Buffer pool hit rate"가 낮다면 버퍼풀 크기를 추가로 늘려야 합니다.


## 커넥션 풀 확인

```sql
SHOW VARIABLES LIKE 'max_connections';
// 기본값 151

// 조정
SET GLOBAL max_connections = 200;
```

### MySQL 현재 연결 상태 확인

```sql
SHOW STATUS LIKE 'Threads%';
```


- 최대 커넥션 풀 150이고 부하테스트를 진행 하면서 MySQL 현결 상태를 확인 하여 커넥션 풀이 부족한지 확인한다.

### Mysql error 로그 설정 후 확인

```bash
docker exec -it mysql_prod cat /var/log/mysql/error.log
```


### Mysql CPU 사용 쿼리 추적

```sql
SELECT * 
FROM performance_schema.events_statements_summary_by_digest
ORDER BY SUM_TIMER_WAIT DESC
LIMIT 10;
```

## 커넥션 풀 문제

```bash
mysql max 커넥션 151개
애플리케이션에서 TypeORM 커넥션 리미트 30
```

- mysql max connection 개수
- typeorm connectionLimit 개수
- typeorm queueLimit 개수


## 작업 내용

### 데이터 베이스 및 개발 환경 작업

- InnoDB 버퍼풀 크기를 늘려서 디스크 접근 줄이기
- 커넥션 풀 조정하기
	- mysql max 커넥션 풀을 늘렸다.
- Mysql을 HDD I/O 작업에서 SDD에서 읽어올 수 있게 변경

### 애플리케이션 작업

- 토큰 검증 작업시 `refreshToken` 테이블 접근 제거
- nginx를 통한 로드 밸런서와 docker scale 옵션을 통한 서버 3개 스케일 아웃



# 결과
- InnoDB 버퍼풀을 증가 시키거나 mysql max 커넥션 풀을 늘려도 CPU 이용률이 떨어지지 않는다.


- typeorm  timeout 증가
- 네트워크 TCP 설정 조정
- 네트워크 캡쳐 도구 사용

### 1. TCP Keep-Alive 활성화

TCP Keep-Alive는 MySQL과 지속적인 연결을 유지하기 위해 설정합니다. Docker에서 이 기능을 활성화하려면 아래와 같이 설정할 수 있습니다:

#### Docker-Compose에서 설정

Docker Compose를 사용하면 MySQL 컨테이너의 설정 파일(`my.cnf`)에 Keep-Alive 관련 설정을 추가해야 합니다.

**`mysql/my.cnf`** 파일 예시:

ini

코드 복사

`[mysqld] # TCP Keep-Alive 설정 net_read_timeout=30 net_write_timeout=30 wait_timeout=28800 interactive_timeout=28800`

Docker-Compose 파일에 이미 `./mysql/my.cnf:/etc/mysql/conf.d/my.cnf`로 마운트 설정이 되어 있으므로, 위 내용을 추가한 뒤 컨테이너를 재시작하면 적용됩니다.


### 2. Nagle Algorithm 비활성화

Nagle Algorithm 비활성화는 Docker와 호스트 간의 네트워크 패킷 지연을 줄이기 위해 사용됩니다.

#### Docker-Compose에서 설정

`sysctl` 명령을 통해 Nagle Algorithm을 비활성화할 수 있습니다. Docker Compose의 `extra_hosts` 또는 `entrypoint` 스크립트를 수정하여 아래 명령을 추가합니다.

**`sysctl.conf` 예시:**

bash

코드 복사

`# Nagle Algorithm 비활성화 net.ipv4.tcp_no_metrics_save = 1 net.ipv4.tcp_sack = 0`

`extra_hosts` 또는 `entrypoint`에서 `sysctl -w`를 사용하여 실행:

yaml

코드 복사

`services:   mysql-prod:     image: mysql:8.0     sysctls:       net.ipv4.tcp_no_metrics_save: 1       net.ipv4.tcp_sack: 0`

# I/O 병목 문제

- typeorm keep alive 설정, mysql wait_timeout 설정 
- docker 네트워크 최적화 설정

## 웹서버에서 mysql 요청 테스트 ping

```bash
$ docker exec -it backend_prod sh
$ ping mysql_prod
```

## Docker 네트워크 사용량 확인

```bash
docker network inspect bridge
```


## Mysql 네트워크 설정 추가

```ini
wait_timeout = 28800
interactive_timeout = 28800
```


## Docker 네트워크 최적화 설정

1. 브릿지 네트워크 MTU 조정

```bash
docker network create \
  --driver bridge \
  --opt com.docker.network.driver.mtu=1400 \
  optimized_bridge
```

2. 고성능 네트워크 드라이버

```bash
docker network create \
  -d macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  -o parent=eth0 \
  macvlan_net
```

1. 기존 브릿지 네트워크 대신 고성능 네트워크 드라이버를 설치 한 후에 docker-compose에 네트워크 설정을 추가
2. macvlan 네트워크 외부 생성

```bash
docker network create \
  -d macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  -o parent=eth0 \
  --opt com.docker.network.driver.mtu=1400 \
  macvlan_net

// --opt com.docker.network.driver.mtu=1400
```

3. mtu 부분을 패킷 크기에 따라 조정

### 드라이버 사용중인지 확인

```bash
docker network inspect macvlan_net
```


### macvlan 필수 설정

```bash
ip link add macvlan-host link eth0 type macvlan mode bridge
ip addr add 192.168.1.100/24 dev macvlan-host
ip link set macvlan-host up
```

### 3.2 IP 포워딩 및 라우팅 설정

1. **IP 포워딩 활성화**  
    호스트가 패킷을 컨테이너로 전달하기 위해선 IP 포워딩이 켜져 있어야 합니다:
    
    bash
    
    코드 복사
    
    `sysctl -w net.ipv4.ip_forward=1`
    
    영구 적용은 `/etc/sysctl.conf`에 추가:
    
    bash
    
    코드 복사
    
    `net.ipv4.ip_forward = 1`

### NCP 클라우드 환경에서 macvlan_net 사용 안된다.

# 네트워크 공부가 필요하다 ㅠㅠ

- 와이어 샤크와 패킷 분석이 필요함...
	- 패킷 손실문제 그런거
- TCP Keep-Alive 가 뭔지 이해가 필요함


```yml
version: "3.9"
services:
    backend:
      image: ${NCP_CONTAINER_REGISTRY}/backend:latest
      
      expose:
        - ${BACKEND_OUTBOUND_PORT}
      environment:
          - DB_TYPE=${DB_TYPE}
          - DB_HOST=${DB_HOST}
          - DB_PORT=${DB_PORT}
          - DB_USERNAME=${DB_USERNAME}
          - DB_PASSWORD=${DB_PASSWORD}
          - DB_DATABASE=${DB_DATABASE}
          - DB_SYNCHRONIZE=${DB_SYNCHRONIZE}
          - JWT_SECRET_KEY=${JWT_SECRET_KEY}
          - JWT_ACCESS_TOKEN_EXPIRATION=${JWT_ACCESS_TOKEN_EXPIRATION}
          - JWT_REFRESH_TOKEN_EXPIRATION=${JWT_REFRESH_TOKEN_EXPIRATION}
          - MAIL_HOST=${MAIL_HOST}
          - MAIL_PORT=${MAIL_PORT}
          - MAIL_USER=${MAIL_USER}
          - MAIL_PWD=${MAIL_PWD}
          - API_BASE_URL=${API_BASE_URL}
          - SERVER_PORT=${SERVER_PORT}
          - N_ACCESS_KEY=${N_ACCESS_KEY}
          - N_SECRET_KEY=${N_SECRET_KEY}
          - N_ENDPOINT=${N_ENDPOINT}
          - N_REGION=${N_REGION}
          - N_BUCKET_NAME=${N_BUCKET_NAME}
          - N_BUCKET_URL=${N_BUCKET_URL}
      depends_on:
        - mysql-prod
      extra_hosts:
        - "host.docker.internal:host-gateway"

    backend-flame:
      image: ${NCP_CONTAINER_REGISTRY}/backend-flame:latest
      container_name: backend_flame
      ports:
          - "${BACKEND_OUTBOUND_PORT}:${BACKEND_INBOUND_PORT}"
      environment:
          - DB_TYPE=${DB_TYPE}
          - DB_HOST=${DB_HOST}
          - DB_PORT=${DB_PORT}
          - DB_USERNAME=${DB_USERNAME}
          - DB_PASSWORD=${DB_PASSWORD}
          - DB_DATABASE=${DB_DATABASE}
          - DB_SYNCHRONIZE=${DB_SYNCHRONIZE}
          - JWT_SECRET_KEY=${JWT_SECRET_KEY}
          - JWT_ACCESS_TOKEN_EXPIRATION=${JWT_ACCESS_TOKEN_EXPIRATION}
          - JWT_REFRESH_TOKEN_EXPIRATION=${JWT_REFRESH_TOKEN_EXPIRATION}
          - MAIL_HOST=${MAIL_HOST}
          - MAIL_PORT=${MAIL_PORT}
          - MAIL_USER=${MAIL_USER}
          - MAIL_PWD=${MAIL_PWD}
          - API_BASE_URL=${API_BASE_URL}
          - SERVER_PORT=${SERVER_PORT}
          - N_ACCESS_KEY=${N_ACCESS_KEY}
          - N_SECRET_KEY=${N_SECRET_KEY}
          - N_ENDPOINT=${N_ENDPOINT}
          - N_REGION=${N_REGION}
          - N_BUCKET_NAME=${N_BUCKET_NAME}
          - N_BUCKET_URL=${N_BUCKET_URL}
      volumes:
        - ./clinic-flame:/app/.clinic
        - ./clinic-flame:/tmp  # Doctor 실행을 위한 TMPDIR 경로와 동일하게 설정
      extra_hosts:
        - "host.docker.internal:host-gateway"

    mysql-prod:
      image: mysql:8.0
      restart: always
      container_name: mysql_prod
      volumes:
          - ./mysql-data:/var/lib/mysql
          - ./mysql/my.cnf:/etc/mysql/conf.d/my.cnf
          - ./mysql/logs:/var/log/mysql
      ports:
          - "${MYSQL_OUTBOUND_PORT}:${MYSQL_INBOUND_PORT}"
      environment:
          - MYSQL_DATABASE=${DB_DATABASE}
          - MYSQL_USER=${DB_USERNAME}
          - MYSQL_PASSWORD=${DB_PASSWORD}
          - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}

    nginx:
        image: nginx:stable-alpine
        container_name: nginx_lb
        ports:
        - "80:80"        
        depends_on:
        - backend
        volumes:
        - ./nginx/nginx.conf:/etc/nginx/conf.d/default.conf:ro
        - ./nginx/logs:/var/log/nginx


```



flame 그래프에 CPU 집약적인것도 별로 없고 제일 넓은 막대기가 3%이기 때문에 이건 CPU 병목이라고 하기 보다는 bubbleprof를 보면 I/O 병목문제 인것 같습니다.

- 그래서 현재 Mysql에서 파일 디스크 I/O 병목을 예상 하여 InnoDB 버퍼풀을 늘렸습니다.
- Mysql 연결 문제를 개선하기 위해서 max 커넥션 풀을 늘렸습니다(500)
- 쿼리를 분석하여 인덱스를 추가하고 쿼리 성능이 문제 없음을 확인 하였습니다. 또한 슬로우 쿼리 로그를 추가하여서 느린 쿼리가 없는것도 확인 하였습니다.
- 3번째 그림은 RPS600을 준 상태로 특정 api를 테스트 했을때 docker stats입니다.

만약 I/O 병목이라면 제가 알고 싶은거라면 두가지중에 뭐가 문제인지입니다.
1. mysql에서 디스크를 읽어오는 I/O 병목 문제인가
2. backend서버에서 database사이의 네트워크 통신 I/O 문제인가


- 슬로우 쿼리 로그 확인
- mysql 에러 로그 확인
- mysql max 커넥션 풀 증가
- mysql innodb 버퍼풀 증가
## 디스크 I/O 모니터링
```bash
iostat -x 1
// 또는
iostat -x 1 10 // 10개까지 가져오기
```

## 백엔드와 디비 사이간 네트워크 I/O 문제 확인

- **Ping 및 Latency 확인:**
    
    - MySQL 컨테이너와 Backend 컨테이너 간의 네트워크 레이턴시를 측정:
        
        bash
        
        코드 복사
        
        `docker exec -it backend_prod ping mysql-prod`
        
- **패킷 드롭 및 전송 속도 확인:**
    
    - 네트워크 상태를 확인하기 위해 `iftop` 또는 `netstat` 사용:
        
        bash
        코드 복사
        `netstat -s` 
### 도커 상태

```bash
docker stats
```


# 네트워크 레벨의 대기열 문제 또는 MySQL 연결 최적화가 핵심

```bash
[Nest] 27  - 01/03/2025, 8:29:05 AM   ERROR [ExceptionsHandler] Queue limit reached.
Error: Queue limit reached.
    at Pool.getConnection (/app/node_modules/mysql2/lib/base/pool.js:72:17)
    at /app/node_modules/typeorm/driver/mysql/MysqlDriver.js:728:27
    at new Promise (<anonymous>)
    at MysqlDriver.obtainMasterConnection (/app/node_modules/typeorm/driver/mysql/MysqlDriver.js:719:16)
    at MysqlQueryRunner.connect (/app/node_modules/typeorm/driver/mysql/MysqlQueryRunner.js:60:18)
    at /app/node_modules/typeorm/driver/mysql/MysqlQueryRunner.js:150:55
    at new Promise (<anonymous>)
    at MysqlQueryRunner.query (/app/node_modules/typeorm/driver/mysql/MysqlQueryRunner.js:147:16)
    at SelectQueryBuilder.loadRawResults (/app/node_modules/typeorm/query-builder/SelectQueryBuilder.js:2192:43)
    at SelectQueryBuilder.getRawMany (/app/node_modules/typeorm/query-builder/SelectQueryBuilder.js:646:40)

```

- 애플리케이션 내에서 발생하는 오류


## 리눅스 서버 네트워크 설정 최적화

```bash
// 서버의 네트워크 대역폭 제한 여부 확인
sudo tc qdisc show dev eth0
netstat -s
```


### **1. 주요 문제 요약**

1. **SYN Queue Overflow**:
    
    - `3008 times the listen queue of a socket overflowed`
    - `3008 SYNs to LISTEN sockets dropped`
    - 이는 TCP 연결 요청이 들어올 때 **SYN 큐**가 가득 차서 **연결 요청을 처리하지 못하고 버린 경우**를 의미합니다. 이는 **서버의 listen backlog 설정 부족** 또는 **과도한 부하**로 인해 발생합니다.
2. **TCP Retransmissions**:
    
    - `266 segments retransmitted`
    - `22 fast retransmits`
    - TCP 재전송이 발생했으며, 이는 **네트워크 병목** 또는 **패킷 손실**을 나타냅니다.
3. **Zero Window Advertisements**:
    
    - `TCPFromZeroWindowAdv: 13`
    - `TCPToZeroWindowAdv: 13`
    - 서버가 "Zero Window"를 보내고 받았다는 것은 **애플리케이션 또는 네트워크의 처리 속도 병목**으로 인해 TCP 송수신 버퍼가 가득 찬 경우를 나타냅니다.
4. **Connection Resets**:
    
    - `96 resets sent`
    - 연결이 정상적으로 종료되지 않고 **강제로 닫힌 경우**가 여러 번 발생했습니다. 이는 애플리케이션 문제 또는 네트워크 병목 가능성을 나타냅니다.

---

### **2. 문제 원인 분석**

#### **2-1. SYN Queue Overflow**

- 서버가 들어오는 TCP 연결 요청을 처리하지 못하고 버림.
- 원인:
    - `somaxconn` 값이 낮아 **백로그 큐 크기**가 부족.
    - 애플리케이션의 처리 속도가 느려 TCP 연결이 빠르게 완료되지 않음.

#### **2-2. TCP Retransmissions**

- 네트워크 레벨에서 패킷 손실 또는 지연으로 인해 재전송 발생.
- 원인:
    - 네트워크 대역폭 부족.
    - Docker `host` 네트워크에서도 패킷 손실 발생.

#### **2-3. Zero Window Advertisements**

- 애플리케이션 또는 네트워크 병목으로 인해 송수신 버퍼가 가득 참.
- 원인:
    - 백엔드 또는 MySQL 응답 지연.
    - 네트워크 처리 속도 부족.


```bash
sudo sysctl -w net.core.somaxconn=1024
sudo sysctl -w net.core.netdev_max_backlog=2048
sudo sysctl -w net.ipv4.tcp_max_syn_backlog=4096
sudo sysctl -w net.ipv4.tcp_syn_retries=3
sudo sysctl -w net.ipv4.tcp_fin_timeout=15
sudo sysctl -w net.ipv4.tcp_tw_reuse=1
sudo sysctl -p
```

## TCP 재전송 확인

```bash
netstat -s | grep retrans
```

## docker-compose 내부간의 네트워크 문제인가?

- NAT 오버헤드 문제인가?


# 결론적으로

```bash
docker logs backend_prod
docker logs mysql_prod
docker stats
```

- 디스크 I/O 병목 문제는 아니다.

```
지금까지 해온것들 총 정리
[mysql conf]
[mysqld]
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 1
innodb_buffer_pool_size = 2G
log_error = /var/log/mysql/error.log
log_error_verbosity = 3
max_connections = 500
wait_timeout = 28800
interactive_timeout = 28800

[TypeORM 설정]
import { ConfigModule, ConfigService } from "@nestjs/config";
import path from "path";

import {
    ENV_DB_DATABASE,
    ENV_DB_HOST,
    ENV_DB_PASSWORD,
    ENV_DB_PORT,
    ENV_DB_SYNCHRONIZE,
    ENV_DB_TYPE,
    ENV_DB_USERNAME,
} from "../constants/env-keys.const";

export const TypeOrmModuleOptions = {
    imports: [ConfigModule],
    inject: [ConfigService],
    useFactory: async (configService: ConfigService) => {
        const option = {
            type: configService.get(ENV_DB_TYPE) || "mysql",
            host: configService.get(ENV_DB_HOST) || "localhost",
            port: Number(configService.get<number>(ENV_DB_PORT)) || 3306,
            username: configService.get(ENV_DB_USERNAME) || "root",
            database: configService.get(ENV_DB_DATABASE) || "test",
            password: configService.get(ENV_DB_PASSWORD) || "test",
            entities: [path.resolve(process.cwd(), "dist/**/*.entity.{js,ts}")],
            synchronize: configService.get<boolean>(ENV_DB_SYNCHRONIZE) || true,
            keepAliveInitialDelay: 10000, // Keep-Alive 딜레이
            enableKeepAlive: true,
            extra: {
                connectionLimit: 100,  // 연결 풀 크기 증가
                queueLimit: 500,       // 대기열 크기 증가
                waitForConnections: true,
                connectTimeout: 60000, // 연결 타임아웃 증가
            },
            ...(configService.get("NODE_ENV") === "development"
                ? { retryAttempts: 10, logging: true }
                : { logging: false }),
        };

        return option;
    },
};

mysql 에러로그 on
mysql 슬로우 쿼리 로그 On
둘다 아무 문제 없음.
- mysql max 커넥션 풀 증가
- mysql innodb 버퍼풀 증가
- docker-compose network host로 변경
---------------
배포 서버 사양 (centos-7.8-64) 2vCPU, 4GB Mem, 50GB Disk
[배포 서버 docker-compose.yml]
version: "3.9"
services:
    backend:
      image: ${NCP_CONTAINER_REGISTRY}/backend:latest
      container_name: backend_prod
      network_mode: host
      ports:
          - "${BACKEND_OUTBOUND_PORT}:${BACKEND_INBOUND_PORT}"
      environment:
          - DB_TYPE=${DB_TYPE}
          - DB_HOST=${DB_HOST}
          - DB_PORT=${DB_PORT}
          - DB_USERNAME=${DB_USERNAME}
          - DB_PASSWORD=${DB_PASSWORD}
          - DB_DATABASE=${DB_DATABASE}
          - DB_SYNCHRONIZE=${DB_SYNCHRONIZE}
          - JWT_SECRET_KEY=${JWT_SECRET_KEY}
          - JWT_ACCESS_TOKEN_EXPIRATION=${JWT_ACCESS_TOKEN_EXPIRATION}
          - JWT_REFRESH_TOKEN_EXPIRATION=${JWT_REFRESH_TOKEN_EXPIRATION}
          - MAIL_HOST=${MAIL_HOST}
          - MAIL_PORT=${MAIL_PORT}
          - MAIL_USER=${MAIL_USER}
          - MAIL_PWD=${MAIL_PWD}
          - API_BASE_URL=${API_BASE_URL}
          - SERVER_PORT=${SERVER_PORT}
          - N_ACCESS_KEY=${N_ACCESS_KEY}
          - N_SECRET_KEY=${N_SECRET_KEY}
          - N_ENDPOINT=${N_ENDPOINT}
          - N_REGION=${N_REGION}
          - N_BUCKET_NAME=${N_BUCKET_NAME}
          - N_BUCKET_URL=${N_BUCKET_URL}
      extra_hosts:
        - "host.docker.internal:host-gateway"
      

    backend-flame:
      image: ${NCP_CONTAINER_REGISTRY}/backend-flame:latest
      container_name: backend_flame
      ports:
          - "${BACKEND_OUTBOUND_PORT}:${BACKEND_INBOUND_PORT}"
      environment:
          - DB_TYPE=${DB_TYPE}
          - DB_HOST=${DB_HOST}
          - DB_PORT=${DB_PORT}
          - DB_USERNAME=${DB_USERNAME}
          - DB_PASSWORD=${DB_PASSWORD}
          - DB_DATABASE=${DB_DATABASE}
          - DB_SYNCHRONIZE=${DB_SYNCHRONIZE}
          - JWT_SECRET_KEY=${JWT_SECRET_KEY}
          - JWT_ACCESS_TOKEN_EXPIRATION=${JWT_ACCESS_TOKEN_EXPIRATION}
          - JWT_REFRESH_TOKEN_EXPIRATION=${JWT_REFRESH_TOKEN_EXPIRATION}
          - MAIL_HOST=${MAIL_HOST}
          - MAIL_PORT=${MAIL_PORT}
          - MAIL_USER=${MAIL_USER}
          - MAIL_PWD=${MAIL_PWD}
          - API_BASE_URL=${API_BASE_URL}
          - SERVER_PORT=${SERVER_PORT}
          - N_ACCESS_KEY=${N_ACCESS_KEY}
          - N_SECRET_KEY=${N_SECRET_KEY}
          - N_ENDPOINT=${N_ENDPOINT}
          - N_REGION=${N_REGION}
          - N_BUCKET_NAME=${N_BUCKET_NAME}
          - N_BUCKET_URL=${N_BUCKET_URL}
      volumes:
        - ./clinic-flame:/app/.clinic
        - ./clinic-flame:/tmp  # Doctor 실행을 위한 TMPDIR 경로와 동일하게 설정
      network_mode: host

    mysql-prod:
      image: mysql:8.0
      restart: always
      container_name: mysql_prod
      network_mode: host
      volumes:
          - ./mysql-data:/var/lib/mysql
          - ./mysql/my.cnf:/etc/mysql/conf.d/my.cnf
          - ./mysql/logs:/var/log/mysql
      ports:
          - "${MYSQL_OUTBOUND_PORT}:${MYSQL_INBOUND_PORT}"
      environment:
          - MYSQL_DATABASE=${DB_DATABASE}
          - MYSQL_USER=${DB_USERNAME}
          - MYSQL_PASSWORD=${DB_PASSWORD}
          - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}


테스트 환경 k6 로컬에서 배포 서버로 요청
k6 RPS500 테스트 환경
 import { check, sleep } from "k6";
import http from "k6/http";
import { Trend } from "k6/metrics";

const dataReceivedTrend = new Trend("data_received_size", true);

export const options = {
    scenarios: {
        simple_rps_test: {
            executor: "constant-arrival-rate",
            rate: 500, // 초당 10개의 요청 (RPS)
            timeUnit: "1s", // RPS 단위 설정
            duration: "10s", // 테스트 지속 시간: 5분
            preAllocatedVUs: 500, // 미리 할당할 VU 수
            maxVUs: 1000, // 최대 VU 수
        },
    },
    // 태그 추가
    tags: {
        testName: "v2-participations-application",
        testType: "performance",
        component: "participations",
        version: "2.0",
    },
    // thresholds: {
    //     http_req_failed: [{ threshold: "rate<0.05", abortOnFail: true }],
    //     dropped_iterations: [{ threshold: "rate<0.05", abortOnFail: true }],
    //     http_req_duration: [{ threshold: "p(95)<3000", abortOnFail: true }],
    // },
};

export default function () {
    const BASE_URL = __ENV.BASE_URL || "http://localhost:4000";
    const ACCESS_TOKEN = __ENV.ACCESS_TOKEN || "access_token";

    const cursors = [12001, 23000, 30000, 40000, 50000];
    const cursor = cursors[Math.floor(Math.random() * cursors.length)];
    const limit = 10;

    const articleIds = [23640, 12714, 11621, 43514];

    const participationsResponse = http.get(
        `${BASE_URL}/participations/articles/${articleIds[Math.floor(Math.random() * articleIds.length)]}?cursor=${cursor}&limit=${limit}`,
        {
            headers: {
                Authorization: `Bearer ${ACCESS_TOKEN}`,
            },
            timeout: "60s",
        },
    );

    dataReceivedTrend.add(participationsResponse.body.length);

    check(participationsResponse, {
        "participations status is 200": (r) => r.status === 200,
    });

    sleep(1);
}


```


```
// 설마 공공 와이 파이 문제 아니겠지..
잠깐만요. 설마 지금 제가 공공와이파이를 사용하고 있는데 여기서 k6 요청을 보내는거에 뭔가 문제가 발생 하는걸 수 도 있나요? 그니까 지금 저는 배포 서버에서의 네트워크 대역폭이나 기타등등을 확인 하였는데 지금 현재 연결된 와이파이에서 뭔가 제한이 걸려 있는건 아니겠죠...?

```


# k6 cloud

```bash
k6 cloud /Users/bugibugi/Project2/flab/Mokakbab/k6/scripts/participations-performance.js --env BASE_URL="http://27.96.130.212:3000" --env ACCESS_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InVzZXJfMTczNDEwNDQ3NDMzM19pN3BwcXdAdW53aWxsaW5nLWF0dGljLm5hbWUiLCJzdWIiOjEsInR5cGUiOiJhY2Nlc3MiLCJpYXQiOjE3MzU5MDE3NDUsImV4cCI6MTczNTkwOTUyMX0.C7gqrJt_iycvyu4scx1OHtjPbQixoWUSC4ktcP4bRws"
```


```
k6 run participations-performance.js --env BASE_URL="http://27.96.130.212:3000" --env ACCESS_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InVzZXJfMTczNDEwNDQ3NDMzM19pN3BwcXdAdW53aWxsaW5nLWF0dGljLm5hbWUiLCJzdWIiOjEsInR5cGUiOiJhY2Nlc3MiLCJpYXQiOjE3MzYwMTU5NDEsImV4cCI6MTczNjAyMzcxN30.WUHKn3C2geu0T4rYCeiqKgWBWDx1iXCpvCcDf8hk4Fc"
```

```
k6 cloud /Users/bugibugi/Project2/flab/Mokakbab/k6/scripts/participations-performance.js --env BASE_URL="http://27.96.130.212:3000" --env ACCESS_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InVzZXJfMTczNDEwNDQ3NDMzM19pN3BwcXdAdW53aWxsaW5nLWF0dGljLm5hbWUiLCJzdWIiOjEsInR5cGUiOiJhY2Nlc3MiLCJpYXQiOjE3MzU5MDE3NDUsImV4cCI6MTczNTkwOTUyMX0.C7gqrJt_iycvyu4scx1OHtjPbQixoWUSC4ktcP4bRws"
```

# 초기 연결 지연 database 커넥션 문제 아닐까?
- 제너럴 로그 사용

```ini
general_log = 1
general_log_file = /var/log/mysql/general.log
```

#### 로그 분석

- `/var/log/mysql/general.log`에서 `Connect`와 `Quit` 이벤트를 검색:

```bash
grep "Connect" /var/log/mysql/general.log
grep "Quit" /var/log/mysql/general.log
```

### 5. **MySQL 서버 상태 확인**

- 커넥션 풀 부족이나 과부하를 유추하기 위해 MySQL 상태를 확인합니다.

```sql
SHOW STATUS WHERE Variable_name IN (
  'Threads_connected',
  'Threads_running',
  'Connections',
  'Aborted_connects',
  'Max_used_connections'
);
```


#### perfomance_schema

```ini
[mysqld]
performance_schema=ON
performance_schema_show_processlist = ON
```

```sql
SELECT * FROM performance_schema.events_waits_summary_global_by_event_name
WHERE EVENT_NAME LIKE 'wait/synch/%' AND SUM_TIMER_WAIT > 0;
```

### 5. **MySQL 버퍼 및 캐시 설정**

다음 설정이 적절한지 확인하세요:

- **`innodb_buffer_pool_size`**: InnoDB 버퍼 풀 크기.
- **`thread_cache_size`**: MySQL이 쓰레드를 재사용하도록 설정.
- **`table_open_cache`**: 동시에 열 수 있는 테이블 수.


```bash
SHOW FULL PROCESSLIST
```


```bash
grep "Connect" mysql/logs/general.log | wc -l
grep "Quit" mysql/logs/general.log | wc -l
```


```
SET GLOBAL wait_timeout = 60;  -- 60초
SET GLOBAL interactive_timeout = 60;  -- 60초

[mysqld]
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 1
innodb_buffer_pool_size = 2G
log_error = /var/log/mysql/error.log
log_error_verbosity = 3
max_connections = 1000
wait_timeout = 28800
interactive_timeout = 28800
general_log = 1
general_log_file = /var/log/mysql/general.log
performance_schema=ON
performance_schema_show_processlist = ON
```



# 변경하기

```ini
[mysqld]
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 1
innodb_buffer_pool_size = 2G
log_error = /var/log/mysql/error.log
log_error_verbosity = 3
max_connections = 1000
wait_timeout = 60
interactive_timeout = 60
general_log = 1
general_log_file = /var/log/mysql/general.log
performance_schema=ON
performance_schema_show_processlist = ON
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

- wait_timeout = 28800, interactive_timeout = 28800 이 설정이 문제였던건가! `sleep` 쿼리가 줄어들었다.

```bash
docker logs backend_prod
docker logs mysql_prod
docker stats
```


```
wait_timeout = 300
interactive_timeout = 300

늘려야 하나?
```

- DB 스토리지 병목
- `SHOW ENGINE INNODB STATUS;` 를 통해 I/O 관련 통계( File I/O, Pending I/O 등 )를 볼 수 있습니다.
- `iostat -x 1` 등의 명령어로 디스크 I/O 사용량, 대기 시간( await ), 큐 길이( avgqu-sz ) 등을 실시간으로 확인해볼 수 있습니


```
데이터베이스 액세스,
class-transformer나 ValidationPipe,
대규모 JSON 직렬화/파싱,
복잡한 RxJS 연산
```

- 이런 아무것도 없는 api를 테스트 해보자


# 커넥션 풀이 재사용 안되고 있나?

```
export const options = {
    scenarios: {
        ramp_up_test: {
            executor: "ramping-arrival-rate",
            startRate: 50,
            timeUnit: "1s",
            stages: [
                { target: 100, duration: "2m" },
                { target: 200, duration: "3m" },
                { target: 500, duration: "5m" },
            ],
            preAllocatedVUs: 700, // 최대 target (500)보다 약간 여유 있는 수준으로 설정
            maxVUs: 1000, // 최대 target과 맞추어 설정
        },
    },
    // 태그 추가
    tags: {
        testName: "v2-participations-application",
        testType: "performance",
        component: "participations",
        version: "2.0",
    },
    thresholds: {
        http_req_failed: [{ threshold: "rate<0.05", abortOnFail: true }],
        dropped_iterations: [{ threshold: "rate<0.05", abortOnFail: true }],
        http_req_duration: [{ threshold: "p(95)<3000", abortOnFail: true }],
    },
};
```