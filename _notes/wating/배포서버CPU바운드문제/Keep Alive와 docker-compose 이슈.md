---
title: mokakbab-issue
permalink: /wating/keep-alive
---

### **문제 요소**

1. **`network_mode: host`**
    
    - `network_mode: host` 설정으로 인해 컨테이너와 호스트가 동일한 네트워크 스택을 공유하게 됩니다.
    - 이로 인해 `DB_HOST=host.docker.internal`을 사용한 경우, 네트워크 연결이 불안정하거나 `keepAlive` 동작이 비정상적으로 작동할 가능성이 있습니다.
    - 특히, `host.docker.internal`은 Docker Desktop에서 호스트 네트워크에 접근하는 특수한 방법이므로, 네이티브 리눅스 환경에서는 완전히 지원되지 않을 수도 있습니다.
2. **`extra_hosts`**
    
    - `extra_hosts`를 통해 `host.docker.internal`을 강제 매핑했지만, 이 역시 네트워크 종속성을 유발할 수 있습니다.
    - 권장되는 방법은 Docker 네트워크 브릿지 또는 사용자 정의 네트워크를 사용하는 것입니다.
3. **MySQL 설정과 컨테이너 설정의 비호환성**
    
    - MySQL 설정에서 `wait_timeout`과 `interactive_timeout`이 지나치게 낮게 설정된 경우, `keepAlive` 연결이 타임아웃으로 끊어질 수 있습니다.
    - 예: `wait_timeout=120`은 짧은 세션 타임아웃을 유발하여 문제가 발생할 가능성을 높입니다.
4. **백엔드 컨테이너의 커넥션 풀 설정**
    
    - `TypeORM`의 `extra.connectionLimit` 값이 MySQL 서버의 `max_connections`와 적절히 조율되지 않은 경우, 풀 연결 초과나 타임아웃 문제가 발생할 수 있습니다.
    - 현재 설정에서 `connectionLimit=500`은 MySQL `max_connections=1000`의 약 50% 수준으로 적절해 보이나, 네트워크 문제로 인해 일부 연결이 끊길 가능성을 완전히 배제할 수는 없습니다.

---

### **권장 수정**

#### 1. **Docker 네트워크 개선**

- `network_mode: host`를 제거하고 사용자 정의 네트워크를 추가합니다.

yaml

코드 복사

`networks:   app_network:     driver: bridge  services:     backend:       networks:         - app_network      backend-flame:       networks:         - app_network      mysql-prod:       networks:         - app_network`

#### 2. **`DB_HOST` 설정 변경**

- `DB_HOST=host.docker.internal` 대신, 컨테이너 이름을 사용하여 MySQL 컨테이너에 연결합니다.
- 예: `DB_HOST=mysql-prod`.

#### 3. **MySQL 타임아웃 설정**

- MySQL의 `wait_timeout`과 `interactive_timeout` 값을 늘립니다.

ini

코드 복사

`wait_timeout=600 interactive_timeout=600`

#### 4. **TypeORM 커넥션 풀 설정 최적화**

- `TypeOrmModuleOptions`의 `queueLimit` 값을 조정합니다.

typescript

코드 복사

`extra: {     connectionLimit: 300, // 적절히 줄이기 (예: MySQL max_connections의 약 30%)     queueLimit: 1000, // 대기열 크기를 줄여 컨테이너 부하 완화     waitForConnections: true,     connectTimeout: 30000,     acquireTimeout: 30000, },`

#### 5. **로그 확인**

- MySQL 및 애플리케이션 로그를 통해 타임아웃 및 연결 끊김의 원인을 모니터링하세요.

---

### **결론**

- `network_mode: host`와 `DB_HOST=host.docker.internal` 설정은 네트워크 연결 문제의 주된 원인일 가능성이 높습니다. 사용자 정의 네트워크와 `DB_HOST=mysql-prod`로 변경하면 이 문제를 완화할 수 있습니다.
- MySQL의 `wait_timeout` 및 `interactive_timeout`을 늘리고, TypeORM의 커넥션 설정을 적절히 조정하면 연결 안정성을 더욱 높일 수 있습니다.
- 위 개선 사항을 적용한 후 성능 테스트를 다시 수행해보는 것이 필요합니다.



