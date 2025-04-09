---
title: 4장 네트워크 계층 Data Plane
permalink: /cs/network/top-down-approach/4장 네트워크 계층 Data Plane
tags:
  - Network
layout: page
---



- 포워딩과 라우팅 : Data Plane(데이터 평면), Control Plane(제어 평면), Management Plane(관리 평면)
	- 라우터
		- 포워딩
			- 하드웨어에서 실행
			- 트랜스포트 레이어에서 패킷이 들어오면 이걸 어디로 보낼지 분류 해주는 역할을 한다.
			- forwarding table(포워딩 테이블)
				- 라우터는 도착하는 패킷 헤더의 필드값을 조사하여 패킷을 전달한다.
					- 예를 들어 도착 패킷 헤더값 `0110` 
				- 이 값을 라우터의 포워딩 테이블의 내부의 헤더값 필드에 `0110` 을 찾는다.
		- 라우팅
			- 소프트웨어에서 실행
		- 이해하기 위해 쉽게 설명
			- 포워딩 - 인풋으로 들어온것을 아웃풋으로 전달하는것.
			- 라우팅 - 라우팅 알고리즘을 통해서 포워딩 테이블을 채워놓는 역할을 한다.
- Network layer service models
	- best-effort service (최선형 서비스)
- Datagram forwarding table
- Longest prefix matching
- Switching
	- Memory
	- Bus
	- 상호연결 네트워크
- 라우터 내부
	- 큐잉
		- 입력 큐잉
		- 출력 큐잉
	- 얼마나 많은 버퍼
	- 패킷 스케줄링
- Internet Protocol(IP)
	- *라우터들이 IP패킷만 이해할 수 있다* 
	- 네트워크계층에서 트랜스포트에서 내려온 TCP 세그먼트를 IP 헤더와 함께 감싸서 *IP 패킷(IP Header + TCP 세그먼트)* 를 만든다.
	- 네트워크에서 IP패킷들중에 40byte로 헤더만 왔다 갔다 하는 패킷들이 많이 발견 된다.
		- ACK패킷이다.

```ts
Application Layer       →  데이터 생성
Transport Layer (TCP)   →  TCP 헤더 추가  →  TCP 세그먼트 생성
Network Layer (IP)      →  IP 헤더 추가   →  IP 패킷 생성
Data Link Layer         →  이더넷 헤더 추가 → 이더넷 프레임 생성
Physical Layer          →  전기 신호 or 무선 신호로 전송
```

- IPV4 DataGram Format
	- Time-To-Live(TTL)
		- 해당 필드를 통해서 데이터그램이 네트워크에서 무한루프에 빠지는것을 방지한다.
			- 라우팅 루프
		- 어떻게?
			- 라우터가 데이터그램을 처리할때마다 감소한다.
			- TTL필드가 0이되면 라우터가 데이터그램을 폐기한다.
	- *32 bit source IP address* 
	- *32 bit destination IP address*
	- 보낼때 Fragmentation(단편화), 받을때 Reassembly(조립)
- IPV4 주소 체계
	- 32-bit number
	- 8-bit씩 4개로 만들었다.
	- 인터페이스가 1개라면 장치 1개의 IP주소 1개라고 이해해도 무방하나 인터페이스가 2개 이상인경우는 다르다.
	- 인터페이스가 2개이상인 경우의 대표적인 예가 라우터이다.
	- 즉, 라우터는 IP를 여러개를 가진다.
- Grouping Related Hosts
	- LAN (Local Area Network)
	- WAN (Wide Area Network)
	- 구조
	- 각각 host마다 ip를 할당 해주면 무슨 문제가 발생할까?
		- 라우터안에 포워딩 테이블이 있는데 엔트리를 해당하는 LAN에 보내준다.

```ts
// Grouping Related Hosts 구조

host       host        host               host         host        host
           LAN1                                        LAN2
        router     <- WAN ->     router    <- WAN ->     router

                          forwarding table
                          [1,2,3,4][<-----] 엔트리
                          [1.2.3.5][----->] 엔트리
                          [.......][......] 엔트리
                          [.......][......] 엔트리
```

