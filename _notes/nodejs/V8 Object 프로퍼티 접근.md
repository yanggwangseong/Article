---
title: V8 Object 프로퍼티 접근
permalink: /nodejs/v8-object-property
---

# V8 Object 프로퍼티 접근

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

- `Value` : 프로퍼티의 값을 의미합니다. 프로퍼티의 값으로는 자바스크립트의 모든 값(숫자, 문자열, 객체, 함수 등)을 사용할 수 있습니다.
- `Writable` : `=` 연산자를 이용하여 값을 할당할 수 있는지를 나타냅니다.
- `Enumerable` : `for ... in` 과 같은 연산을 통해 "열거(enumerate)" 할 수 있는지를 나타냅니다.
- `Configurable` : `delete` 연산자로 해당 속성을 지울 수 있는지, 그리고 `defineProperty()` 로 다른 프로퍼티 속성을 변경할 수 있는지를 나타냅니다.

```js
const object = {
	x: 5,
	y: 6
}
```

![](/assets/image07.png)

![[Pasted image 20241109160709.png]]

![[Pasted image 20241109161424.png]]

목적은 메모리가 낭비되는것을 방지하고 메모리를 효율적으로 사용하기 위해서 Hidden Class를 사용한다.

1. 객체들은 프로퍼티의 값만 저장한다.
2. 해당 객체의 `Hidden Class` 인스턴스를 가리킵니다.
3. `Hidden Class` 인스턴스에는 프로퍼티
	- 프로퍼티의 이름 (`'x', 'y'` ) 과 해당 이름에 대한 프로퍼티 속성 정보 (`Writable, Enumerable, Configurable`)
	- 실제 객체에서 해당 프로퍼티가 몇번째 인덱스(오프셋(`offset` ))인지를 나타냅니다.
	- **해당 인덱스를 통해 JS엔진이 실제 객체에서 프로퍼티 값을 어떻게 찾을지 알 수 있다** 
	- 이러한 방식을 사용하면 똑같은 `Hidden Class` 를 가진 여러 객체들이 존재하는 경우 각 객체들의 프로퍼티 이름과 그에 대한 프로퍼티 속성 정보를 한번만 저장하면 된다!


# Reference

- [링크1](https://v8.dev/docs/hidden-classes) 
- [링크2]([JS배열과객체가 어떻게 다양한 elements kinds로 처리 되는지](https://v8.dev/blog/elements-kinds) ) 
- [링크3]([https://www.youtube.com/watch?v=m9cTaYI95Zc](https://www.youtube.com/watch?v=m9cTaYI95Zc) ) 
- [링크4](https://v8.dev/blog/fast-propertie) 
- [링크5](https://v8.dev/blog/fast-properties) 
- [링크6](https://mathiasbynens.be/notes/shapes-ics) 
- [링크7](https://engineering.linecorp.com/ko/blog/v8-hidden-class) 
- [링크8](https://meetup.nhncloud.com/posts/78) 

