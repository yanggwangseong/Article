---
title: Promise
permalink: /nodejs/promise
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

```js
// Promise
function handler() {
  return validateParams()
    .then(dbQuery)
    .then(serviceCall)
    .then(result => {
      console.log(result);
      return result;
    });
}

// async functions
async function handler() {
  await validateParams();
  const dbResults = await dbQuery();
  const results = await serviceCall(dbResults);
  console.log(results);
  return results;
}
```

- 비동기 함수를 사용하면 실행이 여전히 비동기적임에도 불구하고 코드가 더 간결해지고 제어 및 데이터 흐름을 훨씬 더 쉽게 따라갈 수 있습니다.


> pending, fulfiled, reject
> resolved, rejected
> thenable
> event loop microtask queue macro taskqueue

## Async functions
https://v8.dev/blog/fast-async#async-functions





# Reference

- [https://v8.dev/blog/fast-async](https://v8.dev/blog/fast-async)
- [https://developer.mozilla.org/ko/docs/Web/API/ReadableStream](https://developer.mozilla.org/ko/docs/Web/API/ReadableStream) 
- [https://developer.mozilla.org/ko/docs/Web/JavaScript/Reference/Global_Objects/Promise](https://developer.mozilla.org/ko/docs/Web/JavaScript/Reference/Global_Objects/Promise) 
- [https://developer.mozilla.org/ko/docs/Web/JavaScript/Reference/Statements/async_function](https://developer.mozilla.org/ko/docs/Web/JavaScript/Reference/Statements/async_function) 
- [https://alishabhale.hashnode.dev/mastering-promises-in-javascript-a-deep-dive](https://alishabhale.hashnode.dev/mastering-promises-in-javascript-a-deep-dive) 
- [https://blog.stackademic.com/asynchronous-javascript-a-deep-dive-into-promises-1ef79d9758c6](https://blog.stackademic.com/asynchronous-javascript-a-deep-dive-into-promises-1ef79d9758c6) 
- [https://medium.com/node-gem/learning-v8-tasks-microtasks-f384ec68ac63](https://medium.com/node-gem/learning-v8-tasks-microtasks-f384ec68ac63) 
- [https://mathiasbynens.be/notes/async-stack-traces](https://mathiasbynens.be/notes/async-stack-traces) 
- [https://blog.appsignal.com/2023/05/17/an-introduction-to-async-stack-traces-in-nodejs.html](https://blog.appsignal.com/2023/05/17/an-introduction-to-async-stack-traces-in-nodejs.html) 
- [https://preamtree.tistory.com/168](https://preamtree.tistory.com/168) 
- [https://v8.dev/blog/fast-async](https://v8.dev/blog/fast-async) 
- [https://exploringjs.com/js/book/ch_promises.html#ch_promises](https://exploringjs.com/js/book/ch_promises.html#ch_promises) 
- https://jakearchibald.com/2015/tasks-microtasks-queues-and-schedules/
- [https://promisesaplus.com/](https://promisesaplus.com/) 

