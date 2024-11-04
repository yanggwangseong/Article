---
title: Closure
permalink: /javascript/event-loop/execution-context/closure
---
- [[Execution Context]]
# Closure
- 어떤 함수 LexicalEnvironment의 environmentRecord에 있는 지역 변수를 내부함수가 outerEnvironmentReference를 통해 참조하는 내부 함수를 외부로 전달 할 경우, 어떤 함수의 실행 컨텍스트가 종료된 후에도 해당 지역 변수가 사라지지 않는 현상.
- 내부함수를 외부로 전달하는 방법에는 함수 return, 콜백으로 전달.
- 어떤 함수에서 선언한 변수를 참조하는 내부함수에서만 발생하는 현상.
	- 외부 함수의 `LexicalEnvironment` 가 가비지 컬렉팅되지 않는 현상.
- 가비지 컬렉터가 어떤 값을 참조하는 변수가 하나라도 있다면 그 값은 수집 대상에 포함시키지 않아서 발생한다.

```js
var outer = function() {
	var a = 1;
	var inner = function() {
		return ++a;
	};
	return inner;
}
var outer2 = outer();
console.log(outer2()); // 2
console.log(outer2()); // 3
```

- outer 함수가 실행되면 outer 함수의 실행 컨텍스트가 생성된다.
	- outer 함수의 LexicalEnvironment에서 EnvironmentRecord에 { a, inner: f } 수집된다.
- outer 함수가 호출되면서 inner 함수를 반환하면서 종료되지만, inner함수가 a를 참조하고 있으므로 outer함수의 LexicalEnvironment는 메모리에 남아 GC의 대상이 되지 않는다.
- outer2 변수에는 반환된 inner함수가 할당 됩니다. 이때 inner 함수는 a변수에 접근 할 수 있는 클로저를 형성하고 있다.
- outer2()가 호출되면 inner함수가 실행되어 a의 값이 1증가하고 , 그 결과 2를 반환.
- 다시 outer2()를 호출하면 a의 값이 다시 증가하여 3이 반환된다. 이는 inner 함수가 a를 계속해서 참조하고 있기 때문이다.
- 이러한 현상을 `클로저` 라고 한다. 함수가 선언된 당시의 Lexical Environment를 기억하고 그 환경의 변수에 접근할 수 있는 현상을 의미한다.

TODO 그림 필요.

```js
// 직접 만들어 보기 : 배열에 숫자값을 push하는 클로저
const outer = () => {
	const result = [];
	const inner = (num) => {
		result.push(num);
		return result;
	}
	return inner;
}
const closure = outer();
console.log(closure(3));
console.log(closure(4));
console.log(closure(5));
```
## 클로저 활용
1. 콜백 함수 내부에서 외부 데이터를 사용하고자 할 때
2. 접근 권한 제어(정보 은닉 캡슐화)
	- 함수에서 지역변수 및 내부 함수 등을 생성합니다.
	- 외부에 접근 권한을 주고자 하는 대상들로 구성된 참조형 데이터(대상이 여럿일 때는 객체 또는 배열, 하나일 때는 함수)를 return 합니다.
3. 부분 적용 함수
	- n개의 인자를 받는 함수에 미리 m개의 인자만 넘겨 기억시켰다가, 나중에 (n-m)개의 인자를 넘기면 비로소 원래 함수의 실행 결과를 얻을 수 있게끔 하는 함수
4. 커링 함수
	- 여러 개의 인자를 받는 함수를 하나의 인자만 받는 함수로 나눠서 순차적으로 호출될 수 있게 체인 형태로 구성한 것.



### 접근 권한 제어(정보 은닉)
```js
var outer = function () {
	var a = 1;
	var inner = function () {
		return ++a;
	}
	return inner;
};
var outer2 = outer();
console.log(outer2());
console.log(outer2());
```

### 부분 적용 함수
> bind 활용

```js
var add = function(){
	var result = 0;
	for (var i = 0; i < arguments.length; i++){
		result += arguments[i];
	}
	return result;
};
var addPartial = add.bind(null, 1, 2, 3, 4, 5);
console.log(addPartial(6, 7, 8, 9, 10));
```

### 커링 함수
```js
var curry3 = function (func) {
	return function (a) {
		return function (b) {
			return func(a, b);
		};
	};
};

var getMaxWith10 = curry3(Math.max)(10);
console.log(getMaxWith10(8)); // 10
console.log(getMaxWith10(25)); // 25
```

```js
const getInformation = baseUrl => path => id => `${baseUrl}${path}/${id}`;

const imageUrl = 'http://imageAddress.com/';
const productUrl = 'http://productAddress.com/';

// 이미지 타입별 요청 함수 준비
const getImage = getInformation(imageUrl);
const getEmoticon = getImage('emoticon');
const getIcon = getImage('icon');

const emoticon1 = getEmoticon(100);
const emoticon2 = getEmoticon(102);
console.log(emoticon1); // http://imageAddress.com/emoticon/100
console.log(emoticon2); // http://imageAddress.com/emoticon/102
```