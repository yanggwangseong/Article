---
title: AWS와 S3 업로드시 CPU Bound
permalink: /project/mokakbab/trouble-shooting/6
tags:
  - Troubleshooting
  - mokakbab
  - nestjs
  - s3
  - aws
layout: page
---

![](/assets/Mokakbab06.png)

## AWS와 S3 업로드시 CPU Bound

- 🐙 **[모각밥 프로젝트(GitHub)](https://github.com/f-lab-edu/Mokakbab)** 
- 📑 [**V1 프로젝트 리포트**](https://curvy-wood-aa3.notion.site/V1-192135d46c8f803caaa6f10c2faeb4b2?pvs=4) 

---

### 📚 Contents

1. 개요
2. 문제
3. 문제 해결 및 결과

---

### 개요

**Flow** 

- NestJS에서 multer 호출 multer에서 multer-s3 호출 multer-s3에서 lib-storage 호출
- lib-storage에서 업로드를 위한 AWS SDK JS 호출 -> `시그니처V4` 를 통해서 사용자 인증과 S3 업로드시에 항상 해싱하여 업로드

---

### 문제

파일 업로드시에 보안적인 이슈 때문에 해당 파일을 항상 암호화 하여 업로드 하기 때문에


---

### 문제 해결 및 결과

- 📘 **노션 결과 리포트**: [노션 결과 리포트 링크](노션 결과 링크)
- 🔗 **PR #123 이슈**: [해당 PR#123 이슈 링크](해당 Pr 이슈 링크)

https://github.com/f-lab-edu/Mokakbab/pull/82

파일 업로드시에 보안적인 이슈 때문에 해당 파일을 항상 암호화 하여 업로드 하기 때문에 추후에 성능 개선을 위해서는 서버 리소스를 늘리는 방법이 필요합니다.
