---
title: V8 Object vs Map
permalink: /nodejs/v8-object-vs-map
---

# JS Object vs Python Dictionary

Javascript에서의 `Object` 는 일반적인 `Dictionary` 하고 다른데 무엇이 다른지 알아보겠습니다.

## 구조

`Python Dictionary`

- 해시 테이블로 구현되어 있습니다.

`JS Object`

- V8에서 초기 상태에서 속성 키가 많지 않거나 객체가 정적으로 사용할 경우 해시 테이블 형태로 최적화 합니다.
- 다수의 속성이 동적으로 추가될 때는 **히든 클래스(hidden classes)** 및 **속성 배열(elements kind)** 을 사용하는 등 V8엔진이 추가적인 최적화를 수행합니다.

## 키의 타입 제한

`Python Dictionary`

- 해시테이블의 키로 불변(immutable) 객체인 `str` , `int` , `float` , `tuple` 등을 키로 사용하여 해시값이 변경되지 않게 사용하여 테이블의 일관성을 유지 합니다.

`JS Object`

- **문자열과 심볼(Symbol)** 만 키로 사용할 수 있습니다.
- 숫자, 불리언 등 다른 타입을 키로 사용하게 되면 **문자열로 변환** 됩니다.
	- `obj[1]` 은 `obj['1']` 로 변환 됩니다.

## 프로토타입 체인과 상속의 영향

`Python Dictionary`

- 상속 개념이 없고, 독립적인 키-값 저장소로 사용 됩니다.
- 기본 구조가 단순하고 상속 체인이 없기 때문에 키 충돌 문제에 신경쓰지 않아도 된다.

`JS Object`

- 프로토타입 체인을 통해 다른 객체의 속성을 상속 받을 수 있습니다.
- 키를 조회할 때 프로토타입 체인을 따라가면서 상속된 속성도 접근할 수 있어, 예상하지 못한 키와 값이 존재 할 수 있습니다.

```js
// obj에 name 프로퍼티만 명시적으로 정의
const obj = {
	name: "Alice",
};

// 상속된 속성에 접근
console.log(obj.toString); // [Function: toString]
console.log(obj.hasOwnProperty); // [Function: hasOwnProperty]

// 명시적으로 정의하지 않았지만 상속받은 속성
console.log(obj.toString()); // [object Object]
console.log(obj.hasOwnProperty("name")); // true

// 예상치 못한 키와 값이 존재할 수 있음
console.log("toString" in obj); // true
console.log("hasOwnProperty" in obj); // true
```

> 이러한 특성을 가지는 이유는 바로 `__proto__` 도 객체이기 때문에 프로토타입 체인으로 `Object.prototype` 을 가지게 된다. 그래서 분명히 `name` 프로퍼티만 명시적으로 정의 했음에도 불구하고 프로토타입 체인상의 제일 최상위 `Object.prototype` 메서드들을 상속 받게 된다.




# Map vs Object

## 키의 타입

