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

## 프로토타입 체이닝을 통한 조회

```js
const obj = {
	name : "hello",
};

console.log(obj.toString); // [Function: toString]
```

> JS 객체는 **프로토타입 체인을 통해 키를 조회** 할 수 있습니다. 다음은 객체에서 `key` 조회시 프로토타입 체인을 사용하는 과정에 대한 설명 입니다.
 
1. obj에 `__proto__` 가 자동으로 생성 된다.
2. `console.log(obj.toString)` 을 출력 한다. `obj` 에 `toString` 프로퍼가 있는지 확인 한다.
	- `toString` key가 존재 하지 않는다.
3. obj의 `__proto__` 는 최상위 `Object.prototype` 을 참조한다.
4. 즉 obj는 `Object.prototype` 메서드를 사용 할 수 있다.
5. `Object.prototype` 에 `toString` 이 있는지 확인한다. -> 해당 key가 존재한다.
6. `obj(.__proto__)(.__proto__).toString` 을 console.log로 출력 한 것이다.
7. 여기서 `__proto__` 는 생략 가능하기 때문에 사용자는 `obj.toString` 으로 사용 가능하다.
8. 이처럼 해당 `key` 를 조회 하는데 객체의 `__proto__` 프로퍼티가 연쇄적으로 연결된 구조 프로토 타입 체인에서 객체는 자신의 프로토타입에 정의된 속성이나 메서드를 찾고 없다면 프로토 타입 체인 상의 상위 프로토타입에 정의된 속성이나 메서드를 찾는다. 이러한 과정을 **프로토타입 체이닝** 이라고 합니다.

## V8 Hidden class와 객체 프로퍼티 읽기

