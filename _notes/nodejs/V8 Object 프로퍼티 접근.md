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

## Transition 체인과 Transition 트리

```js
const o = {};
o.x = 5;
o.y = 6;
```

- 런타임에 객체 프로퍼티를 추가(혹은 제거) 할 수 도 있습니다.
- JS엔진은 이때 `Hidden Class` 인스턴스는 `transition 체인` 을 형성 합니다.

![[Pasted image 20241109165551.png]]

1. `{}` 에서 시작 했다가 `o.x = 5;` 구문에 의해 `x` 프로퍼티가 추가되어 엔진은 기존의 모양을 새로운 Hidden Class로 "transition(전이)" 합니다.
2. `o.y = 6` 구문에 의해 `y` 프로퍼티가 추가되어 한번 더 다른 Hidden Class로 "transition(전이)" 합니다.

실제로는 각 Hidden Class 마다 모든 프로퍼티의 정보를 저장하는것이 아니라, 아래처럼 Hidden Class 인스턴스가 생성될 때 추가된 프로퍼티에 관한 정보만을 저장 합니다.

![[Pasted image 20241109165857.png]]

- 마치 프로토타입 체인처럼 특정 `Hidden Class` 의 인스턴스에 존재하지 않는 프로퍼티를 찾기 위해, 다음 `Hidden Class` 에서 이전 `Hidden Class` 를 가리키는 포인터가 추가됩니다.
- 기존의 단방향 포인터에서 양방향 포인터가 됩니다.
- 예를들어 `o.x` 와 같이 어떤 객체의 `x` 프로퍼티에 접근하는 경우, 엔진은 `x` 프로퍼티를 가지는 모양을 찾을 때까지 transition 체인을 거슬러 올라갑니다.

### Hidden Class(Shape) Table

- 객체의 프로퍼티에 접근할 때 (ex `obj,x` ) 실제 객체가 가리키는 `Hidden Class` 에서 시작하여 프로퍼티를 찾을때까지 체인을 따라 이동 한다고 했는데 이는 사실 시간 복잡도가 `O(n)` 만큼 걸리는 연산이라 transition 체인이 긴 경우 비효율적일 수 있습니다.
- V8엔진은 `Hidden Class Table` 이라는 것을 두어 객체 접근 연산을 최적화 했습니다.
- Hidden Class Table의 각 엔트리는 프로퍼티의 key와 해당 프로퍼티를 가지고 있는 `Hidden Class` 를 매핑 합니다.

![[Pasted image 20241109171009.png]]



## Inline Cache (IC)

- **Hidden Class** 인스턴스를 사용하는 가장 큰 이유는 `Inline Cache, IC(인라인 캐시)` 라는 최적화 기법을 사용하기 위해서 입니다.
- 인라인 캐시는 객체의 프로퍼티를 어디서 찾아야 하는지에 대한 정보를 캐싱함으로써 JS의 성능을 최적화하는 주된 요소이다.

함수 `getX()` 처음 실행

![[Pasted image 20241109163742.png]]

1. 함수 `getX()` 를 **처음 실행** 한 경우 `get_by_id` 바이트 코드는 `Hidden Class` 의 인스턴스로 부터 `x` 프로퍼티에 관한 정보를 찾아 `x` 프로퍼티의 오프셋이 `0` 이라는 사실을 알아내게 됩니다.
2. V8엔진은 해당 정보를 찾는 데 사용된 `Hidden Class` 의 인스턴스와 프로퍼티의 오프셋을 `get_by_id` 바이트 코드에 저장 합니다.

함수 `getX()` 두번째 이후 실행

![[Pasted image 20241109162944.png]]

1. 바이트 코드의 인라인 캐시에 저장된 `Hidden Class` 의 인스턴스를 비교한 후 만약 `Hidden Class` 의 인스턴스가 같다면 앞서 수행했던 작업을 처음부터 일일이 수행할 필요 없이 캐시 된 오프셋을 통해 객체의 프로퍼티에 접근 하면 됩니다.
2. 즉, V8엔진이 IC에 저장된 것과 같은 `Hidden Class` 임을 확인한 경우 굳이 `Hidden Class` 의 프로퍼티 속성 정보를 찾아서 오프셋을 알아내는 과정을 거칠 필요 없이 IC에 저장된 오프셋을 통해 실제 객체에서 값을 찾을 수 있게 됩니다.

**인라인 캐시를 통해 Hidden Class 인스턴스와 오프셋을 캐싱함으로써 정보를 찾는 과정을 생략하여 프로퍼티 접근 속도를 크게 향상 시킬 수 있습니다** 


```js
const object = { foo: 42 };
console.log(Object.getOwnPropertyDescriptor(object, 'foo'));
// { value: 42, writable: true, enumerable: true, configurable: true }
```

JS에서 배열은 객체의 특수한 경우라고 생각하면 됩니다. 일반적인 객체와의 차이점이라면 현재 배열에 담긴 프로퍼티의 개수를 나타내는 `length` 라는 특별한 프로퍼티가 존재한다는 점과 배열의 각 `key` 는 0에서 2³²-2 사이의 모든 정수를 의미합니다. (이러한 key를 배열의 인덱스라고 합니다)

```js
const arr = ['a', 'b'];
arr.length; // 2

// 위 배열을 일반적인 객체의 형태로 나타내면 아래와 같습니다.
// (물론 실제 배열과 100% 똑같지는 않습니다)
const arrLike = {
  0: 'a',
  1: 'b',
};

Object.defineProperty(arrLike, 'length', {
  value: 2,
  writable: true
});


// 일반 객체처럼, 배열에도 문자열을 key로 사용할 수는 있습니다만,
// 일반적인 경우는 아닙니다.
arr.hello = 'world';
console.log(arr); // [ 'a', 'b', hello: 'world' ]
```

배열을 내부적으로 표현하는 방식도 객체를 표현하는 방식과 매우 흡사합니다.

![](/assets/image08.png)

배열에 요소를 추가하는 경우 자바스크립트 엔진이 알아서 배열의 `length` 프로퍼티 값을 증가시킵니다:


- **Elements** : 별도의 배열로 저장되어 `pop` , `slice` 와 같은 연산에 최적화 되어 있습니다.
- **Named Properties** : 프로퍼티 배열에 저장되며, 접근 시 추가적인 메타데이터가 필요합니다.


# Reference

- [링크1](https://v8.dev/docs/hidden-classes) 
- [링크2]([JS배열과객체가 어떻게 다양한 elements kinds로 처리 되는지](https://v8.dev/blog/elements-kinds) ) 
- [링크3]([https://www.youtube.com/watch?v=m9cTaYI95Zc](https://www.youtube.com/watch?v=m9cTaYI95Zc) ) 
- [링크4](https://v8.dev/blog/fast-propertie) 
- [링크5](https://v8.dev/blog/fast-properties) 
- [링크6](https://mathiasbynens.be/notes/shapes-ics) 
- [링크7](https://engineering.linecorp.com/ko/blog/v8-hidden-class) 
- [링크8](https://meetup.nhncloud.com/posts/78) 

