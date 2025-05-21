---
title: AWS Code Deploy
permalink: /AWS/aws-code-deploy
tags:
  - aws
  - post
category: AWS
---

## 선행 작업

- EC2 ECR ECS 연동
- ECS 클러스터 생성
- ECS 태스크 정의 패밀리 생성
- Route53 ACM 도메인 등록
- ALB와 도메인 연동

## ECS CodeDeploy

1. **ALB 생성**
    - Listener: HTTP(80), HTTPS(443)
    - HTTPS에는 **ACM 인증서 연결**
2. **ECS 서비스 생성 (EC2)**
    - **CodeDeploy 배포 방식 → Blue/Green 선택**
    - **로드 밸런서 설정 필수 → ALB 지정**
    - Target Group 2개 (blue, green) 자동 생성됨
3. **Route53 → ALB에 도메인 연결**
    - `api.example.com` → ALB (HTTPS 가능)


### ECS CodeDeploy 배포

- https://dong-queue.tistory.com/9
- https://medium.com/delivus/aws-codedeploy-blue-green-%EB%B0%B0%ED%8F%AC-%EC%A0%81%EC%9A%A9%EA%B8%B0-with-ecs-github-actions-aws-cdk-5d3325dba3fb

- IAM 서비스 역할 생성
- ALB에 보안그룹
- CodeDeploy에서 배포 그룹을 생성하고 난 후에 배포를 생성하지 않고 github Actions를 통해서 CD Pipleline을 구성한다.


## Reference

- [AWS AppSpec docs](https://docs.aws.amazon.com/ko_kr/codedeploy/latest/userguide/tutorial-ecs-create-appspec-file.htm) 
- [AWS ECS 배포를 시작하기전 레퍼런스 먼저](https://docs.aws.amazon.com/ko_kr/codedeploy/latest/userguide/deployment-steps-ecs.html#deployment-steps-prerequisites-ecs) 
- [AWS LB CodeDeploy ECS 레퍼런스](https://docs.aws.amazon.com/ko_kr/codedeploy/latest/userguide/deployment-groups-create-load-balancer.html) 