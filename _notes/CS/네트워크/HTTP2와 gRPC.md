
> http/1.1에서 client-server architecture를 사용하는 TCP 기반의 순차적인 데이터 송수신을 한다.
> 즉, 병렬적인 전송의 부재가 있다. 그러나 http/1.1에서 파이프라이닝 방식을 통해서 어느정도로 병렬처리를 제공 하는듯 했으나 결국에는 이 방식 자체가 HOL Blocking 문제가 발생하기 때문에 효율적이지 못한다.
> HOL Blocking문제, Paralle 하지 못하다. Plain Text (ASCII)으로 불필요한 공간 낭비. 머신 친화적이 못하다.

> 생각 해보니까 프론트엔드 개발자 입장에서 보았을때 js나 css 파일을 요청마다 받아오는 방식이면 그만큼 TCP/TLS 오버헤드가 발생 할 수 밖에 없는것 같다. 그래서 배포 환경에서는 하나의 js와 하나의 css 파일에다가 왕창 넣어서 하나만 가져오는건가? 당근마켓 랜딩 페이지에 css를 9개나 가져오네 흠.... 왜 하나로 번들링 안했을까 그래도 그나마 보니까 cloud front로 css 가져오게 CDN으로 되어있긴 한데 왜 9개? 아 하나로 번들링해서 배포를 하면 여러 당근마켓 개발자들이 css를 수정할때 전체 css가 다시 배포되는구나 아하


# HTTP/2

- multiplexing
- HTTP header compress
- request priority
- server push

> 내가 느끼는건 기존의 REST 원칙을 따르는 REST API와 HTTP 특징을 그대로 살리고 추상화된 Layer를 도입하여서 기존의 방식을 그대로 유지하고 확장성을 통해서 기능을 사용할 수 있게 제공 하는것 같다.


> AWS ALB, ELB 차이
> ALB는 Application Layer, http/2 지원
> ELB또는 CLB는 Network Layer, http/2 직접 세팅해야함
> 이전에는 왜 Network Layer 아아 흐름제어와 혼잡제어 메커니즘으로 쉽게 로밸 할 수 있구나.
> ALB는 어떻게 로밸 하는거지?
> ALB Application Layer에 있는건데 네트워크레이어에서 라우팅 알고리즘 돌겠지, 라우트 통로로 이제 트랜스포트 레이어에 TCP 소켓에 패킷 전달하겠지. 이해가 안가네.
> ALB -> 아하 약간 Application 앞단에 있는 새로운 Layer같은 느낌이네. 확실히 이렇게 하면 TCP 흐름제어는 거의 동작 안할 수 있는데 혼잡제어는 동작 하겠군.




# Binary Farming Layer



# Flow control

> HTTP/2를 사용하면 원래 기존의 Flow control은 transport layer 영역의 역할인데 Flow control을 할 수 있는 `WINDOW_UPDATE` Stream을 제공 하는것 같다.


# gRPC

- HTTP/2
- protobuf

## RPC

- RPC의 핵심 개념은 *Stub(스텁)* 이다.
	- RPC 메커니즘 자체가 IPC통신에서 메서드를 호출 할 수 있게 해주는 기능을 하는데 결국 다른 프로세스가 다른 프로세스의 메서드를 호출하니까 서로 다른 주소공간을 사용하니 함수의 매개변수를 꼭 변환해야하는데 이 역할을 하는게 Stub이다.
- Client Sub은 
	- 함수 호출에 사용된 파라미터의 변환을 Marshalling(마샬링)
	- 함수 실행 후 서버에서 받은 결과 변환
- Server Sub
	- 클라이언트가 전달한 매개변수의 Unmarshalling(언마샬링)
	- 함수 실행 결과 변환을 담당.

![[Pasted image 20250217223355.png]]

1. IDL(Interface Definition Language) 사용하여 호출 규약 정의.
	- gRPC로 치면 protobuf이다.
	- 함수명, 인자, 반환값 IDL 파일을 rpcgen으로 컴파일 하면 stub code가 자동 생성.
	- gRPC 기준으로 봤을때 protobuf 파일을 작성해서 컴파일 하면 그게 stub code가 자동 생성 되는것 같다.
2. Stub Code라는 녀석은 내가 이해하기로는 interface 역할을 하는것 같다.
	- 상세한 기능은 server에서 구현한다.
3. Client -> stub code에 있는 정의된 함수를 호출 -> client stub이 *RPC runtime* 을 통해 함수 호출
	- RPC runtime이 뭘까?
		- RPC Runtime을 통해서 데이터를 Transport Layer에서 송수신 하는거다.
		- RPC Runtime을 통해서 Transport Layer에서 데이터 송수신을 할 수 있는 것을 제공하는데
		- 이때 RPC Runtime은 기본적으로 내장되어 있는것이 아니라 RPC 프레임워크들이 RPC Runtime 라이브러리를 제공한다.
		- RPC Runtime Library의 핵심 개념은
			- Routines
			- Client Routines
			- Server Routines
			- Conversion Routines


# Reference

- [https://ably.com/topic/http2](https://ably.com/topic/http2) 
- [https://www.thewebmaster.com/what-is-http2-and-how-does-it-compare-to-http1-1/](https://www.thewebmaster.com/what-is-http2-and-how-does-it-compare-to-http1-1/) 
- https://evan-moon.github.io/2019/06/13/http2-with-aws/
- [크롬 개발자도구 Waterfall](https://hi-claire.tistory.com/9) 
- https://protobuf.dev/
- https://github.com/protocolbuffers/protobuf
- [RPC RFC1057](https://datatracker.ietf.org/doc/html/rfc1057?utm_source=chatgpt.com#appendix-A) 
- [NCP gRPC 1편](https://blog.naver.com/n_cloudplatform/221751268831) 
- [NCP gRPC 2편](https://medium.com/naver-cloud-platform/nbp-%EA%B8%B0%EC%88%A0-%EA%B2%BD%ED%97%98-%EC%8B%9C%EB%8C%80%EC%9D%98-%ED%9D%90%EB%A6%84-grpc-%EA%B9%8A%EA%B2%8C-%ED%8C%8C%EA%B3%A0%EB%93%A4%EA%B8%B0-2-b01d390a7190) 
- [RPC Runtime Library](https://sites.ualberta.ca/dept/chemeng/AIX-43/share/man/info/C/a_doc_lib/aixprggd/progcomc/rpc_lib.htm) 

https://engineering.linecorp.com/ko/blog/LINT-newtork-modernization-http2-tls

