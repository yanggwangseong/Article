---
title: mobile
permalink: /nodejs/mobile
---
# Promise

## Promise는 왜 등장 했을까?

- 프로미스가 등장하기 전에는 **콜백 기반 API가 비동기 코드** 가 사용 되었습니다.

```js
function handler(done) {
  validateParams((error) => {
    if (error) return done(error);
    dbQuery((error, dbResults) => {
      if (error) return done(error);
      serviceCall(dbResults, (error, serviceResults) => {
        console.log(result);
        done(error, serviceResults);
      });
    });
  });
}
```

- 이러한 방식으로 깊이 중첩된 콜백을 사용하는 특정 패턴은 코드를 가독성이 떨어지고 유지 관리가 어렵기 때문에 이를 **콜백 지옥** 이라고 불립니다.

이를 개선 하기 위한 `Promise` 와 `async await` 가 등장 했습니다.

## Promise

- 프로미스가 생성된 시점에는 알려지지 않았을 수도 있는 값을 위한 대리자로, 비동기 연산이 종료된 이후에 결과 값과 실패 사유를 처리하기 위한 처리기를 연결할 수 있습니다.
- 프로미스를 사용하면 비동기 메서드에서 마치 동기 메서드처럼 값을 반환 할 수 있습니다.
- **최종 결과를 반환하는 것이 아니고, 미래의 어떤 시점에 결과를 제공하겠다는 promise를 반환합니다** 

### Promise 상태

- 대기(pending) : 이행하지도, 거부하지도 않은 초기 상태.
- 이행(fulfilled) : 연산이 성공적으로 완료됨.
- 거부(rejected) : 연산이 실패함.

![](/assets/image13.png)
