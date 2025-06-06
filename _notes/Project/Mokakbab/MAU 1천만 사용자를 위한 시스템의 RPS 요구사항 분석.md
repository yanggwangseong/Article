---
title: MAU 1천만 사용자를 위한 시스템의 RPS 요구사항 분석
permalink: /project/mokakbab
tags:
  - mokakbab
  - post
layout: page
image: /assets/Mokakbab06.png
category: NestJS
description: MAU 1천만 사용자를 위한 시스템의 RPS 요구사항 분석
---

![](/assets/Mokakbab06.png)

## MAU 1천만 사용자를 위한 시스템의 RPS 요구사항 분석

MAU(월간 활성 사용자)가 1,000만 명인 상황에서, DAU(일간 활성 사용자)를 추산하기 위해서는 사용자들이 한 달 동안 얼마나 자주 서비스를 이용 하는지를 가정해야합니다.

현재 진행중인 모각밥 서비스가 함께 밥 먹을 사람을 모집하는 서비스이므로 사용 빈도가 매일처럼 매우 높지는 않을 것으로 예상할 수 있습니다. 보통 이런 이벤트성/목적성 서비스는 **한 사용자가 일주일에 2~3회 정도** 로그인할 가능성이 있다라고 가정해보겠습니다.

- **일주일에 2회 이용하는 경우** 
	- 한 달(약 4주) 동안 평균 8회 이용
	- → 평균 일간 방문수 = (8회 × 1,000만) / 30 = 2,670만 회
	- 다만, 한 사용자가 하루에 여러 번 방문할 가능성이 낮다고 보면, 고르게 분포된다고 가정할 때 DAU/MAU 비율은 약 2/7 = 28% 정도로 예측 해볼 수 있습니다.
	- **→ DAU = 1,000만 × 0.28 = 280만 명**  
- **일주일에 3회 이용하는 경우** 
	- 한 달 동안 평균 12회 이용
	- → DAU/MAU 비율은 약 3/7 = 43% 정도
	- **→ DAU = 1,000만 × 0.43 = 430만 명** 

| 주간 이용 빈도 | 월간 이용 횟수 (4주 기준) | 평균 DAU 계산 | DAU / MAU 비율 | 추정 DAU |
| -------- | ---------------- | --------- | ------------ | ------ |
| 주 2회     | 8회 (2×4주)        | 8회 ÷ 30일  | 약 28% (2/7)  | 280만 명 |
| 주 3회     | 12회 (3×4주)       | 12회 ÷ 30일 | 약 43% (3/7)  | 430만 명 |

두 가정 사이의 중간값을 취하면, DAU는 대략 **300만~400만 명** 정도가 될 것으로 추산할 수 있습니다. 즉, 사용자의 서비스 이용 빈도(일주일 23회)를 감안할 때, MAU 1,000만 명에 대해 DAU는 **약 300만400만 명** 정도일 것이라는 결론에 도달할 수 있습니다.

- **MAU (Monthly Active Users) 1000만 사용자를 위한 시스템의 RPS 요구사항 분석과 목표 설정**
    - MAU (Monthly Active Users) : 한달 동안 서비스를 이용한 고유 사용자 수
- **DAU(Daily Active Users, 일일 활성 사용자) : 300만 ~ 400만** 
	- 하루 동안 서비스를 이용한 고유 사용자 수
- **RPS (Requests Per Second, 초당 요청 수)** 
	- 시스템이 1초에 처리해야 하는 요청의 수로, 서비스 성능 목표를 설정할 때 중요한 지표

## 📌 평균 RPS 계산

DAU가 300~400만 명일때 평균 RPS를 계산 해보겠습니다. 그러기 위해서는 **1일 총 요청량이 필요합니다** 

서비스의 특성상, 사용자당 하루 평균 **약 30회 요청**(로그인, 게시글 조회 등)이 발생한다고 가정 해보겠습니다.


| DAU 기준 | 사용자당 하루 요청 수 | 1일 총 요청량 |
|----------|-----------------------|---------------|
| 300만 명 | 30회                  | 9,000만 회    |
| 400만 명 | 30회                  | 1억 2,000만 회 |

즉, 하루 동안의 요청량은 약 **9,000만~1억 2,000만 회**입니다.

### 📌 1일 평균 RPS

**하루(86,400초)로 나누면 다음과 같습니다** 

- `DAU 300만 명 기준`

![](/assets/Mokakbab05.png)


- `DAU 400만 명 기준`

![](/assets/Mokakbab04.png)

즉, 평균 RPS는 약 **1,000~1,400 RPS**로 계산됩니다.

## 🎯 성능 목표 설정

| 지표           | 추정 값                       |
| ------------ | -------------------------- |
| DAU          | 300~400만 명                 |
| 1일 총 요청량     | 9,000만~1억 2,000만 회         |
| 평균 RPS       | 약 1,000~1,400 RPS          |

서비스의 안정성과 원활한 운영을 위해서는 평균 트래픽 외에 **피크 타임을 고려**하여 시스템을 설계할 수 있지만 현재 프로젝트에서는 **평균 RPS만 목표로 설정** 하였습니다.

# Reference

- [당근마켓 NestJS 성능에 관한 아티클](https://medium.com/daangn/typescript%EB%A5%BC-%ED%99%9C%EC%9A%A9%ED%95%9C-%EC%84%9C%EB%B9%84%EC%8A%A4%EA%B0%9C%EB%B0%9C-73877a741dbc) 
- [샌드버드 MAU에 대한 최고의 가이드 아티클](https://sendbird.com/ko/blog/monthly-active-users-mau?utm_source=chatgpt.com) 
