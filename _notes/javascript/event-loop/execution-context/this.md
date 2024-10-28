---
title: this
permalink: /javascript/event-loop/execution-context/this
---

# this
- 실행 컨텍스트가 실행 될때 함께 결정된다.
	- 즉, 함수를 호출할 때 결정된다.
- 전역 공간에서의 this는 전역객체(window, global)를 참조
- 어떤 함수를 메서드로서 호출한 경우 this는 메서드 호출 주체(메서드명 앞의 객체)를 참조
- 어떤 함수를 함수로서 호출한 경우 this는 전역 객체를 참조. 메서드의 내부함수에서도 동일하다.
- 콜백 함수 내부에서의 this는 해당 콜백 함수의 제어권을 넘겨받은 함수가 정의한 바에 따르며, 정의하지 않은 경우에는 전역 객체를 참조.
- 생성자 함수에서의 this는 생성될 인스턴스를 참조.

# this가 달라지는 상황
- 전역 공간에서의 this
- 함수 호출시
- 메서드 호출시
- callback 호출시
- 생성자 함수 호출시
## 전역 공간에서의 this
- 전역 공간에서 this는 전역객체를 의미한다.
	- window, global === this.
	- `JS의 모든 변수는 실은 특정 객체의 프로퍼티로서 동작하기 때문에` 
## 함수 메서드 호출시
- 일반 함수 표현식이든 함수 선언문이든 일반 함수로 호출시 전역 객체를 가리킨다.
	- `this는 전역 객체를 가리킨다.`
	- strict mode 에서는 `this는 undefined` 가 된다.
- 메서드로 호출시 `this는 메서드 호출 주체 (메서드명 앞)를 가리킨다` 
- 화살표 함수로 호출시 `this는 스코프체인상 가장 가까운 this를 가리킨다` 

```js
// 메서드로 호출과 함수 선언문으로 함수 내부에서 함수 호출
var d = {
	e: function() {
        console.log(this); // (1)
		function f(){
			console.log(this); // (2)
			const arrowD = () => {
				console.log(this); // (3)
			}
			arrowD();
		}
		f(); 
		const arrowF = () => {
			console.log(this); // (4)
		}
		arrowF();

		// 함수 표현식
		var func = function(){
			console.log(this); // (5)
		}
		func();

		var obj2 = {
			innerMethod: func
		}
		obj2.innerMethod(); // (6)
	}
}
// d.e();

const { e } = d;
e(); // (7)
```

1. (1) d의 메서드로 e함수를 호출 하고 있기 때문에 메서드 호출 주체 d를 가리킨다.
	- { e: f }
2. (2) 함수 선언문을 통해서 this를 호출 하고 있기 때문에 전역 객체를 가리킨다.
	- window, global
3. (3) 화살표 함수를 통해서 this를 호출 하고 있기 때문에 자신의 this는 존재하지 않고 상위 스코프의 this를 바인딩 받는다. - f함수의 this 전역 객체를 가리킨다.
	- window, global
4. (4) 화살표 함수를 통해서 this를 호출 하기 있기 때문에 자신의 this는 존재하지 않고 상위 스코프의 this를 바인딩 받는다. - e 메서드의 this 를 가리킨다.
	- { e : f }
5. (5) 함수 표현식으로 선언 되었더라도 일반 함수로 호출하기 때문에 this는 전역 객체를 가리킨다.
	- window, global
6. (6) 이 함수는 호출할 때 함수명인 `innerMethod` 앞에 점(.)이 있었으므로 메서드로서 호출
	- { innerMethod: f }
7. (7) 객체 디스트럭쳐링을 통해 메서드를 분리하면, 메서드와 원래 객체 간의 연결이 끊어지기 때문에 일반 함수 호출로써 호출 된다.
	- 즉, 다시 e가 호출 되어서 1 ~ 6번이 실행 되는데 1~5번까지는 모두 전역객체를 가리키지만 6번은 obj2의 메서드로써 호출 되기 때문에 `this가 obj2를 가리킨다` 
	- (1) : 전역객체
	- (2) : 전역객체
	- (3) : 전역객체
	- (4) : 전역객체
	- (5) : 전역객체
	- (6) : { innerMethod : f } 

### 메서드 내부함수에서의 this를 우회법
- 변수를 활용하는 방법
- 화살표 함수 사용
- 명시적 this지정 (call, apply, bind)

```js
var a = 10;
var obj = {
	a: 20,
	b: function() {
		var self = this;
		console.log(this.a); // 20

		function c() {
			console.log(self.a); // 20
		}
		c();
	}
}
obj.b();
```

## callback 호출시
> 함수 A의 제어권을 다른 함수(또는 메서드) B에게 넘겨주는 경우 함수 A를 콜백 함수라 합니다. <br>
> 기본적으로는 전역 객체를 참조하지만, `제어권을 받은 함수에서 콜백 함수에 별도로 this가 될 대상을 지정한 경우에는 그 대상을 참조 한다` 

```js
const callback = function() {
	console.dir(this);
};
const obj = {
	a: 1,
	b: function(cb){
		console.log(this); // (1) b를 메서드로써 호출 obj
		cb(); // (2) 일반 함수로써 호출 했기 때문에 global
	},
	c: function(){
		console.log(this);
	}
};
obj.b(callback);

setTimeout(callback, 100); // (3)

[1,2,3,4,5].forEach(function(x){
	console.log(this, x); // (4)
});

[1,2,3,4,5].forEach(function(x){
	console.log(this, x); // (5)
},[6,7,8]);

```

1. (1) obj의 메서드로 b를 호출 하고 있기 때문에 this는 obj를 가리킨다.
2. (2) 콜백함수의 호출부분을 보면 일반 함수로써 호출 했기 때문에 this는 전역 객체를 가리킨다.
3. (3) setTimeout의 첫번째 인자 콜백 함수 부분은 따로 this 바인딩 하지 않기 때문에 this는 전역객체
4. (4),(5) forEach에서는 this를 따로 지정 할 수 있게 thisArgs를 2번째 인자로 제공 한다.
	- (4) 지정 안하면 this를 전역 객체 : window/global
	- (5) 두번째 인자 thisArgs를 지정하면 지정한 값이 this가 된다. : `[6,7,8]` 


## 생성자 함수 호출시
- 셍성자 함수를 호출하면 해당 인스턴스가 this가 된다.



# 명시적 this 바인딩 
- call
- apply
- bind

```js
Function prototype.call(thisArg[, arg1[, arg2[, ...]]]);
Function prototype.apply(thisArg[, argsArray])
Function prototype.bind(thisArg[, arg1[, arg2[, ...]]]);
```

