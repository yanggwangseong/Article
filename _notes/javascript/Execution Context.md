---
title: Execution Context
permalink: /javascript/execution-context
---

# 실행 컨텍스트
- VariableEnvironment
	- environmentRecord (snapshot)
	- outerEnvironmentReference (snapshot)
- LexicalEnvironment
	- environmentRecord *(호이스팅)* 
	- outerEnvironmentReference *(스코프 체이닝)* 
- ThisBinding
	- 실행 컨텍스트의 thisBinding에는 this로 지정된 객체가 저장된다.
	- 실행 컨텍스트가 활성화 당시에 this가 지정되지 않은 경우 this에는 전역 객체가 저장(window, global)

# 실행 컨텍스트 생성
1. Environment Record 생성
	- 매개변수, 함수 선언, var로 선언된 변수를 수집하여 Environment Record를 구성
2. Outer Environment Reference 설정
	- 외부의 렉시컬 환경을 참조하기 위해 상위 Lexical Environment를 연결
3. Variable Environment 생성
	- Environment Record와 Outer Environment Reference 정보를 Variable Environment에 먼저 저장합니다.
4. Lexical Environment 생성
	- Variable Environment를 복사하여 Lexical Environment를 구성.
5. ThisBinding

# VariableEnvironment
- `VariableEnvironment` 에 담기는 내용은 `LexicalEnvironment` 와 같지만 최초 실행시 스냅샷 유지
- 실행 컨텍스트를 생성할 때 `VariableEnvironment` 에 정보를 먼저 담은 다음 그대로 복사해서 `LexicalEnvironment` 를 만든다.
- 이후에는 주로 `LexicalEnvironment` 를 사용한다.

# LexicalEnvironment
## EnvironmentRecord (호이스팅)
> 현재 문맥의 식별자 정보

- environmentRecord에 컨텍스트를 구성하는 함수에 지정된 매개변수 식별자, 선언한 함수가 있을 경우 그 함수 자체, var로 선언된 변수의 식별자등을 컨텍스트 내부 전체를 처음부터 끝까지 쭉 훑어나가며 순서대로 수집.
	- 이러한 수집 과정을 이해를 위해 *호이스팅* 이라고 하는데 이는 실제하는 현상은 아니다.
	- 호이스팅 : 현재 컨텍스트 식별자 정보들을 수집해서 `environmentRecord` 에 담는 과정.
	- let, const : Environment Record가 let과 const를 수집하고 Environment Record에 let과 const가 등록 되었지만 초기화 되지 않은 상태 이것을 TDZ에 갇힌다고 표현한다.
	- TDZ : 변수 선언과 초기화 사이의 상태.


```js
function a () {
	console.log(b);
	var b = 'bbb';
	console.log(b);
	function b() {}
	console.log(b);
}
a();
```

> EnvironmentRecord가 내부 전체를 처음부터 끝까지 쭉 훑어나가며 순서대로 수집 하기 때문에 아래와 같은 결과가 나온다.

```js title="호이스팅 결과"
function a () {
	var b;              // 수집 대상 1. 변수는 선언부만 끌어올림.
	function b() {}     // 수집 대상 2. 함수 선언은 전체를 끌어올림.

	console.log(b);     // (1)
	b = 'bbb';          // 변수의 할당부는 원래 자리에 남겨둔다.
	console.log(b);     // (2)
	console.log(b);     // (3)
}
```

> 결과
> (1) `[Function: b]` 
> (2) `bbb` 
> (3) `bbb` 
### 함수 선언문과 함수 표현식
```js
console.log(sum(1, 2));
console.log(multiply(3, 4));

function sum (a, b) {  // 함수 선언문 sum
	return a + b;
}

var multiply = function (a, b) { // 함수 표현식 multiply
	return a + b;
}
```

```js title="호이스팅 결과"
var sum = function sum (a, b) { // 함수 선언문은 전체를 호이스팅합니다.
	return a + b;
};
var multiply; // 변수는 선언부만 끌어올립니다.
console.log(sum(1, 2));
console.log(multiply(3, 4));

multiply = function (a, b){ // 변수의 할당부는 원래 자리에 남겨둔다.
	return a * b;
}
```

