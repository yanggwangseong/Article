---
title: mokakbab-issue
permalink: /wating/out-bound
---

- Free tier 기준 Outbound 트래픽 한도는 15GB이다.
- [aws 데이터 전송 요청 크레딧 신청을 해야할까?](https://aws.amazon.com/ko/blogs/korea/free-data-transfer-out-to-internet-when-moving-out-of-aws/) 
- [AWS 프리티어 공홈 FAQ](https://aws.amazon.com/ko/free/free-tier-faqs/?p=ft&z=subnav&loc=5&sc_channel=sm&sc_campaign=Support&sc_publisher=REDDIT&sc_country=global&sc_geo=GLOBAL&sc_outcome=AWS%20Support&sc_content=Support&trk=Support&linkId=242286059#Regions) 
- [aws 한번만 사용 할 수 있는 프로모션 크레딧](https://aws.amazon.com/ko/awscredits/) 

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