- 즉, 해당하는 인터페이스로 보내기 위해서 포워딩 테이블에 엔트리 개수가 굉장히 많아지게 된다.
- 이문제를 해결하기 위해서 Hierarchiecal Addressing: IP Prefixes
- *Hierarchiecal Addressing: IP Prefixes*
	- *앞부분 Network* 를 통해서 인터페이스를 구분하여 해당하는 곳에 보내주는거다. 즉, 이걸 통해서 포워딩 테이블에 많은 수의 엔트리가 생성되는것을 막히 위함이 목적이다.
	- 뒷부분 *Host( 8bit)* 는 위에서 그림처럼 어떤 host인지 식별 할 수 있는 영역이다.
	- Network Id와 prefix는 동일한거라고 봐도 무방하다.

```ts
00001100 | 00100010 | 10011110  | 00000101
<------------------------------> <-------->
          Network (24 bits)      Host(8 bits)

// 표기 예시
12.34.158.0/24
24 bit prefix를 가진 2의 8승의 address

// 구하기
// /24는 앞 24비트가 네트워크 주소라는 뜻입니다.
// 12.34.158.0을 8비트씩 쪼개면:
00001100.00100010.10011110.00000000
Network Portion (24bit): `00001100.00100010.10011110`
Host Portion (8bit): `00000000`

// /16이라면 앞 16비트가 네트워크 주소라는 뜻입니다.
12.34.158.0/16

```

- *Scalability Improved* 
	- 이를 통해서 Scalability 해진것이다.
	- Number related hosts from a common subnet
		- 1.2.3.0/24 -> left LAN
		- 5.6.7.0/24 -> right LAN
		- 즉, 이를 통해서 포워딩 테이블에서 엔트 개수를 최소화 할 수 있게 되었다!

```ts
// Scalability Improved

host       host        host               host         host        host
           LAN1                                        LAN2
        router     <- WAN ->     router    <- WAN ->     router

                          forwarding table
                          [1,2,3,4/24][<-----] 엔트리
                          [5.6.7.0/24][----->] 엔트리
                          // 엔트리 개수 최소화
```

- 사람들이 이해하기는 쉽게 `/24` 방식으로 표기 하였지만 머신이 이를 이해하는것은 생각보다 쉽지 않다.
- IP Address and 24-bit Subnet Mask
- *Subnet Mask* 
	- Subnet Mask란
		- 책에서는 `/24` 슬래시 24를 서브넷 마스크라고 부른다고 한다.
		- IP prefix 방식을 머신이 이해할 수 있게 제공하기 위한것.
		- 머신입장에서 prefix가 어디까지 인지 알려주는 역할을 한다.
- IPV4 (32bit) 에서 IP 주소를 8bit로 4개를 나눈후에 바로 사용하는것이 아니라 앞부분 24bit부분을 Network Id 식별자 즉, prefix로 사용하고 뒤의 부분을 host 식별자로 사용한다.
- *그렇다면 무조건 Network Id(prefix)를 24bit로 고정 해서 사용하면 어떤 제약이 있을까?* 
	- host IP 부족 문제
		- 왜냐하면 host 식별자로 8bit밖에 쓰지 않으니까 뒤의 8bit로만 host를 식별 하니까 부족 문제가 발생한다.
		- 만약에 prefix가 24bit host가 8bit 였다가 host가 굉장히 많아 지게 된다면 prefix를 16bit로 줄이고 host를 8bit에서 16bit로 늘려주는 메커니즘이 필요하다.
- *Network Id(prefix)를 그럼 8bit로 가장 적게 설정 하면 어떤 제약이 있을까?* 
	- 전세계 네트워크에서 8bit 즉, 2의 8승개 밖에 존재하지 못하게 된다.