- 함수 선언문은 전체가 호이스팅 되므로 문제없이 실행 되어버린다.
- 함수 표현식은 변수 선언부만 호이스팅 되므로 `multiply` 에 값이 할당되지 않는다.
	- 비어 있는 대상을 함수로 여기고 실행하고 한 상황이다.
		- 즉, `not a function` 런타임 에러가 발생한다.


```js
scopeChainFunc();
function scopeChainFunc(){
	console.log("이게 왜 실행될까요?");
}
```

- Global 실행컨텍스트의 EnvironmentRecord에서 `scopeChainFunc` 함수 자체가 수집 되기 때문에 Global 실행 컨텍스트가 생성될때 `scopeChainFunc` 함수 전체가 수집 되기 때문에 scopeChainFunc이 실행되게 된다.
- Global 실행 컨텍스트가 생성될 때, 함수 선언이 먼저 수집되기 때문에 `scopeChainFunc()` 함수가 코드 순서와 관계없이 실행될 수 있습니다.
#### 결론
- 함수 선언문 사용은 굉장히 위험하다.
- 상대적으로 함수 표현식이 안전하다.

## Outer Environment Reference (스코프 체인)
> *외부 환경에 대한 참조*  (scope chain)
> 외부의 `LexicalEnvironment` 에 대한 참조
> 현재 문맥에 관련 있는 외부 식별자 정보
### Scope
- 변수의 유효범위.
- *ES5* 까지의 JS는 오직 함수에 의해서만 스코프가 생성됨.
- *ES6* 이후부터는 `let, const, class, strict mode` 를 통해서 블록 스코프 사용 가능.
### Scope-Chain
```js
var a = 1;
var outer = function () {
	var inner = function () {
		console.log(a);
		var a = 3;
	};
	inner();
	console.log(a);
};
outer();
console.log(a);
```
- inner
	- `LexicalEnvironment`
		- `environmentRecord`
		- `outerEnvironmentReference`
- outer
	- `LexicalEnvironment`
		- `environmentRecord`
		- `outerEnvironmentReference`
- 전역(Global컨텍스트)
	- `LexicalEnvironment`
		- `environmentRecord` 
- inner 컨텍스트에서 선언한 변수(environmentRecord가 수집한 변수)는 environmentRecord에 의해서 접근 할 수 있다.
- inner컨텍스트에서 -> outerEnvironmentReference를 통해서 outer라는 실행 컨텍스트를 참조 -> outer의 LexicalEnvironment 정보에 접근 가능.
- outer 컨텍스트에서 -> environmentRecord에 의해서 outer컨텍스트 내부에서 선언한 변수에 접근 가능
- outer 컨텍스트에서 -> outerEnvironmentReference를 통해서 글로벌컨텍스트를 참조
- outer 컨텍스트에서 -> 글로벌 컨텍스트의 전역 공간에서 선언한 변수에도 접근 가능.
- But, outer 컨텍스트에서 -> inner에서 선언한 변수들 접근은 못한다 -> 왜? -> outer컨텍스트에서 inner의 컨텍스트에 접근 할 수단이 없기 때문 -> 스코프 체인은 내부에서 외부로 탐색하지만 반대로 외부에서 내부로는 접근할 수 없기 때문에.
- 바깥쪽으로는 나갈 수 있는데 outerEnvironmentReference를 통해 안으로 들어갈 순 없다. -> 이걸 *변수의 유효범위(Scope)* 라고 할 수 있다.

> inner 함수에서 선언한 변수는 inner 함수 내부에만 국한 된다.
> > inner 컨텍스트의 environmentRecord는 오직 inner 안에서만 존재한다.
> outer 함수에서 선언한 변수는 outer 함수 내부와 inner함수 모두에 접근 가능
> > 글로벌 컨텍스트에서는 접근 불가
> 전역 컨텍스트에서 선언한 변수는 전역, outer, inner 다 접근 가능.


