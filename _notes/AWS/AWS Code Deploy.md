---
title: mokakbab-issue
permalink: /wating/aws-code-deploy
---
- 선행 작업
- EC2 ECR ECS 연동
- ECS 클러스터 생성
- ECS 태스크 정의 패밀리 생성

## 이후 작업

- 생성한 클러스터에서 서비스 -> 생성
- 프론트 CloudFront + S3 + Route53 + ACM 배포
- 백엔드 EC2 + ECS 일때 서비스를 생성 할때 배포 옵션으로 블루/그린 AWS CodeDeploy 기반 방식을 지원하고 Amazon Elastic Load Balancing을 사용 할 수 있는 옵션 체크가 있는데 제가 알기로 ACM을 사용하기 위해선 Amazon Elastic LoadBalancing을 사용해야 되는것으로 알고 있습니다.

## 백엔드

1. **ALB 생성**
    - Listener: HTTP(80), HTTPS(443)
    - HTTPS에는 **ACM 인증서 연결**
2. **ECS 서비스 생성 (EC2 or Fargate)**
    - **CodeDeploy 배포 방식 → Blue/Green 선택**
    - **로드 밸런서 설정 필수 → ALB 지정**
    - Target Group 2개 (blue, green) 자동 생성됨
3. **Route53 → ALB에 도메인 연결**
    - `api.example.com` → ALB (HTTPS 가능)
4. **보안 그룹 및 VPC 설정**
    - ALB는 **퍼블릭 서브넷**
    - ECS는 **프라이빗 서브넷 (NAT + ALB 통해 노출)**

- ECS Service 생성시 배포 유형 설정 할 수 있는데 이때 CodeDeploy 구성과 서비스 역할을 설정
- 네트워킹
	- VPC 설정
- 로드 밸런싱 설정으로 앞단에 ALB 구성 해야한다.
- Route53 -> ALB 백엔드
- Route53 -> CloudFront 프론트

- [AWS ECS 배포를 시작하기전 레퍼런스 먼저](https://docs.aws.amazon.com/ko_kr/codedeploy/latest/userguide/deployment-steps-ecs.html#deployment-steps-prerequisites-ecs) 
- [AWS LB CodeDeploy ECS 레퍼런스](https://docs.aws.amazon.com/ko_kr/codedeploy/latest/userguide/deployment-groups-create-load-balancer.html) 

### ECS CodeDeploy 배포

- https://dong-queue.tistory.com/9
- https://medium.com/delivus/aws-codedeploy-blue-green-%EB%B0%B0%ED%8F%AC-%EC%A0%81%EC%9A%A9%EA%B8%B0-with-ecs-github-actions-aws-cdk-5d3325dba3fb

- IAM 서비스 역할 생성
- ALB에 보안그룹
- CodeDeploy에서 배포 그룹을 생성하고 난 후에 배포를 생성하지 않고 github Actions를 통해서 CD Pipleline을 구성한다.

- [AppSpec 파일 생성](https://docs.aws.amazon.com/ko_kr/codedeploy/latest/userguide/tutorial-ecs-create-appspec-file.html)

## 프론트

- **S3에 정적 파일 배포**
- **CloudFront 생성**
    - Origin → S3
    - Custom domain → `www.example.com`
    - TLS → **ACM (us-east-1)에서 발급**
- **Route53 연결**
    - `www.example.com` → CloudFront 도메인 (A 레코드, alias)

## 작업 순서

- 1. CloudFront 생성
- 2. ACM과 Route53 도메인 인증 설정 **ACM은 반드시 버지니아 북부로 발급받는다** 
- 2. CodeDeploy 설정
- 3. 로드 밸런싱 설정

```yml
name: Zero down-time deployment AWS ECS using CodeDeploy

on:
  push:
    branches:
      - disabled
      

jobs:
  deploy:
    name: Deploy
    runs-on: ubuntu-latest
    environment: production

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Build, tag, and push image to Amazon ECR
        id: build-image
        uses: docker/build-push-action@v3
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: ${{ secrets.AWS_CONTAINER_REGISTRY }}
          IMAGE_TAG: latest
        
        with:
          file: ./Dockerfile
          context: .
          push: true
          tags: ${{ steps.login-ecr.outputs.registry }}/${{ secrets.AWS_CONTAINER_REGISTRY }}:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max
          secrets: |
            GIT_AUTH_TOKEN=${{ secrets.GIT_TOKEN }}

      - name: Build Image Path
        id: image-path
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: ${{ secrets.AWS_CONTAINER_REGISTRY }}
          IMAGE_TAG: latest
        run: |
          echo "ecs-deploy=${{ steps.login-ecr.outputs.registry }}/${{ secrets.AWS_CONTAINER_REGISTRY }}:latest" >> $GITHUB_OUTPUT

      - name: Download task definition
        run: |
          aws ecs describe-task-definition \
            --task-definition ${{secrets.TASK_DEFINITION_NAME}} \
            --query taskDefinition \
            > ecs-deploy-task-definition.json

      - name: Deploy Amazon ECS task definition
        uses: aws-actions/amazon-ecs-deploy-task-definition@v1
        with:
          task-definition: ecs-deploy-task-definition.json
          service: ${{secrets.ECS_SERVICE}}
          cluster: ${{secrets.ECS_CLUSTER}}
          wait-for-service-stability: true

```


```yml
- name: Deploy to ECS via CodeDeploy
        run: |
          aws deploy create-deployment \
            --application-name ${{ secrets.CODEDEPLOY_APP_NAME }} \
            --deployment-group-name ${{ secrets.CODEDEPLOY_DEPLOYMENT_GROUP }} \
            --deployment-config-name CodeDeployDefault.ECSAllAtOnce \
            --description "GitHub Actions deployment" \
            --github-location repository=${{ github.repository }},commitId=${{ github.sha }}
```