```bash
[root@mokakbab ~]# docker inspect backend_prod | grep "NetworkMode"
            "NetworkMode": "host",
```

```yaml
version: "3.9"
services:
    backend:
      image: ${NCP_CONTAINER_REGISTRY}/backend:latest
      container_name: backend_prod
      network_mode: host
      ports:
          - "${BACKEND_OUTBOUND_PORT}:${BACKEND_INBOUND_PORT}"
     
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



```

- `extra_hosts` 와 host.docker.internal를 사용하면 포트 충돌문제가 발생함.

# 브릿지 네트워크 전환 도전하기 전에

- 네트워크 안전성 테스트

### 5. **추가 네트워크 디버깅 도구**

#### **Traceroute**

네트워크 경로에서 병목 구간이 있는지 확인합니다.

bash

코드 복사

`traceroute <mysql-host-ip>`


```bash
[root@mokakbab ~]# docker inspect backend_prod | grep "NetworkMode"
            "NetworkMode": "host",
[root@mokakbab ~]# docker inspect mysql_prod | grep "NetworkMode"
            "NetworkMode": "root_default",
[root@mokakbab ~]# 

```

- 왜 네트워크 모드가 다를까?

- **MySQL bind-address 확인**: `mysql/my.cnf`에서 `bind-address = 0.0.0.0`으로 설정되어 있는지 확인하세요.

- Docker 네트워크 리스트 확인

```bash
docker network ls
```

- *같은 호스트라면 아래 명령어로 접속이 가능해야 하는거였다... 즉 네트워크가 다르네 하...* 

```bash
$ docker exec backend_prod ping mysql-prod
// ping: bad address 'mysql-prod'
```

1. 항상 같은 네트워크 인지 확인 해야 한다.

**DNS 해석 문제**

- 컨테이너 이름(`mysql-prod`)을 사용해 접근할 때 이름이 제대로 해석되지 않는 경우 발생할 수 있습니다.
- 이를 확인하기 위해 다음 명령어를 실행해 보세요:
    
**MySQL 접근 제한**

- MySQL이 `bind-address`로 `127.0.0.1` 또는 특정 IP만 허용하고 있다면, 외부 컨테이너에서의 접근이 차단될 수 있습니다.
- MySQL 설정 파일(`/etc/mysql/my.cnf` 또는 `/etc/my.cnf`)에서 다음을 확인하세요:
    
    css
    
    코드 복사
    
    `bind-address = 0.0.0.0`
    
    이 설정은 모든 인터페이스에서 MySQL 접근을 허용합니다.


# DNS 해석 과정 최적화

- 고정 Ip 설정
```yaml
networks:
  custom_network:
    ipam:
      config:
        - subnet: "172.18.0.0/16"

services:
  mysql-prod:
    networks:
      custom_network:
        ipv4_address: 172.18.0.2
  backend:
    networks:
      custom_network:
```



### 2. **DNS 캐싱이란?**

DNS 캐싱은 DNS 이름 해석 결과(IP 주소)를 일정 시간 동안 저장해두고, 같은 요청이 발생하면 DNS 서버에 다시 요청하지 않고 저장된 결과를 재사용하는 것을 의미합니다.

- **예:**
    - 처음 요청: `mysql-prod` → `172.18.0.2` 변환 (DNS 서버에 요청)
    - 캐싱된 이후 요청: DNS 서버에 다시 요청하지 않고 바로 캐시에서 `172.18.0.2` 반환.

Docker 내부 DNS도 기본적으로 이러한 캐싱 메커니즘을 활용해 네트워크 성능을 최적화합니다.



# 설정

- Host를 mysql-prod로 변경
- my.cnf 설정

```
bind-address = 0.0.0.0
skip-name-resolve
```

