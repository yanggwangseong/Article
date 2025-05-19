---
title: Authentication Authorization Deep Dive
permalink: /Authentication Authorization Deep Dive
tags: 
layout: page
image: /assets/Layered-Architecture-01.png
---

## Authentication Authorization Deep Dive

- 🐙 **[진행중인 프로젝트(GitHub)](https://github.com/yanggwangseong/daily-sentence-be)** 
- 🔗 **[PR #82 이슈 링크](https://github.com/f-lab-edu/Mokakbab/pull/82)** 

---

### 📚 Contents

1. 개요
2. 문제
3. 문제 해결 및 결과

---

## OpenID Connect(OIDC)

https://www.samsungsds.com/kr/insights/oidc.html


[Wikipedia Reply attack](https://en.wikipedia.org/wiki/Replay_attack) 

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