- Object
	- **키는 문자열(String) 또는 심볼(Symbol) 타입만 가능** 합니다.
	- 숫자나 다른 타입의 키를 사용하려고 하면 자동으로 문자열로 변환됩니다.
	- [ECMAScript 사양에 따르면, "The properties of an object are uniquely identified using property keys. A property key is either a String or a Symbol."](https://tc39.es/ecma262/#sec-object-type) 
- Map
	- **키로 모든 타입을 사용할 수 있습니다** 
		- 객체, 함수, 심지어 다른 Map도 키로 사용할 수 있습니다.
	- [MDN Web Docs에 따르면, "Map 객체는 키로 모든 값(객체와 원시 값 모두)을 사용할 수 있습니다."](https://developer.mozilla.org/ko/docs/Web/JavaScript/Reference/Global_Objects/Map) 

## 키의 순서 보장

- Object
	- `OrdinaryOwnPropertyKeys` 메서드를 사용하여 객체의 키를 반환 할 때 **키의 종류에 따라 순서가 다르게 적용** 되기 때문에, **일반적인 키 순서를 보장하지 않습니다** 
	- 정수 인덱스 키
		- 예: "0", "1", "2"
		- 배열의 인덱스와 유사한 형태의 **정수 인덱스 문자열** 키는 **숫자 순서로 정렬** 되어 반환 됩니다.
	- 문자열 키
		- **일반 문자열 키** 는 **정의된 순서로** 반환됩니다.
	- 심볼(Symbol) 키
		- 마지막으로 **심볼 키** 들이 반환 됩니다.
		- 심볼 키는 문자열 키와 별개로, 추가된 순서에 따라 반환 됩니다.
	- [OrdinaryOwnPropertyKeys 순서 규칙](https://tc39.es/ecma262/#sec-ordinaryownpropertykeys) 
- Map
	- V8 엔진에서 `OrderedHashTable` 을 사용하여 키-값 쌍을 관리하고, **삽입 순서** 를 유지 합니다.
	- **반복(iteration)** 시에 **키와 값이 삽입된 순서대로 반환** 되는것을 의미합니다.
	- [[V8-map-set]] 이전의 작성한 글을 참고하면 좋습니다.

### 예제 코드

```js
/*
* Object
*/
// 심볼 키 정의
const symbolKey = Symbol("symbolKey");

// 객체 정의: 심볼, 일반 문자열 키, 정수 인덱스 문자열 키 순서로 정의
const obj = {
  [symbolKey]: "심볼 값",
  "key": "일반 문자열 값",
  "2": "정수 인덱스 문자열 값 2",
  "1": "정수 인덱스 문자열 값 1",
  "0": "정수 인덱스 문자열 값 0",
};
// 모든 키와 값을 출력하기
const allKeys = Reflect.ownKeys(obj);
allKeys.forEach((key) => {
  if (typeof key === "symbol") {
    console.log(`[${key.toString()}]: ${obj[key]}`);
  } else {
    console.log(`[${key}]: ${obj[key]}`);
  }
});

/*
* 결과
* [0]: 정수 인덱스 문자열 값 0
* [1]: 정수 인덱스 문자열 값 1
* [2]: 정수 인덱스 문자열 값 2
* [key]: 일반 문자열 값
* [Symbol(symbolKey)]: 심볼 값
*
/
```

1. 정수 인덱스 문자열이 숫자 순서로 정렬되어 출력되고 
2. 정의된 순서로 문자열
3. 마지막으로 심볼이 출력되는것을 알 수 있다.

```js
/*
* Map
*/
// 심볼 키 정의
const symbolKey = Symbol("symbolKey");

// Map 정의: 심볼 키, 일반 문자열 키, 정수 인덱스 문자열 키 순서로 정의
const map = new Map();
map.set(symbolKey, "심볼 값");
map.set("key", "일반 문자열 값");
map.set("2", "정수 인덱스 문자열 값 2");
map.set("1", "정수 인덱스 문자열 값 1");
map.set("0", "정수 인덱스 문자열 값 0");

// for...of 루프를 사용하여 Map의 키-값 쌍 출력
for (const [key, value] of map) {
  console.log(`${String(key)}: ${value}`);
}

/*
* Symbol(symbolKey): 심볼 값
* key: 일반 문자열 값
* 2: 정수 인덱스 문자열 값 2
* 1: 정수 인덱스 문자열 값 1
* 0: 정수 인덱스 문자열 값 0
*/
```

- 삽입한 순서대로 데이터를 반환 하는것을 알 수 있습니다.

## 성능 측면

- Object : 키-값 쌍의 추가 및 삭제 시에 최적화되어 있지 않아 특히 많은 양의 데이터를 다룰 때 성능 저하가 발생할 수 있습니다.
- Map : 대량의 데이터 처리에 최적화되어 있어 추가, 삭제, 검색 작업에서 더 나은 성능을 보입니다.

## 프로토타입 체인 영향

- Object : 프로토타입 체인의 영향을 받기 때문에, 키로 사용하려는 이름이 프로토타입 체인에 존재하면 예기치 않은 동작이 발생할 수 있습니다.
- Map : 프로토타입 체인의 영향을 받지 않으며, 키로 사용된 값이 충돌할 위험이 없습니다.


# Map에서의 key 조회

- `OrderedHashTable` 형태로 구성되어 있어 **삽입 순서를 유지** 하면서 **해시를 기반으로 효율적인 접근** 이 가능하다.
- 평균 시간 복잡도 O(1)
- 최악의 경우 : O(N)

# Object에서의 key 조회

- 프로토타입 정보 레벨
	- 프로토타입 체인을 말하는것 같다.
- V8 히든 클래스
- elements kind

# Reference

[JS배열과객체가 어떻게 다양한 elements kinds로 처리 되는지](https://v8.dev/blog/elements-kinds) 
[Object의 속성 추가 및 삭제에 따른 히든 클래스 사용과 최적화 방식](https://v8.dev/blog/fast-properties) 
[https://www.zhenghao.io/posts/object-vs-map](https://www.zhenghao.io/posts/object-vs-map) 
[https://tc39.es/ecma262/#sec-object-type](https://tc39.es/ecma262/#sec-object-type) 
https://tc39.es/ecma262/#sec-map-objects