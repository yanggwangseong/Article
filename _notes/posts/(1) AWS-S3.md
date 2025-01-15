---
title: AWS-S3
permalink: /posts/AWS-S3
---

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


