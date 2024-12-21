---
title: prototype
permalink: /javascript/prototype
tags:
  - Javascript
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

# 프로토타입이 왜 필요할까?

```js
function Person(){
	this.eyes = 2;
	this.nose = 1;
}

const kim = new Person();
const park = new Person();

console.log(kim.eyes); // 2
console.log(park.nose); // 1

console.log(park.eyes); // 2
console.log(park.nose); // 1
```

- `kim` 과 `park` 은 `eyes` 와 `nose` 를 공통적으로 가지고 있는데, 메모리에는 `eyes` 와 `nose` 가 2개씩 총 4개가 할당 됩니다. 이는 객체를 100개를 만들면 200개의 변수가 메모리에 할당되게 됩니다.

```js
function Person(){}

Person.prototype.eyes = 2;
Person.prototype.nose = 1;

const kim = new Person();
const park = new Person();

console.log(kim.eyes); // 2
```

- Person의 prototype의 static 공간에 eyes와 nose를 둬서 메모리를 효율적으로 사용 할 수 있게 됩니다.

# 프로토 타입이 어떻게 객체를 만들어 내는가?

> `new Animal(...)` 가 실행 될때

1. `Animal.prototype` 을 상속하는 새로운 객체가 하나 생성 됩니다.
2. 새롭게 생성된 객체에 this가 바인딩이 되고 Animal 함수가 생성자 함수로써 호출된다.
3. 일반적으로 생성자 함수에서 리턴이 없기 때문에 1번에서 생성된 객체가 대신 사용된다. 즉, 인스턴스가 된다.
4. `return` 시에 반환값이 없거나 `Primitive` 값을 반환하는 경우 1번에서 생성된 객체가 반환 됩니다.
5. 그 이외의 것들을 `return` 하게 되면 그 반환된 객체가 반환됩니다.

```js
function FuncAnimal() {
  this.name = "animal";
}

class Animal {
  constructor(name) {
    this.name = name;
  }
}

const animal = new Animal("dog");
console.log(animal); // Animal { name: 'dog' }
console.log(animal.__proto__ === Animal.prototype); // true
const funcAnimal = new FuncAnimal();
console.log(funcAnimal); // FuncAnimal { name: 'animal' }
console.log(funcAnimal.__proto__ === FuncAnimal.prototype); // true
```

```js
// 원시값(Primitive)값을 반환하는 경우 1번 생성된 객체가 반환 됩니다.
function FuncAnimal() {
  this.name = "animal";

  return 1;
}

class Animal {
  constructor(name) {
    this.name = name;
    return 2;
  }
}

const animal = new Animal("dog");
console.log(animal); // Animal { name: 'dog' }
const funcAnimal = new FuncAnimal();
console.log(funcAnimal); // FuncAnimal { name: 'animal' }
```

```js
// 그 이외의 값을 반한할 때
function FuncAnimal() {
  this.name = "animal";

  return new Map();
}

class Animal {
  constructor(name) {
    this.name = name;
    return new Map();
  }
}

const animal = new Animal("dog");
console.log(animal); // Map(0) {}
const funcAnimal = new FuncAnimal();
console.log(funcAnimal); // Map(0) {}
```

## 해당 프로토타입 객체 안에 무엇이 들어가 있을까?

### 1. `__proto__`

- JS 모든 객체는 `__proto__` 라는 인터널 슬롯(`internal slot`)을 가진다.
- `__proto__` 값은 null 또는 객체이며 상속을 구현하는데 사용된다.
- `__proto__` 객체의 데이터 프로퍼티는 get 액세스를 위해 상속되어 객체의 프로퍼티처럼 사용할 수 있다.
- 하지만 set 액세스는 허용되지 않는다.

### 2. prototype 프로퍼티

- **함수 객체는 prototype 프로퍼티도 소유한다** 
- 함수 객체의 경우 `__proto__` 가 해당 `Function.prototype` 을 가리킨다.

