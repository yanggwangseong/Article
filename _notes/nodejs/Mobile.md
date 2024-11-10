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

1. 대기 중인(pending) 프로미스는 값과 함께 이행(fulfilled)할 수 도, 어떤 이유(오류)로 인해 거부(rejected)될 수 도 있습니다.
2. fulfilled이나 rejected될 때, 프로미스 의 `then` 메서드에 의해 대기열(큐)에 추가된 처리기들이 호출 됩니다.
3. 이미 fulfilled 했거나 rejected 프로미스에 처리기를 연결해도 호출됩니다.
4. 프로미스가 이행되거나 거부 되었지만 보류 중이 아닌 경우, 프로미스가 확정된 것으로 간주합니다.
	- 확정(Settled)된 프로미스는 "더 이상 상태가 변경되지 않는 상태"를 말합니다. 즉, 프로미스가 이행(Fulfilled)되었거나 거부(Rejected)된 상태를 의미합니다.

- States (상태): 프로미스의 현재 상태를 나타냅니다. **Pending**, **Fulfilled**, **Rejected**의 세 가지 상태가 있으며, 상태는 **시간에 따라 변할 수 있습니다**.
- Fates (운명): 프로미스가 **최종적으로 어떻게 처리되었는지**를 나타냅니다. **Resolved** 또는 **Unresolved**가 있으며, 한 번 **Resolved**되면 더 이상 상태가 변경되지 않습니다.
- Settled (확정) :  
	- 단순히 **Pending이 아닌 상태**를 나타내며, 이행(Fulfilled) 또는 거부(Rejected)된 상태입니다.
	- `then` 이나 `catch` 를 여러번 호출 하더라도, 결과는 동일하게 유지됩니다.
	- 즉, 한번 확정된 이후의 **상태는 불변하며, 이미 결과값이나 오류** 가 결정되었기 떄문에 언제든지 그 값을 참조 할 수 있습니다.

```js
const promise = new Promise((resolve, reject) => {
  setTimeout(() => {
    resolve("Success!");
  }, 1000);
});

promise.then((result) => {
  console.log("First then: ", result); // "First then: Success!"
});

// 추가로 then을 호출하면, 동일한 결과가 출력됩니다.
promise.then((result) => {
  console.log("Second then: ", result); // "Second then: Success!"
});
```

- Promise에서 resolve를 실행해서 현재 States가 `Fulfilled` 가 되고 Fates가 `Resolved` 가 되어서 `Settled` 되어 상태는 불변하여 then을 호출하면 결과값이 결정 되었기 때문에 언제든지 그값을 다시 호출하면 같은 결과를 얻을 수 있다.
- **즉, `then` 이나 `catch` 그리고 `finaly` 를 계속 호출 할 수 있는 이유가 `Settled` 되었기 때문이다!**  
