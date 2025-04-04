---
title: AWS-S3
permalink: /posts/AWS-S3
---

# 미리 알아두면 좋은 내용

- NestJS에서 multer와 multer-module을 통해서 s3에 어떻게 업로드 할까?
- S3 업로드 방법

# 직면한 문제

- 이미지 업로드를 S3로 변경 한 후에 `900KB` 이하의 작은 크기의 이미지 파일 3개정도를 준비하여 AWS의 요금 정책을 확인 해보고 적당한 request 수를 통해서 성능 테스트를 진행 하였다.
- 그렇게 많은 수의 reqeust 요청도 아닌데 CPU utilization이 100%를 넘어가며 서버가 죽어 버렸다.
- 프로파일링을 통해서 플레임 그래프를 분석
- aws sdk에서 제공하는 `signed` 함수 부분이 높은 CPU 이용률을 차지 했다.
- 요청을 보낼때 마다 항상 매번 새로운 signed를 해서 이는 어쩔수 없는 성능 트레이드 오프라고 생각 하였다.
- 그러나 궁금해서 signed 라이브러리의 코드를 찾아보았다.
- signed 하는곳에서 매번 하는게 아니라 signed를 캐싱하고 다르다면 새로 signed 하게 되어 있었다.
- 플레임 그래프에서 지속적으로 signed 하는 메서드를 호출 하는것을 봐서는 아무래도 캐싱이 전혀 되지 않는것 같다.
- signed 부분에 어떤것들을 통해서 하는지 확인해보자.


1. NestJS에서 플랫폼 express를 통하여 미들웨어인 `multer` 를 사용할때 전체적인 흐름도.
2. 현재 사용 하는 라이브러리들을 S3에 업로드시에 `900KB` 이하의 가벼운 이미지 파일들을 업로드 하는데 굉장히 높은 CPU 사용률로 인한 문제 설명과 응답 시간과 플레임 그래프를 통한 프로파일링 분석 결과정리.
3. 문제점 분석과 코드 링크들 첨부 해결 하기 위한 과정들 기록.
4. 해결 후 성능 개선에 대한 결과 데이터와 (RPS, 응답시간), 플레임 그래프 제공.
5. 업로드 하기 위한 다른 방법
	- 가장 대중화된 업로드 방법 Pre-signed URL를 클라이언트에게 제공하여 업로드
	- Pre-signed URL를 서버에서 발급 받아 레디스에 저장 해두고 서버에서 `http.post` 로 업로드 하는 방법.
		- NestJS에서 `multer-module` 로 사용하고 싶으면 multer 엔진 문서를 보고 `strage` 부분을 직접 구현 해야함.
		- @aws-sdk/client-s3 와 @aws-sdk/s3-request-presigner를 사용하여 signed url을 가져와서 서버에서 http요청으로 post로 이미지 업로드
6. 대용량 파일일때는 사용자에게 Pre-signed URL을 제공 해주고 AWS Multipart 업로드를 사용.
7. 결론) 백엔드에서는 Pre-signed URL를 클라이언트에게 전달 해주고 클라이언트가  `Stream` 방식으로 작은 파일 (프로필 이미지 등) 업로드 할것인가 AWS S3 MultiPart Upload 방식으로 대용량 파일 또는 여러 파일들을 업로드 할것인가를 상황에 맞게 선택 하는게 좋은것 같다.

