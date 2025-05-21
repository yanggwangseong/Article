---
title: AWS SES 사용시 Production Access 요청
permalink: /AWS SES 사용시 Production Access 요청
tags:
  - aws
  - post
layout: page
image: 
category: AWS
description: AWS SES 사용시 Production Access 요청
---

## AWS SES 사용시 Production Access 요청

![[Pasted image 20250517135925.png]]

- 프로덕션 액세스 요청을 꼭 설정 해야 한다.


![[Pasted image 20250517141352.png]]

이런 문제가 발생했는데 MAIL FROM 도메인 설정을 해주어야 한다.

![[Pasted image 20250517141421.png]]

얘도 DNS 레코드 추가

- DKIM 레코드 추가
- MAIL FROM 도메인 레코드 추가
- DMARC 레코드 추가
- SPF레코드 추가

## 프로덕션 샌드박스에서 AWS에 프로덕션 액세스 요청 필요

- [공식문서](https://docs.aws.amazon.com/ses/latest/dg/request-production-access.html) 
- https://docs.aws.amazon.com/ses/latest/dg/creating-identities.html

## 확인 가능 사이트

- [https://www.learndmarc.com/](https://www.learndmarc.com/) 

```ts
 MessageRejected: Email address is not verified. The following identities failed the check in region AP-NORTHEAST-2: soaw83@gmail.com
    
```

**프로덕션 환경 인증을 하지 않으면 결국 에러가 무조건 발생한다** 

## EC2 CLI를 통해서 신청

```bash
aws sesv2 put-account-details \
  --production-access-enabled \
  --mail-type TRANSACTIONAL \
  --website-url https://www.daily-sentence.co.kr \
  --additional-contact-email-addresses soawn83@gmail.com \
  --contact-language EN \
  --use-case-description "We send weekly English sentences to subscribed users as part of a language learning project." \
  --region ap-northeast-2
```

**보통 1일에서 2일정도 걸린다!!! 후... 삽질 그만** 

## SMTP 설정

![[Pasted image 20250517141838.png]]

이건 지금 하는것과 별개다
**SES로 전송하는 방식과 SMTP로 보내는 방식 2가지가 있는가 보다** 


## Reference

- [https://docs.aws.amazon.com/ses/latest/dg/creating-identities.html](https://docs.aws.amazon.com/ses/latest/dg/creating-identities.html) 
