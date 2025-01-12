---
title: mokakbab-issue
permalink: /wating/out-bound
---

- Free tier 기준 Outbound 트래픽 한도는 15GB이다.
- [aws 데이터 전송 요청 크레딧 신청을 해야할까?](https://aws.amazon.com/ko/blogs/korea/free-data-transfer-out-to-internet-when-moving-out-of-aws/) 
- [AWS 프리티어 공홈 FAQ](https://aws.amazon.com/ko/free/free-tier-faqs/?p=ft&z=subnav&loc=5&sc_channel=sm&sc_campaign=Support&sc_publisher=REDDIT&sc_country=global&sc_geo=GLOBAL&sc_outcome=AWS%20Support&sc_content=Support&trk=Support&linkId=242286059#Regions) 
- [aws 한번만 사용 할 수 있는 프로모션 크레딧](https://aws.amazon.com/ko/awscredits/) 

# CPUCreditBalance

- free tier EC2 micro t2를 사용하고 있는데 쉽게 말해서 해당 크레딧 밸런스라는건 CPU의 로드밸런서라고 이해 하면 된다.
- 이건 끄기 옵션도 없기 떄문에 과금이 될까봐 걱정 했는데 무제한 옵션을 키지 않는 이상 과금 되지는 않는다.
- 근데 온전히 스파이크 테스트를 진행하는 방법을 찾을 수 가 없다...
- [AWS 부하 테스트 CPU 크레딧 모니터링](https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/burstable-performance-instances-monitoring-cpu-credits.html) 
- [부하 테스트 가능 인스턴스 개념](https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/burstable-credits-baseline-concepts.html#burstable-performance-instances-credit-table) 
- 크레딧이 없을 경우, CPU 성능은 다음처럼 작동합니다:
- **10%의 CPU 사용량 제한:**
    - T2.micro의 CPU는 단일 코어를 사용하며, 10% 사용량이란 코어의 계산 처리 능력이 크게 제한됨을 의미합니다.
# 결론

- (Requesst) 1분 이상 총 1Gbps(초당 10억 비트) 또는 1Gpps(초당 10억 패킷) 이상 부하 테스트를 진행 하면 반드시 디도스 아님을 증명하는 폼 양식을 제출 해야함.
- (Reponse) 한달에 100GB 아웃 바운드 트래픽만 허용한다.


# 멘토님 감사합니다

### 하드 리미트를 사용한 테스트 장점

1. **정확한 자원 제한**:
    
    - 하드 리미트를 설정하면 컨테이너가 특정 CPU나 메모리를 초과하여 사용하지 못하게 제한됩니다.
    - 이를 통해 테스트 환경에서의 RPS(초당 요청 수)가 제한된 리소스 하에서 어떻게 작동하는지 확인할 수 있습니다.
2. **테스트 재현성**:
    
    - 제한된 CPU 환경에서 반복 테스트를 수행하면 성능 결과를 비교 분석하기 쉽습니다.
3. **크레딧 문제 회피**:
    
    - EC2 인스턴스에서 CPU 크레딧 문제가 발생하지 않으므로 테스트 결과가 더 일관됩니다.



# EC2에서 Free Tier 확인

![[Pasted image 20250107151857.png]]
![[Pasted image 20250107151904.png]]

- 나가는 아웃 바운드 트래픽은 100GB인걸로 예상 된다.

```
Hello,

I am currently using the AWS Free Tier for learning purposes and have deployed a service using ECR, ECS, EC2, and AWS RDS. I would like to test the performance of my project by conducting a load test from my local computer to the deployed server.

Would conducting a load test in my current project result in any additional charges?
Based on the official documentation, I understand that inbound traffic is free, and outbound traffic is free up to 100GB per month under the Free Tier.
I estimate that my outbound traffic for the load test will be less than 20GB per month.
Could you kindly confirm if my understanding is correct and whether there would be any additional costs incurred during my load test?

Thank you for your assistance.
```

- 애매하면 AWS에 문의 넣자.

![[Pasted image 20250107154015.png]]


# 중요한점

## 배포환경

- EC2와 ECS를 사용 할 때 굉장한 부하 테스트기 때문에 EC2 테스트 정책을 미리 작성해서 해당 폼을 제출 하는게 좋다.
- 그렇지 않는다면 이를 `DDOS` 공격으로 간주 하는것 같다.
- [EC2 network test 정책과 폼 제출](https://aws.amazon.com/ko/ec2/testing/) 
- [aws 데이터 전송 요청 크레딧 신청을 해야할까?](https://aws.amazon.com/ko/blogs/korea/free-data-transfer-out-to-internet-when-moving-out-of-aws/) 



```bash
sudo docker run -d \
  --name mokakbab-container \
  --cpu-quota=50000 \
  --cpu-period=100000 \
  --cpuset-cpus="0" \
  --cpu-shares=512 \
  --memory="1g" \
  --env-file .env \
  -p 80:3000 \
  980921753402.dkr.ecr.ap-northeast-2.amazonaws.com/mokakbab:latest

```