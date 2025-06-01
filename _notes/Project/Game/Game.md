

- RN기반 게임 만들기
- https://bluromangames.tistory.com/27
- 러너류 게임
- Run and Jump
- https://github.com/bberak/react-native-game-engine
- expo 와 matter-js와 react-native-game-engine으로 만들 수 있나봄
- https://www.youtube.com/watch?v=qBGnfULn8W4&list=PLnGUkDX-ak1kdA8R8dUrkrqOG33fIrlWb

- expo
- react-native-game-engine
- matter-js
- expo-av
- Golang, Terraform, HTTP/2 gRPC

## 1. 프로젝트 구조 아이디어

### 백엔드 아키텍처

- Node.js (TS): 사용자 인증, RESTful API Gateway 역할
- Go: 핵심 서비스 로직 (e.g., 매치메이킹, 실시간 점수 처리 등)
- gRPC + HTTP/2: Node.js ↔ Go 서비스 간 통신
- Redis , Kafka

---

## 2. 인프라 구성


### 로컬 쿠버네티스

- 먼저 로컬 쿠버네티스 환경에서 먼저 연습하자.
- 어느정도 감을 잡았다면 GCP의 GKE에 배포
- 앱스토어에 게임 배포
- 게임 프론트 개발자와 디자이너 기획자가 필요할것 같다.

### EKS 기반 마이크로서비스

- EKS: Kubernetes로 각 서비스 배포
- Terraform: EKS 클러스터 및 인프라 리소스 생성 자동화
- Helm: K8s 리소스 배포 자동화 (Terraform에서 Helm provider 사용 가능)

---

## 3. Terraform 활용 포인트

  

### 인프라 코드화 예시

- EKS 클러스터 구성
- IAM 역할 및 OIDC Provider 연결
- Node Group 설정 (Fargate 또는 EC2)
- 서비스별 Helm Chart 배포
- node-api, go-grpc-service, ingress-nginx, cert-manager, external-dns 등
        
    

```
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  cluster_name    = "game-backend-cluster"
  cluster_version = "1.29"
  ...
}

resource "helm_release" "node_api" {
  name       = "node-api"
  chart      = "path/to/chart"
  ...
}

resource "helm_release" "go_grpc_service" {
  name  = "go-service"
  chart = "path/to/chart"
  ...
}
```


## 4. 프로젝트 데모 아이디어

- 로그인/회원가입 (Node.js)
- gRPC로 게임 플레이 기록 저장 요청 (Go)
- Grafana + Prometheus + Loki로 gRPC 응답 시간 모니터링
- Terraform으로 EKS + Ingress + Helm Chart 자동 배포
- proto 파일 작성 및 양방향 코드 생성 (protoc, ts-proto, buf 활용 가능)
- istio 기반 gRPC 트래픽 제어 및 observability 도입
- SRE 관점에서 Terraform 코드에 backend, state locking, workspace 고려
    