### 3. constructor 프로퍼티

- 프로토 타입 객체는 `constructor` 프로퍼티를 갖습니다.
- constructor 프로퍼티는 객체의 입장에서 자신을 생성한 객체를 가리킵니다.

```js
function Person(name) {
  this.name = name;
}

var foo = new Person('Lee');

// Person() 생성자 함수에 의해 생성된 객체를 생성한 객체는 Person() 생성자 함수이다.
console.log(Person.prototype.constructor === Person);

// foo 객체를 생성한 객체는 Person() 생성자 함수이다.
console.log(foo.constructor === Person);

// Person() 생성자 함수를 생성한 객체는 Function() 생성자 함수이다.
console.log(Person.constructor === Function);
```

# 객체 리터럴 방식으로 생성된 객체의 프로토타입

```js
const array = [1, 2, 3, 4, 5];

console.log(array.__proto__ === Array.prototype); // true
console.log(Array.prototype.__proto__ === Object.prototype); // true
console.log(Object.prototype.__proto__ === null); // true
console.log(Array.__proto__ === Function.prototype); // true
console.log(Function.prototype.__proto__ === Object.prototype); // true

/*
* Function.prototype
*/
Function.prototype.sayHello = function(){
	console.log("sayHello");
}

// array.sayHello(); // Error
Array.sayHello(); // sayHello
```

**프로토 타입 체인 구조** 

- array -> Array.prototype -> Object.prototype -> null

### 원시 타입은 객체가 아니므로 프로퍼티 추가할 수 없다

```js
const num = 12345;

// 에러가 발생하지 않는다.
num.myMethod = function () {
  console.log('num.myMethod');
};

// num.myMethod(); // Uncaught TypeError: str.myMethod is not a function

Number.prototype.myMethod = function () {
  console.log('num.myMethod');
};

num.myMethod(); // num.myMethod
```

- 하지만 Number 객체의 프로토타입 객체 Number.prototype에 메소드를 추가하면 원시 타입, 객체 모두 메소드를 사용할 수 있다.

**프로토타입 체인 구조** 

- num -> Number.prototype -> Object.prototype -> null
- 이러한 체인 구조를 가지고 있기 때문에 Number.prototype에 선언한 프로퍼티를 사용 할 수있다.

# 프로토타입에서 프로퍼티 접근

```js
class Car2 extends Car {
  color = "blue";
}
function Car() {}
const car1 = new Car(); // this가 car1이라는 인스턴스를 가리킴.
const car2 = new Car2(); // this가 car2이라는 인스턴스를 가리킴.
console.log(car1.color); // 1:
console.log(car2.color); // 1:
Object.prototype.color = "red";
console.log(car1.color); // 2:
console.log(car2.color); // 2:
Car.prototype.color = "yellow";
console.log(car1.color); // 3:
console.log(car2.color); // 3:
Function.prototype.color = "pink";
console.log(car1.color); // 4:
console.log(car2.color); // 4:
car1.color = "black";
car2.color = "white";
console.log(car1.color); // 5:
console.log(car2.color); // 5:
```

프로토타입 접근에 대한 예시 입니다.

## 결과

> 1: undefined
> 1: "blue"
> 2: "red"
> 2: "blue"
> 3: "yellow"
> 3: "blue"
> 4: "yellow"
> 4: "blue"
> 5: "black"
> 5: "white"

# 객체 생성자가 아닌 방식으로 클래스 만드는 방법

## Object.create

- 지정된 프로토타입 객체 및 속성(property)을 갖는 새 객체를 만듭니다.

## prototype 상속 구현

- classical

