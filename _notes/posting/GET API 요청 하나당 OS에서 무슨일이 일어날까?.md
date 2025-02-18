
```
(GET) /members/:memberId
json

GET 요청 하나에 OS에서 무슨일이 일어날까?

1. CPU Intensive
2. 컨텍스트 스위칭
3. 페이지 폴트율
4. 콜스택
5. 힙메모리
6. 시스템콜 함수
7. libuv FD(파일 디스크립터)
```

> authentication 할때 복호화 하는것은 CPU를 쓸 수 밖에 없고 작업이 끝난 후의 콜백은 micro taskqueue에 들어가고 CPU 제어권을 넘겨줌. 이걸 의미하는것이 non-Blocking임. 해당 부분은 sync로 동작 할 수 밖에 없음. sync라는것이 의미하는것은 그냥 순차적으로 처리한다는것이다. 로그인 사용자가 토큰이 유효한지 무조건 확인하고 다음 작업이 진행 되는것이니까 이것을 의미하는것은 sync 즉, 순차처리다. 그러니까 결국에는 개발자가 스스로 blocking, non-blocking, sync, async를 적절하게 선택해서 사용 하는 개념이다.
> 4개를 경우의수로 8개로 나눠서 이해 할 필요가 없다는 뜻이다.