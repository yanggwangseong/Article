---
title: Authentication Authorization Deep Dive
permalink: /Authentication Authorization Deep Dive
tags: 
layout: page
image: /assets/Layered-Architecture-01.png
---

## Authentication Authorization Deep Dive

- 2주에 하나씩 FEATURE 1년 24개의 FEATURE

---

### 📚 Contents

1. 개요
2. 문제
3. 문제 해결 및 결과

---

## OpenID Connect(OIDC)

https://www.samsungsds.com/kr/insights/oidc.html

[Wikipedia Reply attack](https://en.wikipedia.org/wiki/Replay_attack) 

## Oauth2 깊은 동작 원리

- 로그인 버튼 클릭부터, 소셜 인증, 콜백 URL,  
- 세션 쿠키 생성, SSR에서의 getUser 호출까지  
- “내 눈 앞에서 어떤 값이 오가고,  
- 어떤 타이밍에 인증이 완성되는지”  
- 실제 동작과 시퀀스 다이어그램(표), 코드로 살펴보았어요.
- 직접 JWT 파싱, 토큰 검증, 세션 로직을 구현하지 않더라도  
- “브라우저 → 소셜 → 콜백 → 내 서버 → 세션 인증”
- https://www.youtube.com/watch?v=RqMuhxbtIWw


## Proxy Authentication


## Referesh Token 전략


## Web Authentication

![](/assets/web-authentication.gif)

### Cookies and Sessions  
  
This traditional approach stores session data on the server and uses a simple cookie on the client to reference it. When a user logs in, the server creates a session and sends back a session ID cookie. Every subsequent request includes this cookie, allowing the server to retrieve the user's session data.  
  
The benefit? Complete server-side control over user sessions. You can instantly revoke access by deleting the session. The downside? Scalability becomes challenging in distributed systems since sessions are tied to specific servers.  
  
### JWT  
  
JSON Web Tokens flip the script by storing all user information directly in the token itself. No server-side storage required. The token contains three parts: a header specifying the algorithm, a payload with user data, and a signature for verification.  
  
JWTs works well in distributed systems since any server can verify the token independently. However, this convenience comes with security considerations—once issued, JWTs are difficult to revoke, and token theft can be problematic.  
  
### PASETO  
  
If you want to avoid becoming a security incident case study, PASETO removes the ways developers typically mess up token-based auth.  
  
Platform-Agnostic Security Tokens deliver JWT's benefits without the vulnerabilities. JWT's flexibility has enabled real attacks—algorithm confusion exploits and weak configurations plague applications. PASETO eliminates these risks by enforcing secure defaults: one vetted algorithm per version, rigid token structure, and modern cryptography. You get stateless authentication without the cryptographic landmines.

![[Pasted image 20250530222321.png]]



---

## Reference

- https://auth0.com/docs/get-started/authentication-and-authorization-flow
- https://oauth.net/2/
- [kerberos 인증방식](https://gruuuuu.github.io/security/kerberos/) 
- [다이제스트 인증방식](https://feel5ny.github.io/2019/11/24/HTTP_013_01/) 
[HTTP authentication framework](https://developer.mozilla.org/ko/docs/Web/HTTP/Authentication#%EC%9D%BC%EB%B0%98%EC%A0%81%EC%9D%B8_http_%EC%9D%B8%EC%A6%9D_%ED%94%84%EB%A0%88%EC%9E%84%EC%9B%8C%ED%81%AC) 
			- 서버가 클라이언트에게 401 응답코드를 가지고 응답하며, 최소한 한번의 시도에 포함된 [www-Authenticate](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/WWW-Authenticate) 응답 헤더로 권한을 부여하는 방법에 대한 정보를 제공한다.
			- [Challenge-response authentication (시도-응답 인증)](https://developer.mozilla.org/ko/docs/Glossary/Challenge) 
				- 공격자가 이전 메시지를 듣고 나중에 다시 보내 원본 메시지와 동일한 자격 증명을 얻는 [Retry Attack](https://developer.mozilla.org/ko/docs/Glossary/Replay_attack) 방지
					- Retry Attack을 방지하기 위한 다이제스트와 kerberos,[retry-attack01](https://www.linkedin.com/advice/0/how-does-pkce-prevent-authorization-code-interception-attacks) , [retry-attack02](https://bluecheat.medium.com/oauth-2-1-pkce-%EB%B0%A9%EC%8B%9D-%EC%95%8C%EC%95%84%EB%B3%B4%EA%B8%B0-14500950cdbf) 
			- [Nginx와 Basic 인증으로 접근 제한하기](https://developer.mozilla.org/ko/docs/Web/HTTP/Authentication#nginx%EC%99%80_basic_%EC%9D%B8%EC%A6%9D%EC%9C%BC%EB%A1%9C_%EC%A0%91%EA%B7%BC_%EC%A0%9C%ED%95%9C%ED%95%98%EA%B8%B0) 
				- Basic schemes로 인증하게 되면 base65로 복호화가 가능하기 때문에 HTTPS/TLS를 통해서 Basic scheme와 함께 사용하고 Ngnix로 한번더 제한 할 수 있습니다.
		- [Proxy authentication](https://developer.mozilla.org/ko/docs/Web/HTTP/Authentication#%ED%94%84%EB%A1%9D%EC%8B%9C_%EC%9D%B8%EC%A6%9D) 
			- 프록시 서버가 유효하지 않은 인증 정보를 받는다면 401또는 407로 응답하여야 하고, 사용자는 새로운 요청을 보내거나 `Authorization` 헤더필드를 바꿀 수 있다.
			- [Proxy-Authorization](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Proxy-Authorization) 
			- [Proxy-Authenticate](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Proxy-Authenticate) 
			- [www-authenticate와 Proxy-authenticate 헤더](https://developer.mozilla.org/ko/docs/Web/HTTP/Authentication#www-authenticate%EC%99%80_proxy-authenticate_%ED%97%A4%EB%8D%94) 
			- [Authorization과 Proxy-Authorization 헤더](https://developer.mozilla.org/ko/docs/Web/HTTP/Authentication#authorization%EC%99%80_proxy-authorization_%ED%97%A4%EB%8D%94) 