- 그래서 스코프 체인이 뭔데?
	- inner에서 어떤 변수를 찾으라고 하면?
		- 일딴 먼저 inner컨텍스트에서 `environmentRecord` 에서 해당 변수가 있는지 확인.
	- 만약에 inner에 없다?
		- 그러면 `outerEnvironmentReference` 를 타고 `outer` 에 있는 `LexicalEnvironment` 에서 `environmentRecord` 에서 해당 변수가 있는지 확인
	- 만약에 outer에도 없다?
		- 그러면 `outerEnvironmentReference` 를 타고 `global컨텍스트` 에 있는 `LexicalEnvironment` 에서 `environmentRecord` 에서 해당 변수가 있는지 확인.
- 이러한 과정을 *스코프 체인* 이라고 한다.
- 가장 먼저 찾아진 것만 접근 할 수 있는 개념 *shadowing* 이라고 한다.
	- shadowing이란?
		- 내부 스코프에서 동일한 이름의 변수가 선언될 경우 가장 가까운 스코프의 변수만 접근 가능한 것.


## ThisBinding
- 실행 컨텍스트의 thisBinding에는 this로 지정된 객체가 저장된다.
- 실행 컨텍스트가 활성화 당시에 this가 지정되지 않은 경우 this에는 전역 객체가 저장(window, global)



# 나의 코드의 실행 컨텍스트 그리기
```js
const globalVariable = "global";
const outerFunc = () => {

	const b = 2;
	
	const innerFunc = () => {
		const c = 3;
		console.log(b);
		console.log(c);
	}
	innerFunc();
}
outerFunc();
```

1. 글로벌 실행 컨텍스트 생성
	- 글로벌 실행 컨텍스트 LexicalEnvironment와 ThisBinding
	- 글로벌 실행 컨텍스트의 `environmentRecord` 에 { globalVariable, outerFunc } 식별자 수집.
	- 전역 컨텍스트 `outerEnvironmentReference` 에 아무것도 담기지 않는다.
	- ThisBinding : this -> 전역객체
2. 콜스택에 글로벌 실행 컨텍스트가 올라감.
3. outerFunc 함수 호출
4. outerFunc 실행 컨텍스트 생성
	- environmentRecord에 { innerFunc, b } 식별자 저장.
	- outerEnvironmentReference에는 글로벌 실행 컨텍스트의 LexicalEnvironment를 참조.
		- { globalVariable, outerFunc }
	- ThisBinding: this -> 화살표 함수로 자신의 this 가지지 않음 상위 스코프의 this 그대로 참조 -> 전역객체
5. 콜스택에 outerFunc 실행 컨텍스트가 올라감.
6. innerFunc 호출
7. innerFunc 실행 컨텍스트 생성
	- environmentRecord에 { c } 식별자 저장.
	- outerEnvironmentReference에 outerFunc 함수의 LexicalEnvironment를 참조
		- { innerFunc, b }
	- ThisBinding: this -> 화살표 함수로 자신의 this 가지지 않음 상위 스코프의 this 그대로 참조 -> 전역객체
8. 콜스택에 innerFunc 실행 컨텍스트가 올라감.
9. `console.log(b)` 출력 
	- innerFunc 실행 컨텍스트의 environmentRecord에서 찾음
		- 찾을 수 없음
		- innerFunc의 outerEnvironmentReference를 통해 outerFunc 함수의 LexicalEnvironment의 environmentRecord에서 찾음 -> 존재함
		- `console.log(b)` 정상 출력
10. `console.log(c)` 출력
	- innerFunc 실행 컨텍스트의 environmentRecord에서 찾음 -> 존재함.
	- `console.log(c)` 정상 출력
11. innerFunc 종료 
	- 콜스택에서 innerFunc 실행 컨텍스트 제거
12. outerFunc 종료
	- 콜스택에서 outerFunc 실행 컨텍스트 제거
13. 프로그램 종료
	- 콜스택에서 글로벌 실행 컨텍스트 제거

## 그림으로 표현
<img src="{{ site.baseurl }}/assets/execution-context.png"/>

# Reference
- ( http://dmitrysoshnikov.com/ecmascript/es5-chapter-3-2-lexical-environments-ecmascript-implementation/ )
- 코어 자바스크립트
- 모던 자바스크립트 DeepDive