- **이러한 사안들이 공통적으로 강조하는 문제가 *고갈* 에 대한 키워드이고 그냥 많은 사람들이 인터넷을 IPV4를 사용하여 IPV4가 부족해진거구나가 아니라 정확히는 prefix와 host IP 부족문제라고 이해하는게 맞는것 같다**   
- 결국에는 최적화가 필요한 이유가 수동으로 prefix나 host를 조절 하거나 이제는 host가 16bit가 아닌 8bit여도 충분한 상황에서도 수동으로 조절해줄 관리자가 없다면 낭비될 가능성이 생긴다.  
- IP Address Allocation
	- *Classful Addressing* 
		- prefix를 8,16,24 bit로 제한 하고 이를 A,B,C 클래스 네트워크로 분류해서 사용하는 초창기 방식.
		- 초창기 MIT등에서는 24bit의 prefix를 가지는 특권을 누렸다.
	- *Classless Inter-Domain Routing (CIDR)* 
		- *핵심은 앞단의 Network Id(prefix)를 각 기관에 맞게 Dynamic하게 allocation 한다* 
		- CIDR 방법을 통해서 각 기관은 Address Block을 얻어야 한다. 이러한 Allocation을 관리하는 IPv4 주소를 관리하는 기관이 존재 한다. ISP에 Address Block을 제공하는 기관
			- 왜냐?
				- 결국에는 각 기관에 맞는 크기의 prefix를 제공 해주는 management가 필요하니까
		- Internet Corporation for Assigned Names and Numbers (ICANN)
			- 전체 관리하는 기관이 ICANN이다.
		- Regional Internet Registries (RIRs)
		- Internet Service Providers (ISPs)
	- *Dynamic Host Configuration Protocol (DHCP)*
	- *Network Address Translation (NAT)* 

> ICANN에서 각각의 지역에 준다.
> 서울지사, 도쿄지사, 뉴욕지사 등
> 여기서 또 각각의 지사들에서 업체에게 또 제공한다.
> 서울지사 -> SKT, LG, KT

- *forwarding table의 Entry는 Prefix 단위로 Entry가 생성이 된다* 
	- Separate Forwarding Entry Per Prefix
- Longest Prefix Match Forwarding
	- IP 주소를 라우팅할 때, Forwarding Table에서 가장 긴(정확한) Prefix를 가진 경로를 선택하는 방식
	- Destination-based forwarding
	- 결국 Prefix Matching이란것은 뒷부분과 상관없이 앞부분의 prefix만 맞는지 찾으면 된다.

```ts
// Longest Prefix Match Forwarding

                        forwarding table
                        4.0.0.0/8
destination             4.83.128.0/17               outgoing link
201.10.6.17       ->    201.10.6.0/23        ->     Serial0/0.1
                        126.255.103.0/24
//옥텟을 2진수로 각각 바꾸면된다.
201 (10진수) → 2진수 변환

- 201 ÷ 2 = 100 … 1
- 100 ÷ 2 = 50 … 0
- 50 ÷ 2 = 25 … 0
- 25 ÷ 2 = 12 … 1
- 12 ÷ 2 = 6 … 0
- 6 ÷ 2 = 3 … 0
- 3 ÷ 2 = 1 … 1
- 1 ÷ 2 = 0 … 1

201 = 11001001
```

- IPV4 주소는 "A.B.C.D" 형식의 4개의 Octet(옥텟)로 구성된 32비트 주소이다.
- 각 숫자는 10진수로 표현되지만, 내부적으로는 2진수(8bit)로 저장된다.
- 옥텟을 2진수로 바꾸지 않아도 10진수로도 prefix 맞는거를 통해서 *Prefix Match* 하는걸로 이해하면 된다.
- 위의 예제를 23이니까 옥텟을 2진수로 변환 하였는데 예를들어 아래의 `126.255.103.0/24` 를 기준으로 보면 *prefix (24bit)* `126.255.103` 이고 *host(8bit)* 니까 `0` 즉, Prefix Match은 앞의 `126.255.103` 을 찾아서 매칭 해주면 되는것이다.
- **Subnets** 
	- subnet이란?
		- Subnet, Network Id, Prefix 같은 맥락이다.
		- IP Address는 Subenet + host
		- router를 거치지 않고 접근할 수 있는 interface 집합

> 라우터
> 인터페이스가 여러개 있는 디바이스인데 인터페이스 만큼 IP 주소를 가진다. IP가 인터페이스를 지칭한다.
> 각각 인터페이스의 Subnet이 다르다. Prefix가 다르다, Network Id가 다르다.
> 이것이 라우터이고 host는 하나의 subnet에 속해 있게 된다.
> Subnet이랑 interface가 좀 헷갈리네. 
> Interface 물리적인 포트 
> Subnet IP 네트워크를 논리적으로 나눈것.
> IP Address Block

