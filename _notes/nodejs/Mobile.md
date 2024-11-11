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

### Promise chain

- `then` 
	- 2개의 인자를 받습니다.
	- 첫번째 `fulfilled` 경우에 대한 콜백 함수
	- 두번째 `rejected` 경우에 대한 콜백 함수
	- 각 `.then()`은 새로 생성된 프로미스 객체를 반환하며, 선택적으로 `chain` 에 사용할 수 있습니다.

1. 프로미스 체인에서 오류 처리

- 프로미스 체인에서는 각 `.then()`에서 이행된 값을 전달하고, 오류가 발생한 경우에는 `.catch()`에서 오류를 처리합니다.

2. 프로미스의 상태 변화에 따른 동작

- 프로미스 체인에서의 다음 프로미스의 상태는 이전 프로미스의 종료 조건(fulfilled, rejected)에 의해 결정됩니다.

3. 중첩된 프로미스와 스택 구조

- 프로미스 체인은 **서로 중첩**된 구조처럼 동작하며, 이는 **스택**과 유사하게 **가장 나중에 추가된 것이 먼저 실행되는 방식**을 따릅니다.

- 예를 들어 `(promise D, (promise C, (promise B, (promise A) ) ) )`와 같이 **안쪽에서 바깥쪽으로** 중첩된 구조로 볼 수 있습니다.

4. 이미 "Settled"된 프로미스

- 이미 **Settled된 프로미스**에 대해 `.then()`을 호출하면, 첫 번째 **비동기 기회**에 해당 핸들러가 실행됩니다. 이는 마치 `setTimeout(action, 0)`와 유사합니다. 즉, **비동기 큐에 추가되어** 실행된다는 의미입니다.

## Thenables

- 모든 프로미스와 유사한 객체는 Thenable 인터페이스를 구현합니다.
- thenable은 두 개의 콜백(하나는 프로미스가 이행될 때, 다른 하나는 거부될 때)과 함께 호출되는 `then()` 메서드를 구현합니다. 프로미스 또한 thenable입니다.
- 기존 프로미스 구현과 상호 운용하기 위해 언어에서는 프로미스 대신 thenables을 사용할 수 있습니다.

```js
const aThenable = {
  then(onFulfilled, onRejected) {
    onFulfilled({
      // thenable은 다른 thenable로 채워집니다.
      then(onFulfilled, onRejected) {
        onFulfilled(42);
      },
    });
  },
};

Promise.resolve(aThenable); // 프로미스는 42로 채워집니다.
```

## Promisification(프로미스화)

- 콜백을 받는 함수를 프라미스를 반환하는 함수로 바꾸는 것을 '프라미스화(promisification)'라고 합니다.
- 기능을 구현 하다 보면 콜백보다는 프라미스가 더 편리하기 때문에 콜백 기반 함수와 라이브러리를 프라미스를 반환하는 함수로 바꾸는 게 좋은 경우가 종종 생깁니다.


