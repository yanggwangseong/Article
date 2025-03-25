

# Stream API

- Stream API가 event-loop를 blocking 하는것을 완화 시켜주는 이유는 Stream API는 비동기적인 작업 병렬성을 제공하는 도구이다.
	- Stream API는 **전체 데이터를 한 번에 처리하지 않고**, **작업을 나눠서 비동기적으로** 처리하게 도와줍니다.
	- **병렬성을 제공한다**
		- **작업 병렬성** 또는 **데이터 병렬성** 
	- 즉, 큰 작업이나 큰 데이터 등의 큰 덩어리를 잘게 쪼개서 비동기적으로 처리 할 수 있게 되어서 비동기적인 작업을 제공하는게 핵심이다.
	- 데이터를 **조각(chunk)** 단위로 처리할 수 있게 해주는 API
	- 전체 데이터를 메모리에 올리지 않고, **조금씩 처리**함으로써 **메모리 효율**이 좋다.
	- **비동기적**으로 처리되기 때문에 Event Loop을 **오래 점유하지 않도록 도와준다** 
- 결국 이를 통해서 예를 들어 CPU Intensive한 작업이나 또는 콜스택에 너무 오래 걸리는 작업 같은 경우가 있다고 가정 했을 때 그만큼 CPU Intensive한 작업이 된다. 이런 경우 큰 덩어리의 데이터나 작업을 작은 조각인 **chunk** 단위로 나눠서 비동기적으로 처리하여 event-loop 블록킹을 최소화 할 수 있게 된다.
- 이러한 비동기적인 특성을 통해서 비동기적인 데이터 흐름을 다루는 라이브러리가 **RxJS** 가 있는데 이는 조금 다른게 RXJS는 Observable 기반으로 실제로 Node.js의 Stream API를 직접적으로 사용하는것은 아니고 Stream API처럼 동작하게 구현하여 Observable기반으로 비동기 스트림을 다룬다.
- RXJS
	- RxJS는 **비동기적인 데이터 흐름을 스트림(Streams)** 으로 다루기 위한 **라이브러리**
	- **Observable** 기반이다.
- [koJSinfo proxy](https://ko.javascript.info/proxy) 
- [koJSinfo Observable 만들기](https://ko.javascript.info/task/observable) 

- `pipeline`, `Transform Stream`, `backpressure`