- IPv6
	- IPv4 주소의 고갈 문제를 해결 하기 위해서 등장했다
	- 등장한지 오래 되었으나 왜 현재도 아직까지 IPv4를 사용하나?
		- 라우터들은 IP패킷만 읽을 수 있다고 하였는데 이때 *라우터는 IPv4만을 읽을 수 있게* 설계 되었다.
		- 그렇기 때문에 IPv6로 변경하기 위해서 수많은 라우터들을 IPv6를 지원하는 라우터로 교체하는 비용이 발생한다.
		- 또한 라우터 소유자들이 새로운 라우터를 교체했을때 발생 하는 사이드이펙트를 감수 하고 싶지 않다.
- *Network Address Translation (NAT)* 
	- Private IP를 사용하는 내부 호스트들이 외부로 패킷을 전송할 때
		- NAT 장치(라우터)에서 출발지 IP를 Public IP로 rewrite합니다.
	- 외부에서 내부로 들어오는 패킷일때
		- NAT 장치는 목적지 IP를 내부 호스트의 사설 IP로 다시 변환합니다.
	- 출발지 IP와 목적지 IP는 헤더에 있다.
	- 목적은 IP 주소 재사용
		- private IP를 내부적으로만 사용하기 때문에 마음대로 여러 호스트에게 할당하고 외부 통신시에는 NAT 장치가 사용하는 public IP를 사용하여 주소 절약 효과가 있다.
	- NAT translation table
		- NAT translation table을 이용하여 내부 호스트(private IP와 Port)와 NAT 장치의 Public IP와 Port를 매핑 해둔다. *이를 PAT(Port Address Translation)* 이라고 한다.

```ts

Network Address Translation (NAT)

                   NAT translation table
        WAN side addr                   LAN side addr          
        138.76.29.7, 5001               10.0.0.1, 3345
        138.76.29.7, 5002               10.0.0.2, 3345
        138.76.29.7, 5003               10.0.0.3, 3345
        ...                             ...
```

- 출발지 주소, 도착지 주소
- 책에 예제에서 80으로 들어올때 라우터 2개(NAT 2개)예제 이해
- 반대로 나갈때 상황도 직접 그려 보면서 이해.
- NAT에서 포트로 구별한다는게 정확히 무엇을 뜻하는걸까?
	- 결국 WAN side addr는 public IP로 IP주소를 최대한 재사용 하는것이 NAT 메커니즘인데 LAN side addr에서의 private address는 여러개일때 같은 Public IP주소를 맵핑하면 당연하게 충돌 문제가 생긴다.
	- 그래서 Public Address에서 port를 기준으로 구분하는데 이를 *PAT(Port Address Translation)* 이라고 한다.

- *Dynamic Host Configuration Protocol (DHCP)*
	- Application Layer Protocol이다.
	- 브로드 캐스트(255.255.255.255)했을때 DHCP Server만 응답 할 수 있는 이유?
		- DHCP는 말그대로 프로토콜이며 DHCP 프로토콜을 서버가 처리할 수 있고 DHCP Discover 패킷을 수신하고 처리할 수 있기 때문이다.
		- 그렇다면 DHCP 서버를 직접 만들어서 브로드캐스트 255.255.255.255를 받아서 DHCP 프로토콜을 처리하고 DHCP Discover 패킷을 수신하고 ACK 할 수 있게 구현하면 DHCP 클라이언트에게 응답 할 수 있나?
			- 가능하다. 실제로도 DHCP Client는 여러 DHCP Server의 ACK를 받는다. 그렇다면 DHCP Client는 자신이 원하는 DHCP Server의 응답을 어떻게 구분할 수 있을까?
				- DHCP Client가 *Reqeust* 단계에서 DHCP Server를 선택해서 요청한다.
	- UDP로 진행된다.
		- 왜 UDP를 사용할까?
			- DBCP 클라이언트가 처음에 IP가 없기 때문에 handshake를 통한 TCP 사용이 불가.
			- IP를 이용한 인터넷 서비스는 best-effort service (최선형 서비스)로 신뢰성을 보장하지 않는 서비스이므로 다른 말로하면 신뢰성을 보장 하지 않아도 되기 때문에 빠른 UDP를 이용한다
	- DHCP Client가 최초로 접속 할때 IP주소가 없기 때문에 IP를 요청하기 위해서 불특정 다수가 수신 할 수 있는 브로드캐스트를 한다.
		- DHCP Discover 메세지 브로드캐스트(255.255.255.255) (IP 주소 요청)
	- 이때 수신은 다 할 수 있지만 이에 응답 할 수 있는것은 DHCP Server(공유기) 뿐이다.
	- DHCP Server가 DHCP Offer 메세지 응답 (사용 가능한 IP 주소 제공)
	- DHCP Client가 DHCP Request 메세지 전송 (IP 주소 할당 요청)
	- DHCP Server가 DHCP Ack 메세지 전송 (IP 주소 할당 완료)

