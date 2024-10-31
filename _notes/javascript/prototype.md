---
title: prototype
permalink: /javascript/prototype
---

# 🛠️ 프로토타입 개념 정리

1. 생성자 함수를 `new` 연산자와 함께 호출하거나 객체 타입을 리터럴로 선언하면, 생성자에서 정의된 내용을 바탕으로 새로운 인스턴스가 생성됩니다.
2. 이 인스턴스에는 `__proto__`라는 프로퍼티가 자동으로 부여되며, 이 프로퍼티는 생성자의 `prototype` 프로퍼티를 참조합니다.
3. `__proto__`는 생략 가능한 속성이므로, 인스턴스는 생성자의 `prototype`에 정의된 메서드를 자신의 메서드처럼 호출할 수 있습니다.
4. 생성자의 `prototype`에는 `constructor`라는 프로퍼티가 있으며, 이는 생성자 함수 자체를 가리킵니다.
5. 이 프로퍼티는 인스턴스가 자신의 생성자 함수가 무엇인지를 알 수 있는 수단입니다.

## 📚 프로토타입의 상세 개념

- JS는 함수에 자동으로 객체인 prototype 프로퍼티를 생성해 놓는다.
- 해당 함수를 생성자 함수로서 사용할 경우 (new 연산자와 함께 함수를 호출할 경우) 또는 리터럴 타입으로 선언 할 때
	- 리터럴로 선언하게 되면 생성자 함수를 사용하여 생성된 인스턴스로 취급한다.
- 생성된 인스턴스에는 숨겨진 프로퍼티인 `__proto__` 가 자동으로 생성된다.
- 해당 `__proto__` 프로퍼티는 생성자 함수의 prototype 프로퍼티를 참조한다.
- `__proto__` 프로퍼티는 생략 가능하도록 구현돼있다.
- 생성자 함수의 prototype에 어떤 메서드나 프로퍼티가 있다면 인스턴스에서도 마치 자신의 것처럼 해당 메서드나 프로퍼티에 접근할 수 있게 된다.

## 그림 

![](/assets/image03.png)

# 🌐 프로토타입 체인 

> 프로토타입 체인(`prototype chain`) 은 객체의 `__proto__` 프로퍼티가 연쇄적으로 연결된 구조를 말하며, 이를 통해 객체는 자신의 프로토타입에 정의된 속성이나 메서드를 사용할 수 있습니다.
> 이러한 구조를 탐색하며 속성을 찾는 과정을 **프로토타입 체이닝** 이라고 합니다.


```js
var arr = [1, 2];
arr.push(3);
console.log(arr.hasOwnProperty(2)); // true
/*
* 위의 리터럴로 선언한것과 아래 생성자 함수로 생성 한것은 동일하다.
* 이해를 쉽게 하기위해서 생성자 함수로 arr2인스턴스를 생성함.
*/
var arr2 = new Array(1, 2);
app2.push(3);
app2.hasOwnProperty(2); // true
```

> `hasOwnProperty` 메서드는 Object의 메서드인데 배열인 arr에서 도대체 어떻게 실행 할 수 있는걸까?

1. `arr2` instance에 `__proto__` 자동생성.
2. `arr2.push(3)` 라는 뜻은
3. `arr2(.__proto__).push(3)` 과 같다.
4. arr2 인스턴스는 `__proto__` 를 통해서 `Array` 의 `constructor` 의 `prototype` 객체에 접근 가능하다.
5. `Array` 의 `prototype` 객체의 메서드를 사용할 수 있다. (프로토타입 체인)
6. `__proto__` 가 생략 가능하기 때문에 사용자는 최종적으로 `arr2.push(3)` 으로 사용 할 수 있다.
7. `Array` 의 `constructor` 의 `prototype` 객체도 결국엔 객체이기 때문에 `__proto__` 를 가지고 있다.
8. `__proto__` 는 다시 Object.prototype을 참조 할 수 있다.
9. `Object` 의 `prototype` 객체의 메서드를 사용 할 수 있다. (프로토타입 체인)
10. `arr2(.__proto__)(.__proto__).haOwnProperty(2)` 를 호출 할 수 있다.
11. `__proto__` 는 생략 가능하기 때문에 사용자는 최종적으로 `arr2.hasOwnProperty(2)` 로 사용하게 된다.

## 그림

![](/assets/image04.png)

![](/assets/image05.png)

![](/assets/image06.png)

## ⚠️ 객체 전용 메서드의 예외사항

- 자바스크립트의 모든 데이터는 결국 `Object.prototype` 을 가지므로, **객체 전용 메서드** 를 다른 프로토타입 객체 안에 정의 할 수 없습니다.
	- 항상 `Object.prototype` 이 **프로토타입 체인의 최상단** 에 있기 때문에, 정의하게 되면 다른 모든 데이터에서도 사용 가능하게 되어버린다.
- 객체만을 대상으로 동작하는 **객체 전용 메서드** 들은 `Object.prototype` 이 아닌 `Object의 정적 메서드` 로 부여할 수 밖에 없었다.
- 생성자 함수인 `Object` 와 인스턴스인 객체 리터럴 간에는 `this` 를 통한 연결이 불가능하다. 따라서 "메서드명 앞의 대상이 곧 this" 인 방식이 아닌, 대상 인스턴스를 인자로 직접 주입하는 방식으로 구현돼 있다.
	- 예를 들어, `Object.freeze(instance)` 는 사용할 수 있지만 `instance.freeze()` 는 사용할 수 없는 이유다.
- 객체 한정 메서드들을 `Object.prototype` 이 아닌 `Object` 에 직접 부여할 수 밖에 없던 이유
	- *Object.prototype* 이 여타의 참조형 데이터뿐 아니라 기본형 데이터조차 `__proto__` 에 반복 접근함으로써 도달할 수 있는 최상위 존재이기 때문이다.