```js
/**
 * Benz Bus <- Bus <-    Vehicle
 * BMW Car <- Car <-     Vehicle
 * HondaBike <- Bike <-  Vehicle
 */

function Vehicle(vehicleType) {
  this.vehicleType = vehicleType;
}

Vehicle.prototype.blowHorn = function () {
  console.log("Honk!");
};

function Bus(make) {
  Vehicle.call(this, "Bus");
  this.make = make;
}

Bus.prototype = Object.create(Vehicle.prototype);

Bus.prototype.noOfWheels = 6;
Bus.prototype.accelerator = function () {
  console.log("Accelerating Bus");
};

Bus.prototype.brake = function () {
  console.log("Braking Bus");
};

function Car(make) {
  Vehicle.call(this, "Car");
}
Car.prototype = Object.create(Vehicle.prototype);
Car.prototype.noOfWheels = 4;
Car.prototype.accelerator = function () {
  console.log("Accelerating Car");
};
Car.prototype.brake = function () {
  console.log("Braking Car");
};

function Bike(make) {
  Vehicle.call(this, "Bike");
  this.make = make;
}
Bike.prototype = Object.create(Vehicle.prototype);
Bike.prototype.noOfWheels = 2;
Bike.prototype.accelerator = function () {
  console.log("Accelerating Bike");
};
Bike.prototype.brake = function () {
  console.log("Braking Bike");
};

const myBus = new Bus("Benz");
const myCar = new Car("BMW");
const myMotorBike = new Bike("Honda");

console.dir(myBus);
/**
 * Bus
 * - make: "Benz"
 * - vehicleType : "Bus"
 * - __proto__ (Vehicle)
 *   - accelerator : f()
 *   - brake: f()
 *   - noOfWheels: 6
 *   - __proto__: Object
 *     - blowHorn : f()
 *     - constructor: f Vehicle(vehicleType)
 */


/*
* class 사용시
*/
class Vehicle {
  constructor(type) {
    this.vehicleType= type;
  }
  blowHorn() {
    console.log("Honk!");
  }
}
class Bus extends Vehicle {
  constructor(make) {
    super("Bus");
    this.make = make; 
  }
  accelerator() {
    console.log('Accelerating Bus');
  }
  brake() {
    console.log('Braking Bus');
  }
}
Bus.prototype.noOfWheels = 6;
const myBus = new Bus("Mercedes");
```

- prototypal

```js
let animal = {
  eats: true,
  walk() {
    console.log("동물이 걷습니다");
  },
};

let rabbit = {
  jumps: true,
  __proto__: animal,
};

let longEar = {
  earLength: 10,
  __proto__: rabbit,
};

console.dir(longEar.eats);
console.dir(longEar.jumps);
console.dir(longEar.walk());
console.dir(longEar.jumps);
```

## extends

```js
function A() {}

const a = new A();

A.prototype.calculate = function () {
  console.log("calculate");
};
A.prototype.name = "yang";
a.calculate(); // calculate

/*
*  현재 A prototype
*  calculate
*  age
*/

class B extends A {}
const b = new B();
b.calculate(); // calculate
console.log(b.name); // "yang"

```

- 이전에 함수에서만 `prototype` 을 가질 수 있다고 하였다.
- 결국 class에서 `extends` 가 의미하는것은 `__proto__` 객체가 `prototype` 객체를 참조할 수 있게 해주는것이다.

# Reference

- [tc39링크1](https://tc39.es/ecma262/#ordinary-object) 
- [tc39링크2](https://tc39.es/ecma262/#sec-ordinary-and-exotic-objects-behaviours)
- [MDN링크](https://developer.mozilla.org/ko/docs/Web/JavaScript/Reference/Operators/new)
- [MDN링크2](https://developer.mozilla.org/ko/docs/Web/JavaScript/Reference/Global_Objects/Object/proto)
- [ECMASSCRIPT](https://tc39.es/ecma262/multipage/fundamental-objects.html#sec-object.prototype.__proto__) 
- [MDN ObjectCreate](https://developer.mozilla.org/ko/docs/Web/JavaScript/Reference/Global_Objects/Object/create) 
- [링크](https://poiemaweb.com/js-prototype) 