> NAT는 네트워크 레이어의 라우터에서 public IP를 변환하는 역할을 수행하고 DHCP는 Application Layer에서 동작하고 IP 동적 할당의 역할을 사용자 Host에 직접적으로 IP를 동적으로 할당
> 그래서 이제 결국 내부적으로 NAT에서도 private IP를 할당 해주려면 내부적으로 사용하는 private IP를 동적으로 할당하는 역할을 하는게 DHCP

> 공공 와이파이에서 이 공공 와이파이를 관리하는 공유기가 DHCP Server라고 가정 했을때 
> DHCP가 굉장히 위험한것 같다고 생각이 드는게 DHCP가 공공 와이파이라고 해보죠. 특히나 와이파이가 비밀번호 설정이 되어있어서 (이게 이제 Request 보낼때 특정한 식별자 역할을 할것으로 예상됨) 근데 만약에 비밀번호가 설정 되지 않은 와이파이라면? 카페에서 사용자가 와이파이 연결을 누르면 이게 브로드캐스트일것이고 일반적으로 ACK가 더 빠른경우에 자동 연결 할것 같은데 아닌가요?
> 맞다. 악성 DHCP Server가 사용자를 쉽게 속일 수 있다. 특히나 비밀번호가 없는 와이파이가 가장 취약한데 비밀번호가 있는 와이파이는 결국 DBCP Client가 Request 보내는 과정에서 해당 DHCP Server를 식별해서 요청을 보내기 때문이다. 하지만 비밀번호가 없는 와이파이라면 이때, **가장 빠르게 DHCP Offer를 응답하는 DHCP 서버가 선택될 가능성이 큼**
> 비밀번호만으로 Rogue DHCP 공격을 차단 할 수 없다. 즉, 만약에 해커가 비밀번호를 알고 있으면 똑같은 상황이 발생한다.
> DHCP Snooping 기능 활성화 (관리자가 설정 가능)
> 기업 네트워크에서는 **DHCP Snooping**이라는 보안 기능을 사용하여, **신뢰할 수 있는 DHCP 서버만 허용**할 수 있음.
> 하지만 **일반적인 카페 Wi-Fi 공유기에는 해당 기능이 없음** 

# IPv6

- IPv4의 주소 고갈문제를 해결하기 위해서 등장했다.
- IPv6 DataGram format
	- 확장된 주소
	- 간소화된 40바이트 헤더
	- 흐름 레이블링
- IPv4에서 IPv6 전환 방법
	- 터널링

# SDN

- 일반화된 포워딩이 현대의 라우터가 일반화된 매치 플러스 액션 작업을 통해 방화벽과 로드 밸런싱을 쉽고 자연스럽게 수행 할 수 있도록 한다.

# MiddleBox

- 출발지 호스트와 목적지 호스트 사이의 데이터 경로에서 IP 라우터의 정상적이고 표준적인 기능과는 별도로 기능을 수행하는 모든 미들박스.
	- NAT 변환
	- 보안 서비스
	- 성능 향상



# 네트워크 계층 데이터 평면

- 포워딩
- 라우팅
- 라우팅 알고리즘
- 데이터 평면
	- DNS 데이터 평면
- 제어 평면
	- SDN 제어 평면

> 흐름도
> 애플리케이션 레이어 X n
> 트랜스포트 계층- 애플리케이션 레이어의 여러 애플리케이션들의 전송 계층이라고 이해하면 되고 다른 트랜스포트 계층과의 point-to-point 연결 역할을 한다.
> 네트워크 계층 - 라우터 지금 드는 이해로는 네트워크 계층은 통로,경로라고 이해된다.
> 네트워크 계층부터는 거의 하드웨어 장치에 대한 내용도 꽤 등장한다.
> APP -> Transport -> network (router) -> Transport -> APP

