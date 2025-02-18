
```
(GET) /members/:memberId
json

GET 요청 하나에 대해 송수신이 어떻게 이루어지는지 분석하려면:

1. TCP 3-way handshake 확인 (`SYN`, `SYN-ACK`, `ACK`)
2. GET 요청 패킷 확인
3. HTTP 응답 확인 (`200 OK` 응답)
4. TCP 재전송 또는 Dup ACKs 발생 여부 확인
5. TCP 윈도우 크기 (`receive window`) 및 흐름 제어 확인
```

- Round Trip Time
- 3-way-handshake delay
- 4-way-handshake delay
- timer expire
- dup ACKs
- send 와 ACK응답

> Timer Expire 발생 횟수 확인
> 필터
> tcp.analysis.retransmission || tcp.analysis.fast_retransmission

> Duplicate ACKs 확인
> 필터
> tcp.analysis.duplicate_ack

> 하나의 GET 요청을 위해 몇번 SEND & ACK이 발생했는지 확인
> `tcp.stream`을 통해 하나의 연결에서 얼마나 많은 `Send` 및 `ACK`가 발생했는지 확인할 수 있습니다.
> tcp.stream eq X
> 여기서 `X`는 GET 요청이 포함된 TCP 스트림의 ID입니다.
> `Follow TCP Stream` 기능을 사용하여 해당 요청과 관련된 모든 패킷을 쉽게 분석할 수 있습니다.

> 송수신 패킷 개수 확인
> GET 요청을 전송하는 패킷 개수:
> `tcp.len` 필드를 확인하여 하나의 TCP 패킷이 얼마나 많은 데이터를 포함하는지 분석합니다.
> 만약 TCP segmentation이 발생하면 요청이 여러 개의 패킷으로 나뉘어 전송됩니다.
> ACK 개수 확인
> 요청에 대한 `ACK`가 몇 번 반환되는지 확인하려면
> tcp.flags.ack == 1

