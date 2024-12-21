---
title: Retry 전략
permalink: /wating/1
---

## 실패 요청에 대해

- 부하 테스트를 하다보면 100% 성공률을 달성하지 못한다.
- 그렇다면 5% 미만이나 1%미만의 스레시홀드 기준으로 잡고 부하테스트를 할때 이것도 결국 실제 사용자들이 많이 몰려서 트래픽이 발생 할 경우도 포함이니까.
- 혹시 이런 경우에는 앞단의 Nginx를 둔 후에 500대 에러를 사용자에게 리턴하게 해주고 어떻게 해결 해야 할까?
- 해결방법 생각
	- Retry-After 헤더를 통해서 503, 429 상태 코드에서 몇초 후에 재시도를 시도하라는 권장 헤더를 넣는다.
	- 실패율이 3%를 넘는 경우 시스템 로그와 모니터링 툴(예: Prometheus, Grafana)을 통해 문제 원인을 분석하고 대응 이게 결국 로그와 모니터링 툴을 사용 하는 이유가 될것 같다.

## 클라우드 환경이 아니라 하나의 서버일때

- 애플리케이션 서버가 1개이고 클라우드 환경도 아니고 클라우드 로드밸런서도 사용 못한다고 가정
- 만약 로드 밸런서를 사용할 수 없는 옛날 시스템 환경이라면?
	- DNS 라운드 로빈 (DNS Round Robin)
		- DNS 서버에서 하나의 도메인에 여러 개의 IP 주소를 할당하고, 요청이 들어올 때마다 순차적으로 다른 서버의 IP 주소를 반환하여 트래픽을 분산합니다.
	- 리버스 프록시 사용
		- Nginx, HAProxy, Caddy
	- 하드웨어 로드 밸런서
		- **F5 Networks**, **Cisco**, **Barracuda**와 같은 전문 하드웨어 장비를 사용해 네트워크 레이어에서 트래픽을 여러 서버로 분산했습니다.
	- IPVS (IP Virtual Server)
		- 리눅스 커널 레벨에서 동작하는 고성능 L4 로드 밸런서.
		- **활용**: Kubernetes의 **kube-proxy**에서 사용.
	- VRRP (Virtual Router Redundancy Protocol)
		- **개념**: 여러 라우터를 가상 IP로 묶고, 마스터 라우터에 장애가 발생하면 자동으로 백업 라우터로 전환.


## 클라우드 일때

- **동일한 Node.js 애플리케이션**을 여러 ECS Fargate 컨테이너로 실행합니다.
- 각 컨테이너는 같은 포트(예: `3000`)를 사용하지만 **다른 IP 주소**를 가집니다.
- **Application Load Balancer (ALB)** 가 클라이언트 요청을 여러 컨테이너에 분산시킵니다.
- 트래픽이 분산되면서 성능과 가용성이 개선됩니다.



<iframe src="https://docs.google.com/presentation/d/11sQIFWbpxqH3QON263AcdFlc3VASSK02PUED-yd12vM/preview" 
        frameborder="0" width="960" height="569" allowfullscreen></iframe>