## IP datagram format

- time to live(TTL)
	- sender TTL 숫자를 적어서 보내면 라우터에서 포워딩할때 -1씩 갱신
	- 0이 되면 해당 패킷이 버려진다.
	- Round Trip Time이랑 비슷하면서도 조금 다른것 같다.
- source IP address
- destination IP adress
- 40byte 정체? -> 이미지나 비디오 다운로드 받을때 receiver 입장에서 계속 ACK 패킷을 줘야하니까
- 아아 이런부분들 때문에 혹시 P2P 방식으로 미디어 파일을 다운 받는건가.


## IP Address (IPv4)

- unique한 32-bit number
- ip 주소는 host를 지칭하는게 아니였다. -> IP 주소는 interface를 지칭한다.
- 와이파이를 생각 해보면 유동 IP이고 결국 이 IP 주소라는것이 host (스마트폰)을 지칭한다고 하기 어려운게 와이파이 주소를 가리키는게 맞으니까 결국 같은 와이파이를 사용하는 host들은 같은 IP를 가지고 있으니까 interface를 지칭한다.
- Internet Protocol Address

## Scalability

> 라우팅 테이블
> 계층형 Addressing : IP Prefixes
> 12.34.158.0/24 24-bit 앞부분의 prefix가 ip address라는 표시

## Scalability Improved

- Number related hosts from a common subnet
- subnet이란?
	- 서브네트워크로 네트워크 내부의 네트워크
	- 왜 필요할까?
		- 서브넷을 통해 네트워크 트래픽은 라우터를 통과하지 않고 더 짧은 거리를 이동하여 대상에 도달 할 수 있는 역할을 한다.
- subnet mask란?
	- IP Address와 비슷하지만 네트워크 내에서 내부적으로만 사용된다.
	- 라우터는 서브넷 마스크를 사용하여 데이터 패킷을 올바른 위치로 라우팅합니다.(약간 디멀티플렉싱 같은거군)
	- 서브넷 마스크는 인터넷을 통과하는 데이터 패킷 내에서 표시되지 않으며 이러한 패킷은 라우터가 서브넷과 일치하는 대상 IP 주소만 나타냅니다.
	- 머신 입장에서 이해하기 쉽게 제공하기 위한 역할로 이해하면 된다.
		- 어디까지가 네트워크 아이디인지 어디까지가 prefix인지

> 네트워크 안의 bit수를 어떻게 해야할까?
> 만약 네트워크 id를 24bit로 고정시켜 버리면 어떻게 될까?
> 결국 IP 주소가 부족하다.
> prefix 8비트 host 16비트 -> 전세계 네트워크에서 2의8승만큼만 존재한다.
> -> 고정비트로 해두게 되면 각 네트워크 기관마다 기준이 다르기 때문에 낭비되거나 부족하거나 하는 문제가 발생한다.


## Classless Inter-Domain Routing (CIDR)

> 우와 AWS에서 봤던 CIDR가 뭔가 싶었는데 이거였구나.

- 각 기관마다 기준에 따라 크기에 맞게 prefix를 유동적으로 제공
- ICANN에서 IP Address 32bit를 관리.


## Longest Prefix Match Forwarding

- 패킷 -> destination (201.10.6.17) -> 얘랑 맞는 prefix를 forwarding table에서 매칭 시킨다.
- *앞부분 21bit까지만 맞는녀석을 찾으면 된다 그게 prefix를 찾는 방법* 
- 라우팅 테이블이란?
	- 네트워크에서 목적지 주소를 목적지에 도달하기 위한 네트워크 노선으로 변환시키는 목적으로 사용.
	- 라우팅 프로토콜의 가장 중요한 목적이 라우팅 테이블의 구성이다.
		- TCP에서는 BGP 네트워크 프로토콜
		- UDP에서는 RIP 네트워크 프로토콜
- forwarding table이란?
	- 라우팅 테이블을 참조하여 만들어진 테이블로 많은 경로중에서 비용이 가장 작은 경로를 선택하는 라우팅 알고리즘을 통해 선택된 경로를 저장 해둔 테이블
