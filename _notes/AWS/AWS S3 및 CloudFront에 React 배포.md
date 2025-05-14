
## 프론트

- **S3에 정적 파일 배포**
- **CloudFront 생성**
    - Origin → S3
    - Custom domain → `www.example.com`
    - TLS → **ACM (us-east-1)에서 발급**
- **Route53 연결**
    - `www.example.com` → CloudFront 도메인 (A 레코드, alias)

## S3에 배포파일

## CloudFront

## Route53





## Reference

- https://velog.io/@fkszm3/AWS-React-%EB%B0%B0%ED%8F%AC%ED%95%98%EA%B8%B0-S3-CloudFront-%EC%84%A4%EC%A0%95%EB%B6%80%ED%84%B0-https-%EB%B0%B0%ED%8F%AC%EA%B9%8C%EC%A7%80
- https://docs.aws.amazon.com/ko_kr/prescriptive-guidance/latest/patterns/deploy-a-react-based-single-page-application-to-amazon-s3-and-cloudfront.html
