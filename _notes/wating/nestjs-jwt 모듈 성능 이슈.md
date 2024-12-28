---
title: nestjs-jwt
permalink: /wating/1
---

# @nestjs/jwt 모듈 성능 이슈

- `@nestjs/jwt` 모듈은 내부적으로 `jsonwebtoken` 를 사용하는 해당 라이브러를 래핑한 모듈이라고 생각하면 된다.
- 즉 `jsonwebtoken` 라이브러리는 생각보다 매우 큰 느린 성능 이슈가 있었다.
- `verifyAsync` 를 할때 `createPublicKey` 를 호출하는데 해당 부분이 I/O 병목을 유발한다.
- `verify` 얘만 없으면 RPS 1000이상도 가는데 얘를 넣으면 RPS가 500이 한계다.

## 플레임 그래프

- 가장 높은 막대(최상단 프레임)는 CPU 시간을 가장 많이 차지하는 작업
	- CPU 병목
- 가로로 넓은 막대는 가로가 넓을수록 오래 실행된 작업이라는 뜻이다.
	- CPU 집약적이지는 않지만 대기 시간이 길거나 비동기 작업에서 병목이 발생 할 수 있는 경우를 나타낸다.
	- 쉽게 생각해서 I/O 병목

# Jwt에서 암호화와 키에 대해서

- HS256

- 하나의 secret key로 서명과 검증 모두 수행

- 키 관리가 단순함

- secret key가 노출되면 토큰을 위조할 수 있음

- RS256

- privateKey로 서명, publicKey로 검증

- 키 관리가 복잡함

- privateKey가 노출되어도 검증용 publicKey는 안전

![[Pasted image 20241227215020.png]]

## createPublicKey

- 대칭키, 비대칭키에 대한것이 있고
- 검증할때 항상 `createPublicKey` 를 호출 한다.
- HS256은 대칭키 알고리즘이므로 createPublicKey를 호출하지 않습니다. 단일 secret key만 사용하기 때문에 `createPublicKey` 를 호출 하지 않는다!
- 대칭키 알고리즘이 근데 보안적으로 안전하기 떄문에 모듈에 private key와 public key를 빌드 할때 미리 모듈에 넣어주면 사용 가능하다.


- [createPublickey 코드 위치](https://github.com/auth0/node-jsonwebtoken/blob/bc28861f1fa981ed9c009e29c044a19760a0b128/verify.js#L120) 
- JWT 모듈이 토큰을 검증할 때마다 이 문자열을 적절한 키 객체로 변환해야 합니다. JWT 라이브러리는 제공된 시크릿이 이미 KeyObject 인스턴스인지 확인하고, 아닌 경우 먼저 createPublicKey()를 사용하여 변환을 시도합니다.
- 즉 그냥 일반 문자열로 넣어두게 되면 `createPublicKey` 를 사용하여 변환을 시도하는거다.
- `secret`에 **문자열** 대신 **미리 만든 `KeyObject`**를 넣어주면   `createPublicKey` 호출을 피하기 


![[Pasted image 20241227223812.png]]

- `createPublicKey` 호출 제거 성공!!!!!!!!!!!!!!!!!! 
- jwtwebotken 라이브러리 이슈 `if (secretOrPublicKey != null && !(secretOrPublicKey instanceof KeyObject)) {` 

