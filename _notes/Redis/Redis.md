
- Redis의 이벤트 루프는 `ae.c` 파일에 정의
- **파일 이벤트 처리**: 소켓의 읽기, 쓰기 등의 파일 디스크립터 이벤트를 처리합니다
- **시간 이벤트 처리**: 일정 시간이 지난 후 실행되어야 하는 작업을 관리합니다
- 이벤트 처리 메커니즘은 `select`, `epoll`, `kqueue`와 같은 운영체제의 멀티플렉싱 기능을 활용하여 구현

- https://app.codecrafters.io/walkthroughs/redis-event-loop
- https://github.com/redis/redis/blob/unstable/src/ae.c
- https://medium.com/better-programming/internals-workings-of-redis-718f5871be84

```
Redis 8의 iothread.c 파일을 뜯어보면 Redis 8 부터는 io-thread 기능이 좀 더 발전한 것을 알 수 있습니다. 클라이언트의 io multiplexing 을 Io thread에서 처리하고 실제 커맨드가 완성되면 이것을 main thread에서 처리하는 형태로 처리하고 있습니다.  
  
예전의 io-thread 모델보다 확실히 발전된 모습니다.(AWS의 ElastiCache가 이미 이런 구조)
```

# Memcached vs Redis

- 멘토님께 질문) 멤캐시와 Redis 선택 기준?
- 멘토님께 질문) 캐시에 대한 이해와 Redis의 트랜잭션을 써야 할 상황이 있나?
	- 내가 생각 하는것은 Redis에서 RDB/AOF를 사용할때 즉, 데이터를 영속성을 보장 할때 트랜잭션을 사용 해야될것 같고 그 이외에는 사용하지 않는게 맞지 않을까?
	- cache miss를 발생 시키는게 맞을것 같다.



# Reference

- [위키피디아 Redis](https://en.wikipedia.org/wiki/Redis) 
- [위키피디아 Memcached](https://en.wikipedia.org/wiki/Memcached) 

