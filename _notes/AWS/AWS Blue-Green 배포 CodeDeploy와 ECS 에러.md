---
title: AWS Blue-Green 배포 CodeDeploy와 ECS 에러
permalink: /AWS/AWS Blue-Green 배포 CodeDeploy와 ECS 에러
tags:
  - aws
  - post
  - Troubleshooting
layout: note
image: 
category: AWS
description: AWS Blue-Green 배포 CodeDeploy와 ECS 에러
---

## ECS 에러

```
The ECS service cannot be updated due to an unexpected error: The container nestjs-app did not have a container port 443 defined. (Service: AmazonECS; Status Code: 400; Error Code: InvalidParameterException; Request ID: adb7f821-fb33-40cf-81cc-2500ae7f0585; Proxy: null). Check your ECS service status.
```

![](/assets/code-deploy01.png)


![](/assets/code-deploy02.png)

- 즉, **ALB(로드 밸런서)의 리스너가 트래픽을 전달하려는 대상 포트(443)** 이 ECS 서비스에서 **매핑되어 있지 않다**는 의미입니다.


## ALB 대상 그룹 → 대상 포트를 **4000으로 설정**

1. **ECS 서비스 > 배포 방식이 블루/그린일 경우**,  
    ALB의 대상 그룹(Target Group)은 **트래픽 전달 포트가 명시적으로 필요**합니다.
2. 현재는 ALB 리스너가 443으로 설정돼 있고, 그 트래픽을 **ECS 컨테이너의 포트 443으로 전달하려고 시도**하지만,
3. ECS Task 정의에 **443 포트가 없기 때문에 에러 발생**.
    

해결:
- **ALB 대상 그룹에서 포트 설정을 443 → 4000으로 바꿔야 합니다.**

## ALB 세팅

![](/assets/code-deploy03.png)

## ECS 세팅

![](/assets/code-deploy04.png)

![](/assets/code-deploy05.png)

- ALB에서 443으로 받아서 ECS에게 전달하는데 리스터로 433을 사용하는 ECS에서 백엔드 포트인 4000에 전달 해주어야 하는데 80으로 대상그룹 1,2를 만들어서 문제가 발생한다.

### 대상 그룹 포트를 **80 → 4000으로 수정**해야 합니다.

**ECS-A1, ECS-A2 대상 그룹 모두 다음과 같이 바꿔야 합니다:**
- **프로토콜**: HTTP
- **포트**: **4000**
- 상태 확인 경로(`/`)와 프로토콜은 그대로 유지해도 무방합니다.

## EC2에서 대상그룹 생성을 시도

![](/assets/code-deploy06.png)

![](/assets/code-deploy07.png)

![](/assets/code-deploy08.png)

![](/assets/code-deploy09.png)

대상 그룹 생성 할때 ALB가 아니라 인스턴스로 선택해서 생성 ECS가 인스턴스에서 돌고있기 때문에

![](/assets/code-deploy10.png)

ALB에서 대상그룹 4000포트로 전달해주는 1,2를 추가

![](/assets/code-deploy11.png)

![](/assets/code-deploy12.png)


## ECS Service 다시 생성

![](/assets/code-deploy13.png)

## 테스트 리스너도 변경해줘야함

![](/assets/code-deploy14.png)

![](/assets/code-deploy15.png)

![](/assets/code-deploy16.png)


## CodeDeploy 실패

```
The ELB could not be updated due to the following error:
Green taskset target group cannot have non-zero weight prior to traffic shifting
```

### ALB 리스너 규칙에서 대상그룹 하나만 지정 해야함

- Blue (EC2-NestJS-1) -> 트래픽 100%

![](/assets/code-deploy17.png)

## 배포 진행시 이미 포트 점유 에러 로그

```
|service [EC2-ECS-ECR-service-utskdyrj](https://ap-northeast-2.console.aws.amazon.com/ecs/v2/clusters/daily-sentence-be2/services/EC2-ECS-ECR-service-utskdyrj?region=ap-northeast-2) was unable to place a task because no container instance met all of its requirements. The closest matching container-instance [fe4b4b68ad6c411ca64d49bb80f5b40e](https://ap-northeast-2.console.aws.amazon.com/ecs/v2/clusters/daily-sentence-be2/infrastructure/container-instances/fe4b4b68ad6c411ca64d49bb80f5b40e?region=ap-northeast-2) is already using a port required by your task. For more information, see the Troubleshooting section of the Amazon ECS Developer Guide.|
```

- 이미 해당 포트를 사용중이라고 나온다.

ECS에서 **EC2 Launch Type**을 사용하는 경우, 컨테이너 인스턴스(EC2)에 할당할 수 있는 **HostPort(호스트 포트)** 가 **고정되어 있으면 중복 배포 불가능** 하다.

![](/assets/code-deploy18.png)

즉, 이렇게 4000 4000으로 설정하게 되면 EC2 인스턴스 기반으로 결국 4000포트를 이미 서비스가 돌아가고 있다면 충돌하여 배포에 실패하게 되는것이다.

## ALB와 ECS 흐름과 CodeDeploy

- ALB에서 Target Group 4000포트로 넘겨줘야한다.
- ECS 애플리케이션은 호스트 포트0 , 컨테이너포트 4000을 가져야한다.

![](/assets/code-deploy19.png)


## Code Deploy 소요시간 문제

- [CodeDeploy 시간 최적화하기](https://velog.io/@vanillacake369/GithubActions-CD-AWS-CodeDeploy-%EC%8B%9C%EA%B0%84-%EC%B5%9C%EC%A0%81%ED%99%94%ED%95%98%EA%B8%B0) 

![](/assets/code-deploy20.png)

3단계가 유독 너무 오래 걸린다.

### 3단계에서 무엇을 할까?

- 즉, **100% 트래픽 전환 이후에도 1시간 동안 기다렸다가 원래 작업 세트를 종료**합니다. 이건 문제가 있으면 트래픽을 다시 원래로 되돌릴 시간을 주는 것입니다.
- CodeDeploy 설정에서 `terminationWaitTimeInMinutes`를 줄이기

```json
"blueGreenDeploymentConfiguration": {
  "terminateBlueInstancesOnDeploymentSuccess": {
    "action": "TERMINATE",
    "terminationWaitTimeInMinutes": 5
  }
}
```

![](/assets/code-deploy21.png)

CodeDeploy에서 원래 개정 종료를 시간 1시간으로 처음 Default로 설정 해두어서 그렇다. 원래 작업 세트를 종료하기전에 대기하는 시간을 5분으로 줄이면 된다.

그러니까 즉, 트래픽 전환 후에 문제가 발생하는지 1시간정도 지켜보고 문제가 있으면 롤백 하기 위한 일종의 안전 장치이다.

### 배포 화면에서 수동 종료

배포 UI에서 직접 "원래 작업 세트 종료" 버튼 클릭하면 빠르게 배포 완료된다.


## Blue Green 배포시 PORT 전략 2가지

- [blue-green 배포 2가지 전략](https://velog.io/@yuureru/GithubActions%EC%9D%84-%EC%9D%B4%EC%9A%A9%ED%95%9C-CICD-nginX-redis-springboot-bluegreen-%EC%A0%81%EC%9A%A92) 
