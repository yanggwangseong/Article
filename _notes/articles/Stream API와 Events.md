
- 왜 Stream 써야하는지?
	- https://nodejs.org/en/learn/modules/how-to-use-streams#why-use-streams
- event에서 async 동작
	- https://nodejs.org/api/events.html#asynchronous-vs-synchronous
- 배치 작업을 위한 event-emitter와 RxJS

```ts
@Injectable()
export class LikesBatchService implements OnModuleInit {
  constructor(
    @InjectRepository(Post)
    private postRepository: Repository<Post>,
    private eventEmitter: EventEmitter2
  ) {}

  onModuleInit() {
    fromEvent(this.eventEmitter, 'like.added').pipe(
      bufferTime(60000),
      filter(likes => likes.length > 0),
      mergeMap(likes => {
        return from(this.postRepository.update(
          { id: In(likes.map(like => like.postId)) },
          { likesCount: () => 'likesCount + 1' }
        ));
      })
    ).subscribe();
  }
}

// 좋아요 생성시
this.eventEmitter.emit('like.added', { postId });


```

- 버퍼링으로 DB 부하 감소
- 스트림 처리로 메모리 효율적
- `Cron` 데코레이터는 내부적으로 `setTimeout` 으로 실행 시킨다.
- 어차피 Rxjs에서 이벤트를 `bufferTime` 을 통해서 5초동안 모으니까 중복인 셈이다
- `Cron` 을 사용하면 배치작업이 없더라도 계속 5초마다 호출 주기가 될때마다 함수를 실행
- `Cron` 을 사용하면 외부 이벤트 저장소가 필요함.
- `RxJS` bufferTime 방식
	- 외부 저장소 필요없음.
	- 5초가 지나도 버퍼에 아무 이벤트가 없으면 그냥 빈배열을 내보내고 쓸데없는 배치 호출 최소화.



```ts
// 이벤트 손실 방지
await this.eventEmitterReadinessWatcher.waitUntilReady();
await this.eventEmitter.emit(
  'order.created',
  new OrderCreatedEvent({ orderId: 1, payload: {} }),
);

@OnEvent('order.created', { async: true })
handleOrderCreatedEvent(payload: OrderCreatedEvent) {
  // handle and process "OrderCreatedEvent" event
}
```


- NestJS EventEmitter, CQRS
- https://medium.com/@jnso5072/node-js-eventhandler%EB%8A%94-%EB%B0%B1%EA%B7%B8%EB%9D%BC%EC%9A%B4%EB%93%9C%EC%97%90%EC%84%9C-%EC%9E%91%EB%8F%99%ED%95%A0%EA%B9%8C-612355714c59