먼저 [ECMAScript 스펙에 따르면](https://tc39.es/ecma262/#sec-property-attributes) JS 객체는 key-value 쌍으로 이루어진 프로퍼티들의 집합 입니다.
이때 key의 타입에는 **문자열 혹은 Symbol** 이 가능하며 key는 `property attribute` 라는 value에 대응 됩니다. 해당 property attribute를 살펴보면 다음과 같습니다.

- `[[Value]]` : 프로퍼티의 값을 의미합니다. 프로퍼티의 값으로는 자바스크립트의 모든 값(숫자, 문자열, 객체, 함수 등)을 사용할 수 있습니다.
- `[[Writable]]` : `=` 연산자를 이용하여 값을 할당할 수 있는지를 나타냅니다.
- `[[Enumerable]]` : `for ... in` 과 같은 연산을 통해 "열거(enumerate)" 할 수 있는지를 나타냅니다.
- `[[Configurable]]` : `delete` 연산자로 해당 속성을 지울 수 있는지, 그리고 `defineProperty()` 로 다른 프로퍼티 속성을 변경할 수 있는지를 나타냅니다.

```js
const object = {
	x: 5,
	y: 6
}
```

![](/assets/image07.png)

```js
const object = { foo: 42 };
console.log(Object.getOwnPropertyDescriptor(object, 'foo'));
// { value: 42, writable: true, enumerable: true, configurable: true }
```

JS에서 배열은 객체의 특수한 경우라고 생각하면 됩니다. 일반적인 객체와의 차이점이라면 현재 배열에 담긴 프로퍼티의 개수를 나타내는 `length` 라는 특별한 프로퍼티가 존재한다는 점과 배열의 각 `key` 는 0에서 2³²-2 사이의 모든 정수를 의미합니다. (이러한 key를 배열의 인덱스라고 합니다)






> JS 객체에는 **이름 있는 프로퍼티(named properties)** 와 **요소(elements)** 가 있습니다.
> `elements` 는 **정수 인덱스** 를 가지는 프로₩퍼티로, 주로 배열에서 사용 됩니다.
> `["foo","bar"]` V8은 이 두 가지 유형을 다르게 처리합니다.

- **Elements** : 별도의 배열로 저장되어 `pop` , `slice` 와 같은 연산에 최적화 되어 있습니다.
- **Named Properties** : 프로퍼티 배열에 저장되며, 접근 시 추가적인 메타데이터가 필요합니다.

### Hidden Classes와 Descriptor Arrays

- V8은 객체의 구조를 동적으로 표현하기 위해 **Hidden Class** 를 사용 합니다.
- 이는 객체 지향 언어의 클래스와 비슷 하지만 런타임에 생성 및 수정됩니다.
- Hidden Class 정보
	- **프로퍼티 개수**
	- **객체의 프로토타입에 대한 참조** 
	- **Descriptor Array** : 프로퍼티 이름과 프로퍼티 배열의 인덱스를 매핑합니다.

> 해당 구조로 V8의 최적화 컴파일러와 인라인 캐시가 객체의 형태를 빠르게 식별하고 프로퍼티에 빠르게 접근 할 수 있도록 돕습니다.

### Hidden Class의 전환 과정

- 객체에 프로퍼티를 추가하거나 삭제하면 V8은 객체의 새로운 구조를 반영하기 위해 새로운 `Hidden Class` 를 생성 합니다.

예시

1. 빈 객체 `{}` 로 시작
2. 프로퍼티 `a` 를 추가하면 새로운 `Hidden Class` 로 전환
3. 추가로 `b` 를 추가하면 또 다른 새로운 `Hidden Class` 로 전환

> 이러한 전환은 `Hidden Class` 의 트리를 형성하며, 이를 통해 V8은 객체의 구조를 효율적으로 추적합니다.

### Fast Properties와 Slow Properties

> V8은 사용 패턴에 따라 프로퍼티 저장 방식을 최적화 합니다.

- **Fast Properties** : 적은 수의 프로퍼티를 가진 객체에 대해 V8은 고정 배열을 사용해 빠른 접근을 가능하게 합니다.
- **Slow Properties** : 많은 프로퍼티를 가진 객체나 빈번한 추가/삭제가 발생하는 경우, V8은 사전(dictionary)기반의 저장 방식으로 전환 합니다. 이 방식은 유연하지만 관리 오버헤드가 있어 느릴 수 있습니다.

**개발자가 할 수 있는 최적화 방법**

1. 객체 생성 시 모든 프로퍼티를 정의하며 `Fast Properties` 유지
2. 프로퍼티 추가나 삭제를 최소화 하여 `Slow Properties` 로의 전환 방지
3. 배열에 일관된 데이터 타입 사용, 같은 배열 내에서 여러 데이터 타입을 섞지 않도록 주의

#### 궁금증) Slow Properties로 전환되는 임계값이 있을까?

[프로퍼티 추가관련 코드링크](https://github.com/v8/v8/blob/main/src/objects/js-objects.h#L908) 

```C++
// When extending the backing storage for property values, we increase
  // its size by more than the 1 entry necessary, so sequentially adding fields
  // to the same object requires fewer allocations and copies.
  static const int kFieldsAdded = 3;
  static_assert(kMaxNumberOfDescriptors + kFieldsAdded <=
                PropertyArray::kMaxLength);
```

- 프로퍼티를 추가할 때 마다 한 번에 3개의 추가 공간을 더 할당하는 것을 볼 수 있습니다.

[배열 요소 관련 코드 링크](https://github.com/v8/v8/blob/main/src/objects/js-objects.h#L884) 

```C++
 // Maximal gap that can be introduced by adding an element beyond
  // the current elements length.
  static const uint32_t kMaxGap = 1024;

  // Maximal length of fast elements array that won't be checked for
  // being dense enough on expansion.
  static const int kMaxUncheckedFastElementsLength = 5000;

  // Same as above but for old arrays. This limit is more strict. We
  // don't want to be wasteful with long lived objects.
  static const int kMaxUncheckedOldFastElementsLength = 500;
```

- 최대 갭 크기: 1024
- 빠른 요소 배열의 최대 길이: 5000
- 오래된 배열의 최대 길이: 500

> 삽질 결론적으로 말하자면 정확한 임계값이 몇인지 찾을 수는 없었다. 그리고 **중요한것은 빈 객체에 500개의 프로퍼티를 순차적으로 넣었다고 해서 Slow Properties로 전환 되는것은 아니다. V8엔진에서 고려하는 여러가지 요인들에 따라서 전환 되는것이다.** 

### Hidden Class를 이용한 조회 과정

#### 프로퍼티 조회 시 `Hidden Class` 사용

- Javascript에서 객체의 프로퍼티를 조회 할 때, V8은 해당 객체의 `Hidden Class` 를 참조하여 프로퍼티의 위치를 빠르게 찾습니다.
- `Hidden Class` 는 객체의 구조에 대한 정보를 가지고 있기 때문에, 이를 통해 특정 프로퍼티가 어떤 인덱스에 위치하는지 바로 알 수 있습니다.

#### 조회 과정의 최적화

- 객체에 **정적** 으로 프로퍼티가 설정되어 있을 때, V8은 해당 `Hidden Class` 를 사용하여 프로퍼티의 **인덱스를 캐싱** 합니다.
- 이를 통해 객체의 **프로퍼티 조회 시간 복잡도는 O(1)** 에 가깝게 최적화 됩니다.

#### Inline Caching (IC)

- V8은 객체 프로퍼티 접근을 최적화 하기 위해 **Inline Caching (IC)** 라는 기법을 사용합니다.
- IC는 객체 프로퍼티 접근 시, 이전에 접근했던 `Hidden Class` 정보를 캐싱하여, 같은 구조의 객체에 대한 프로퍼티 접근이 반복될 경우 **더 빠르게 접근** 할 수 있도록 도와줍니다.
- 예를 들어, 함수에서 여러 번 동일한 객체의 프로퍼티를 접근할 경우, IC 덕분에 이후 접근이 **더 효율적** 으로 이루어 집니다.

#### 객체 구조의 변경과 Hidden Class 전환

- 객체의 구조가 변경될 때, 예를 들어 **프로퍼티가 추가되거나 삭제될 때** , V8은 **새로운 Hidden Class** 를 생성하여 해당 객체의 구조를 업데이트 합니다.
- 이렇게 되면 기존 캐싱된 `Inline Cache` 가 무효화되어 성능이 저하될 수 있습니다.

#### 프로토타입 체인과 Hidden Class

- 객체에서 원하는 프로퍼티를 찾을 수 없는 경우, V8은 **프로토타입 체인** 을 따라 가면서 **상위 객체의 Hidden Class** 를 탐색 합니다.
- 이 과정에서 **프로토타입 체인의 레벨** 이 많을수록 조회 성능이 저하될 수 있습니다.
- 따라서 자주 사용하는 속성은 **객체 자체** 에 정의하는 것이 좋습니다.


```js
function createObject() {
    return {
        a: 1,
        b: 2,
    };
}

let obj = createObject();
console.log(obj.a); // 첫 번째 조회: Hidden Class를 사용하여 'a'의 위치를 찾음
console.log(obj.b); // IC를 사용하여 두 번째 조회: 캐시된 인덱스를 통해 빠르게 접근
```



# Reference

[JS배열과객체가 어떻게 다양한 elements kinds로 처리 되는지](https://v8.dev/blog/elements-kinds) 
[https://www.youtube.com/watch?v=m9cTaYI95Zc](https://www.youtube.com/watch?v=m9cTaYI95Zc) 
[Object의 속성 추가 및 삭제에 따른 히든 클래스 사용과 최적화 방식](https://v8.dev/blog/fast-properties) 
https://mathiasbynens.be/notes/shapes-ics
https://mathiasbynens.be/notes/prototypes
[https://www.zhenghao.io/posts/object-vs-map](https://www.zhenghao.io/posts/object-vs-map) 
https://tc39.es/ecma262/#table-object-property-attributes
[https://tc39.es/ecma262/#sec-object-type](https://tc39.es/ecma262/#sec-object-type) 
[https://tc39.es/ecma262/#sec-map-objects](https://tc39.es/ecma262/#sec-map-objects) 
https://meetup.nhncloud.com/posts/78
[[prototype]]
