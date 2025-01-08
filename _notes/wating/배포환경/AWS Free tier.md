---
title: mokakbab-issue
permalink: /wating/k6-spike-test
---

- ECR
- ECS
- RDS
- S3
- 온프레미스 서버란

### [2.3. 2.3 요금 계산](https://yeonwoo97.tistory.com/602#article-2-3--2-3-%EC%9A%94%EA%B8%88-%EA%B3%84%EC%82%B0)

24시간 한달 내내 돌린다고 가정할 때,

**ECS Anywhere의 총 요금** = 1개의 온프레미스 인스턴스 x 30일 x 24시간 x 0.01025 USD의 인스턴스 시간 = 7.38 USD

- ECR 프리티어 용량 제한이 있지만 무료
- RDS 무료
- S3 무료
- [컨테이너 기반 무료 제품](https://aws.amazon.com/ko/free/containers/?p=ft&z=subnav&loc=3#Learn_more_about_Containers) 
- EC2와 ECS 사용하면 프리티어 기간동안 무료군
- [ECS 공식문서 친절하군](https://aws.amazon.com/ko/ecs/getting-started/?pg=ln&cp=bn) 
- [자동 오토스케일링 안되게 따로따로생성](https://velog.io/@heoze/%EB%8F%84%EC%A0%84-%ED%94%84%EB%A6%AC%ED%8B%B0%EC%96%B4%EB%A1%9C-AWS-ECS-%EC%82%AC%EC%9A%A9%ED%95%98%EA%B8%B0-ECS-%ED%81%B4%EB%9F%AC%EC%8A%A4%ED%84%B0%EC%97%90-EC2-%EC%9D%B8%EC%8A%A4%ED%84%B4%EC%8A%A4-%EC%97%B0%EA%B2%B0-%EA%B0%84%EB%8B%A8-%EB%B0%B0%ED%8F%AC-%ED%85%8C%EC%8A%A4%ED%8A%B8) 


# ECS

1. ECS 클러스터 생성
2. AWS Fargate 해제
3. Amazon EC2 인스턴스해제
4. 모니터링 꺼짐

- Free tier에서 사용하기 위해서 부하테스트시에 자동 오토 스케일링 그룹을 방지하기 위해서
- EC2와 ECS 클러스터를 따로 따로 생성

## 스크린샷

![[Pasted image 20250106123939.png]]

- 인프라 다 체크 해제 후에 생성 하기

# EC2

- Free tier micro 적용되는 기본 인스턴스 생성
- [공식문서 ECS와 EC2 연동](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-install.html#ecs-agent-install-al2) 


## SSH 접속하여 ECS agent 설정

```
curl -O https://s3.ap-northeast-2.amazonaws.com/amazon-ecs-agent-ap-northeast-2/amazon-ecs-init-latest.x86_64.rpm
sudo yum localinstall -y amazon-ecs-init-latest.x86_64.rpm
```


## 설정 파일 수정

```
vi /lib/systemd/system/ecs.service
```

- `/lib/systemd/system/ecs.service`에 `[Unit]` 부분의 마지막 줄 다음과 같이 수정

```
[Unit]
Description=Amazon Elastic Container Service - container agent
Documentation=https://aws.amazon.com/documentation/ecs/
Wants=docker.service
PartOf=docker.service
After=cloud-final.service // 여기 수정

[Service]
Type=simple
Restart=on-failure
RestartPreventExitStatus=5
RestartSec=10s
EnvironmentFile=-/var/lib/ecs/ecs.config
EnvironmentFile=-/etc/ecs/ecs.config
ExecStartPre=/usr/libexec/amazon-ecs-init pre-start
```

- `/etc/ecs/ecs.config` 파일 생성

```bash
ECS_CLUSTER=생성한 클러스터 이름을 여기에
ECS_ENABLE_TASK_IAM_ROLE=true
ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true
```

- *주의 EC2의 역할 설정이 서비스별로 역할 설정으로 바뀐것 같다* 

![[Pasted image 20250106134926.png]]

- EC2 대상으로 해당 IAM 정책을 추가한다.

- *중요) Docker가 필요하다*

```
sudo yum update -y
sudo amazon-linux-extras install docker
sudo systemctl enable docker
sudo systemctl start docker
```


- ECS agent 실행하기

```
sudo systemctl start ecs # 지금 시작
sudo systemctl enable ecs # EC2 인스턴스가 재시작 되면 자동 시작
```


```
sudo yum install -y containerd.io docker
```


# ECR 생성

- ECR private 레포지토리 레포지토리 이름만 설정하고 그대로 생성하기

# 사용자 생성

## 배포시 ECS Task 역할을 설정
- 역할 생성 -> AWS 서비스 -> Elastic Container Service Task 

![[Pasted image 20250106144554.png]]

- 권한 추가
	- AmazonECS_FullAccess
	- AmazonECSTaskExecutionRolePolicy
	- AmazonS3FullAccess

![[Pasted image 20250106144820.png]]


## 배포시 사용자 생성

- 사용자 생성 -> 이름 설정 후 다음
- 직접 정책 연결

- AmazonECS_FullAccess
- AmazonECSTaskExecutionRolePolicy
- AmazonEC2ContainerRegistryFullAccess
- AmazonElasticContainerRegistryPublicFullAccess
- AmazonElasticContainerRegistryPublicPowerUser
- AmazonElasticContainerRegistryPublicReadOnly
- AWSAppRunnerServicePolicyForECRAccess

![[Pasted image 20250106145903.png]]

### 사용자 생성 후 

- 사용자 선택 -> 보안 자격 증명 -> 액세스 키 만들기

# ECS github actions 연동 태스크 생성

- ECS -> 태스크 정의 -> 새 태스크 정의 생성

```
브리지 네트워크 모드는 작업을 호스팅하는 각 Amazon EC2 인스턴스 내에서 실행되는 도커의 기본 가상 네트워크를 사용합니다. 브리지는 동일한 브리지 네트워크에 연결된 각 컨테이너가 서로 통신할 수 있도록 하는 내부 네트워크 네임스페이스입니다. 이는 동일한 브리지 네트워크에 연결되지 않은 컨테이너와의 격리 경계를 제공합니다. 정적 또는 동적 포트 매핑을 사용하여 컨테이너의 포트를 Amazon EC2 호스트의 포트와 매핑합니다.
```


![[Pasted image 20250106203649.png]]

- *중요) CPU 메모리 0.98GB로 변경* 
- EC2 인스턴스 선택
- *네트워크 모드 EC2는 브릿지 선택 해야된다* 
- 태스크 크기
	- CPU 비워두기 메모리 1GB
- 태스크 역할
	- 아까 위에서 IAM 생성한 태스크 역할 추가

## 배포 컨테이너
- 이름 : 도커 이미지 이름
- 이미지 URI : ECR 보고 잘 설정
- 필수 컨테이너 : 예
- 포트 매핑 : 80에 원하는 애플리케이션 포트
- 리소스 할당

![[Pasted image 20250106165007.png]]

- *중요) GPU 공백으로 해둬야함* 
- Free tier EC2의 최대치로 설정 했다.
- 환경변수 설정
- 나머지는 기본값으로 둔채로 생성


# 테스트용 배포

- 미리 테스트용으로 ECR에 올리고 ECS에 배포를 돌려 놓으면 좋다.
- 지금까지 한 작업이 잘되는지 확인 할 수 있고
- github actions로 배포를 할 때 테스트로 해둔것의 Task와 Service를 사용 한다.


## EC2 터미널 다시 접속

- ECR에서 View push commands를 클릭 했을때 첫번째 커맨드를 그대로 입력

```
aws ecr get-login-password --region <리전> | docker login --username AWS --password-stdin <어카운트_아이디>.dkr.ecr.<리전>.amazonaws.com

// 이게 떠야함
Login Succeeded
```

- index.html 생성


```
<!doctype html>
<h1>hello ecs!</h1>
```

- Dockerfile

```
FROM nginx:latest

COPY ./index.html /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

- ECR에서 시키는대로 빌드 명령어 입력
- ECR에서 시키는대로 이미지에 태그 지정
- ECR에서 시키는대로 레포지토리에 푸시

### ECR 푸시할때 에러

- no basic auth credentials: 1번 다시로그인 해야함.
- no identity-based policy allows the ecr:InitiateLayerUpload action : 정책 추가 해줘야한다.
	- EC2에 AmazonEC2ContainerRegistryFullAccess 권한 추가
- push 완료 잘된다!! ECR에 가면 레포지토리에 이미지 있음


## ECS 태스크 실행으로 배포

- ECS -> 태스크 정의 -> 선택 후 -> 배포 -> 서비스 생성

![[Pasted image 20250106200712.png]]

![[Pasted image 20250106211105.png]]


- 중요) 기존 클러스터 선택
- 중요) 시작 유형 -> EC2
- 서비스 이름 설정하고 기본값으로 생성 누른다.
- 데몬으로 안하면 리소스 딸린다.


# github actions를 통해서 배포하기

```yaml
name: AWS deploy

on:
  push:
    branches:
      - feature/76-infra-change-aws
      

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
          file: ./Dockerfile.ecs
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

- 핵심은 Download task definition으로 가져온 json 파일을 가지고 Deploy 하게 구성.


# github actions ECS 이해 한거 정리

- https://github.com/aws-actions/amazon-ecs-render-task-definition
- https://github.com/aws-actions/amazon-ecs-deploy-task-definition
- https://docs.aws.amazon.com/ko_kr/code-library/latest/ug/cli_2_ecs_code_examples.html

## json 파일

- 여러 블로그에서`json` 파일을 프로젝트 루트 경로에 넣는 글들이 종종 있었는데 이런 민감한 정보를 github 올리는게 이해가 안되었다.
- 그래서 찬찬히 이해를 해보니 `json` 파일을 프로젝트에 올릴 필요가 없다.

## service? task? 뭔데 그게

- 두개가 크게 분류 되어 있기 보다 태스크는 작업을 정의 하는 부분이다.
- 서비스는 태스크 정의 메뉴에서 만들어둔 해당 태스크를 서비스 생성을 해서 배포 하는 역할을 하는 녀석이다.
- 태스크정의에서 만든 태스크에서 다시 태스크 실행이란걸 할 수 있는데 배치 작업 같은것들을 할 때 사용되는거다.

1. 태스크 정의
2. 정의된 태스크 -> 서비스 생성
3. 정의된 태스크 -> 태스크 실행

## github actions ecs 부분 

- aws-actions/amazon-ecs-render-task-definition
- aws-actions/amazon-ecs-deploy-task-definition


### render-task

- 태스크 정의 할때 처럼 json 파일을 만드는곳이라고 이해하면 된다.
- aws 사이트에서 미리 태스크를 정의 해두고 그걸 여기에서 가져와서 수정 작업을 한다던지 할 수 있는거다.


### amazon-ecs-deploy-task-definition

- render-task나 아무튼 태스크 json 파일을 통해서 해당 태스크를 특정 클러스터에 특정 서비스로 배포 하는 역할을 하는 녀석이다.
- [공식문서](https://github.com/aws-actions/amazon-ecs-render-task-definition) 

```yaml
- name: Fill in the new image ID in the Amazon ECS task definition
        id: task-def
        uses: aws-actions/amazon-ecs-render-task-definition@v1
        with:
          task-definition: ecs-deploy-task-definition.json
          container-name: nestjs-app
          image: ${{ steps.image-path.outputs.ecs-deploy }}
```

- task json 파일을 해당 이미지를 통해서 정의 해주는 역할을 하는것 같다.
- with 부분에 여러가지 옵션을 넣어서 만들 수 있을것이다.
- 하지만 나는 aws 사이트에서 만들어둔 태스크를 가져와서 그대로 사용 하고 싶다.
- 그래서 해당부분은 사용하지 않을것 같다.

## 정리

- 정리 하자면 ECS를 사용 할 때
- AWS에서 사이트에서 할일
	-  ECS 클러스터 만들기
	- Task 정의에 가서 Task 만들기
- ECS 페이지에서 나머지 부분들은 다 github actions로 처리 할 수 있다.

# 과금 문제

- IPV4 과금문제
- Amazon VPC IP Address Manager에서 퍼블릭 Ip 쓰는 녀석 찾아야함

https://shortcuts.tistory.com/53

# Reference

- [많은 도움이된 블로그](https://velog.io/@heoze/%EB%8F%84%EC%A0%84-%ED%94%84%EB%A6%AC%ED%8B%B0%EC%96%B4%EB%A1%9C-AWS-ECS-%EC%82%AC%EC%9A%A9%ED%95%98%EA%B8%B0-ECS-%ED%81%B4%EB%9F%AC%EC%8A%A4%ED%84%B0%EC%97%90-EC2-%EC%9D%B8%EC%8A%A4%ED%84%B4%EC%8A%A4-%EC%97%B0%EA%B2%B0-%EA%B0%84%EB%8B%A8-%EB%B0%B0%ED%8F%AC-%ED%85%8C%EC%8A%A4%ED%8A%B8) 

