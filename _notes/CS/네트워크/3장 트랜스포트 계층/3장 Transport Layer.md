---
title: Transport Layer
permalink: /network/transport-layer
tags:
  - Network
---

- Transport Layer에서 프로토콜은 각기 다른 호스트에서 동작하는 애플리케이션 프로세스간의 logical communication(논리적 통신)을 제공한다.
- logical communication이란?
	- 애플리케이션의 관점에서 보면 프로세스들이 동작하는 호스트들이 직접 연결된 것처럼 보인다는 것을 의미한다.
- Transport Layer 프로토콜은 네트워크 라우터가 아닌 end system에서 구현된다.
- Network Layer 프로토콜은 host들 사이의 논리적 통신을 제공한다.

# UDP (User Datagram Protocol)

# TCP (Transmission Control Protocol)


- transport-layer-multiplexing (트랜스포트 계층 다중화)
	- host 대 host 전달, process 대 process 전달로 확장 하는것을 말한다.
	- end system사이의 IP 전달 서비스를 end system에서 동작하는 두 프로세스 간의 전달 서비스로 확장하는 것이다.

# Multiplexing과 DeMultiplexing

- Multiplexing이란?
- DeMultiplexing이란?

## 트랜스포트 레이어에서 다중화에 2가지 요구사항

1. 소켓은 유일한 식별자를 갖는다.
2. 각 세그먼트는 세그먼트가 전달될 적절한 소켓을 가리키는 특별한 필드를 갖는다.

# UDP

- Connectionless Trasnport (비연결형 트랜스포트)이다.
- connectionsless
	- no handshaking

## UDP 사용 케이스

- 무슨 데이터를 언제 보낼지에 대해 애플리케이션 레벨에서 더 정교환 제어
- 연결 설정이 없음
- 연결 상태가 없음
- 작은 패킷 헤더 오버헤드


UDP 혼잡제어 문제를 해결하기 위해서 적응 혼잡 제어를 수행.
UDP를 사용할 때도 신뢰적인 데이터 전송이 가능하다.


## UDP 세그먼트 구조

- 체크섬으로 어떻게 오류 검출의 하는지 6.2에 나온다.

## UDP 체크섬

- UDP 체크섬은 오류 검출을 위한것이다.


# Reliable Data Transfer

- rdt 1.0

# TCP

- TCP socket identified by 4-tuple
	- source IP address
	- source port number
	- dest IP address
	- dest port number