- 라우터란?
	- interface = Ip address 여러개의 interface를 가진 디바이스가 라우터, 여러개의 IP Address를 가진 디바이스, 각각 interface의 서브넷이 다른데 그게 라우터. 여러개의 서브넷에 속해 있는 중간자 역할. (교집합)


# Subnets

> Subnet, prefix, network id 로 표현해도 동일하다.

- 같은 network Id를 가진 interface의 집합.

# Network Address Translation, NAT

> host들에게 내부적으로만 사용하는 고유 IP를 사용하고 외부로 나갈때는 외부에서 인식 할 수 있는 IP Address로 rewrite 해주는 장치다. 내부적으로 들어올때도 IP Address를 rewrite하여 내부적으로만 사용하는 고유 IP로 변환 해주는 역할도 한다.

- 네트워크 주소 변환
- 네트워크 내부적으로 유니크한 주소
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

# Dynamic Host Configuration Protocol

- DHCP란?
	- 동적 호스트 구성 프로토콜
	- IP 네트워크에 사용되는 네트워크 프로토콜이다.
	- DHCP는 IP 주소 및 기타 통신 매개변수를 네트워크에 연결된 장치에 자동으로 할당한다.
	- 대부분의 가정용 네트워크에서는 라우터가 IP주소를 장치에 할당하는 DHCP 서버의 역할을 한다.(가정용 기준으로는 공유기가 DHCP Server 역할을 할 수 도 있고 안할 수 도 있는거군)
	- DHCP 사용 없이는 수동으로 IP 주소를 할당해야 한다. (오... 공유기가 이런걸 해주는구나)

> 공유기에 LAN선을 통해서 맥북이랑 연결. 이때 맥북이 DHCP Client, 공유기가 DHCP Server, DHCP Client 맥북의 MAC 주소를 통해서 맥북이 DHCP Discover 메세지 브로드캐스트 (IP 주소 요청)
> 공유기(DHCP 서버)가 DHCP Offer 메세지 응답 (사용 가능한 IP 주소 제공)
> 맥북이 DHCP Request 메세지 전송 (IP 주소 할당 요청)
> 공유기가 DHCP Ack 메세지 전송 (IP 주소 할당 완료)
> 	여기서 ACK 패킷을 줄때 UDP로준다.
> 맥북이 IP 주소를 받아 네트워크 연결완료.

## DHCP 과정

1. Discover : UDP로 클라이언트가 IP 요청 브로드캐스트 (이게 뭐냐 모두에게 IP 요청을 보내는데 이때 DHCP Server만 응답 가능한거임)
2. Offer : UDP로 DHCP Server가 사용 가능한 IP 주소 제공
3. Request : UDP로 클라이언트가 특정 IP 요청.
4. ACK : UDP로 DHCP Server가 클라이언트에게 IP 확정 응답.

> 현실 예제로 이해해보자.
> 아빠(DHCP Server) 나 (DHCP Client)
> 아빠랑 나랑 지리산에 등산을 하러 올라간다. 
> 내가 먼저 올라가서 많은 아줌마 아저씨들 사이에서 아빠를 부른다. -> Discover : 브로드 캐스트
> 아빠만 응답한다. -> Offer
> 아빠한테 쉬었다 가자고 한다 -> Request
> 아빠가 알겠다고 응답한다 -> ACK


