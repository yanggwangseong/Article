

> Anonymous User를 차단하는 방법
> XSS공격, CSRF공격, CSRF, cookie, same-site cookie, http only cookie, local storage
> IPv4, IPv6 NAT, Anonymous User, 라우트 장비, 앱에서는 디바이스 아이디

# Network Address Translation, NAT

- 네트워크 주소 변환
- 네트워크 내부적으로 유니크한 주소
- 살짝 이해가 안되는군.
- 느낌적으로는 AWS NAT Gateway가 이 원리를 사용하는것 같다.
- NAT, NAT translation table (포워딩 테이블이랑 좀 비슷한것 같은데)
- 포트 번호를 마치 IP주소처럼 사용한다. IP는 host 구분하고 포트 번호는 소켓을 분류 해야하는데 포트 번호를 마치 IP 주소처럼 사용해서 문제가 발생 할 수 도 있다.
- 사용자의 90%이상이 클라이언트 역할을 수행 하기 때문에 치명적인 문제가 발생하지 않는다.
- 즉, 원래 전이중연결로 사실 클라이언트도 서버역할을 둘다 수행 할 수 있는데 현대 http에서는 client-server architecture를 사용하기 때문에 해당 문제 자체가 크게 드러나지 않는다.

> IPv4 주소 고갈로 인해서 IPv6가 등장 2의 128승으로 엄청나게 많은 주소
> 현재도 왜 IPv4를 쓸까?
> 현재 존재하는 모든 라우터는 IPv4를 지원하는 라우터로 되어 있기 때문에 IPv6를 지원하려면 해당 라우터 장비를 교체 해야한다. AWS는 IPv6 라우터 장비를 교체 한거군.
> NAT 등장으로 어느정도의 주소 부족 문제를 완화하여 라우터 장비를 완전히 교체하는 비용이 발생 하니까 지금 현대에서 그냥 IPv4로 사용하고 있는거군.

- 컴퓨터 네트워킹에서 쓰이는 용어로, IP

> 질문
> 구글 서버에서 어떤 사용자가 마음에 안들어서 소스 IP를 차단
> NAT를 차단 했기 때문에 NAT ip들의 집단을 다 차단해버림.
> 이제 더이상은 IP 차단을 안한다!!! 해당 유저를 차단하는 방식.
> 웹 애플리케이션에서 그러면 IP차단을 하면 안되는거구나. 그러면 유저를 어떻게 차단하는지에 대해서 좀 알아볼 필요가 있을것 같다. 만약 서비스가 앱으로 운영 된다면 아무래도 디바이스 고유 토큰값이 있기 때문에 해당 디바이스 아이디를 차단하면 될것 같은데, NAT세상에서 웹 애플리케이션 유저는 어떻게 차단해야할까? 흠...
> 비로그인 서비스라고 해보자. 그러면 유저의 식별자가 없을것이고 *Anonymous 유저* 차단 방법이 모호하네.
> 아이디어가 딱히 떠오르지 않네. 사용자의 Mac주소를 알 수는 없을것이고 뭔가 중간의 라우트가 있으면 가능할것 같은데 즉, 라우터를 조작 가능해서 나의 백엔드에 추가 정보를 제공 하는 기능을 추가 할 수 있는 가정이면 가능, 그게 아니라면? 자 예를 들어 로그인 없는 누구나 접속 할 수 있는 사이드 프로젝트, 특정 사용자가 CSRF나 스크립트 삽입공격을 한다고 가정. 이걸 발견. 분명히 어태커는 좀비 PC일거고 IP를 차단하는건 의미가 없음 NAT기반의 세상이기 때문에 쿠키? 차라리 CSRF토큰을 통해서 차단하는건 어떨까
> IP + User Agent + CSRF토큰 이부분이 조금 애매한게 결국 CSRF토큰을 Anonymous 유저가 발급 받을 수 있어야 되는데 그말은 authentication 하지 않는거네.
> [web_authentication_API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Authentication_API)  라는게 존재한다!!!! 이걸로 차단 하면된다.
> [Credential Management API 기반](https://developer.mozilla.org/en-US/docs/Web/API/Credential_Management_API) 
> 이걸 주제로 아티클 1개 작성하면 될것 같다.