- DHCP
	- DHCP 서버를 사용하여 IP주소 및 관련된 기타 구성 세부정보를 네트워크의 DHCP 사용 클라이언트에게 동적으로 할당하는 방법을 제공하는 클라이언트/서버 프로토콜이다.
	- [DHCP에서 offer과정에서 unicast가 가능한 이유](https://sujinnaljin.medium.com/internet-protocol-dhcp%EC%9D%98-offer-%EA%B3%BC%EC%A0%95%EC%97%90%EC%84%9C-unicast-%EA%B0%80-%EA%B0%80%EB%8A%A5%ED%95%9C-%EC%9D%B4%EC%9C%A0-a560065a76e) 
- Broad Cast
	- 패킷을 전송 했을때 모든 server가 수신한다.
- 근데 여기서 DHCP만 응답을 하게 된다.
- DHCP는 왜 unicast와 broadcast 둘다 가능할까?
	- [DHCP unicast와 broadcast](https://velog.io/@hope1213/DHCP%EB%8A%94-%EC%A0%95%EB%A7%90-%EB%B8%8C%EB%A1%9C%EB%93%9C%EC%BA%90%EC%8A%A4%ED%8A%B8%EC%9D%BC%EA%B9%8C) 
- DHCP Server를 DHCP Client가 식별 할 수 있는것 같은데 왜 브로드캐스트 하는걸까?
	- 오오.... DHCP Client가 최초로 접속 할때 IP주소가 없기 때문.
	- 잠깐 그러면 IP주소가 없는데 DHCP Client가 브로드 캐스트 했을때 DHCP Server는 어떻게 찾는걸까?
		- MAC 주소와 브로드캐스트 주소를 통해서 Offer 하는것이다.
		- *DHCP Discover 패킷은 모든 네트워크 장치에게 전송되는 브로드캐스트 패킷이다* 
		- 이제 모든 네트워크 장치가 우선은 브로드캐스트를 받긴 받는거다.
		- 근데 여기서 이제 DHCP Server만 응답이 가능하기 때문에 이때 DHCP Server는 MAC주소를 통해서 DHCP Client를 식별 할 수 있는거다.

> 로컬 컴퓨터에서 만든 포트폴리오를 ip주소 기반으로 외부에 공유하기 힘든 이유가 DHCP와 NAT때문이다.
> 그래서 유동 IP를 가지고는 공유가 불가능하고 고정 IP로 바꿔주는 작업이 필요한거다.

## IP fragmentation , IP reassembly


- 라우터간에 전송시에 네트워크 링크의 MaxTransferSize(MTU)만큼 패킷이 잘려서 전송하게 된다.
- 즉, 너무 큰 패킷을 한번에 전송 할 수 없기 때문에 전송시에 fragmentation 하고 receiver 측에서 reassembly 하는 메커니즘이다.


```
// 기존
4000 byte (IP header 20 byte + DATA 3980 byte)

// 3개의 fragment packet
length = 1500 | ID = x | fragflag = 1 | offset = 0
legnth = 1500 | ID = x | fragflag = 1 | offset = 185 (1480/8)
legnth = 1040 | ID = x | fragflag = 0 | offset = 370 (2960/8)
```

- fragflag : 0이 마지막 조각이라는뜻 1은 뒤에 더 추가 조각들이 있다는뜻.
- offset : 
	- 첫번째 fragment 패킷은 offset이 0이다.
	- offset에 DATA부분의 byte 번호에 -8한 값을 offset에 적는다.
		- 실제로는 1500 byte - IP 헤더 20byte = 1480이 맞는데 여기에 -8한 값을 offset에 기록한다.
		- -8은 왜 할까?
			- -8 하는 의미는 비트로 변환 했을때 뒤에 3개를 생략 한다는뜻이다.
			- 결국 용도는 조금이라도 비트 수를 최소화 하기 위한 최적화 노력이다.
- 마지막 패킷의 legnth가 1020이 아니라 1040인 이유는 *마지막 데이터 크기가 1020byte*  3980 = 3980 - 2960 = *1020* 즉, 헤더 20byte + 데이터 1020byte = 1040byte length를 가진다.
- 만약에 2번째 fragment packet이 없어졌다면?
	- 이런 경우 때문에 IP 자체만으로는 신뢰성 있는 데이터 전송을 보장하지 않는다.
	- 이런 경우의 신뢰성 있는 데이터 전송을 하기 위해서 우리는 TCP를 함께 사용하는것이다.
	- *TCP/IP*


## Reference

- https://www.cloudflare.com/ko-kr/learning/network-layer/what-is-a-subnet/
- https://ko.wikipedia.org/wiki/%EB%9D%BC%EC%9A%B0%ED%8C%85_%ED%85%8C%EC%9D%B4%EB%B8%94
- https://inpa.tistory.com/entry/WEB-%F0%9F%8C%90-NAT-%EB%9E%80-%EB%AC%B4%EC%97%87%EC%9D%B8%EA%B0%80
- https://nordvpn.com/ko/blog/what-is-dhcp/

