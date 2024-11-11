---
title: V8-map-set
permalink: /nodejs/v8-map-set
---
# Map, Set ECMAScript 스펙과 V8 엔진

- ECMAScript 스팩에서 특정 규격을 정의하고 Javascript의 엔진들은 해당 규격만 지키며 알고리즘, 성능에 대해서는 자유롭게 구현이 가능하다.
- V8 엔진은 C++로 최적화된 `Map` 과 `Set` 을 구현하며, Node.js에서는 Javascript API를 통해 V8과 연결해 사용합니다.
- Node.js 백엔드 개발자가 Map 자료형을 선언 했습니다. 그럼 이걸 가지고 Node.js는 Javascript API를 통해서 V8과 연결합니다. V8엔진은 실제 최적화된 C++의 Map을 실행 시킵니다. 그리고 해당 Map은 V8엔진을 통해서 Javascript API로 Node.js 개발자에게 전달 됩니다.

# V8의 Map과 Set 내부 구조

> [V8의 OrderedHashTable 설명 문서](https://github.com/v8/v8/blob/main/src/objects/ordered-hash-table.h#L23)에 따르면, V8 엔진은 `Map`과 `Set`을 `OrderedHashTable` 을 기반으로 구현하며, 이는 삽입된 순서를 보존하는 해시 테이블입니다.

## 기본 알고리즘

> Tyler Close가 제안한 **결정론적 해시 테이블 알고리즘(Deterministic hash tables algorithm)** 을 사용한다.

```ts
interface Entry {
    key: any;
    value: any;
    chain: number; // 다음 항목의 체인을 가리킴 (단방향 링크드 리스트 구조)
}

interface CloseTable {
    hashTable: number[]; // 각 버킷의 인덱스를 저장하는 배열
    dataTable: Entry[]; // 실제 데이터를 저장하는 배열, 삽입 순서대로 저장됨
    nextSlot: number; // 다음 삽입 위치
    size: number; // 현재 테이블의 크기
}
```

- `hashTable` : 각 버킷(메모리의 데이터 저장 단위)을 가리키는 인덱스를 저장합니다. 각 버킷은 메모리의 데이터 저장 단위이며, `dataTable` 의 인덱스를 가리킵니다.
- `dataTable` : 실제 `Entry` 들을 저장하며, 삽입 순서를 보존합니다.
- `Entry` 에는 `key` , `value` , 그리고 다음 항목을 가리키는 `chain` 이 포함됩니다. **단방향 링크드 리스트로 구조로 연결하여 해시 충돌을 처리합니다** 

## 알고리즘 예시

- `CloseTable` 이 두개의 버킷 (`hashTable.length = 2` ) 과 전체 저장 가능 공간이 4(`dataTable.length = 4`), 해시 테이블 요소는 다음과 같다.

```js
// identity hash function를 사용한다 가정,
// i.e. function hashCode(n) { return n; }
table.set(0, 'a'); // => bucket 0 (0 % 2)
table.set(1, 'b'); // => bucket 1 (1 % 2)
table.set(2, 'c'); // => bucket 0 (2 % 2)
```

- 테이블의 내부 구조는 다음과 같습니다

```js
const tableInternals = {
    hashTable: [0, 1],
    dataTable: [
        {
            key: 0,
            value: 'a',
            chain: 2 // <2, 'c'>의 인덱스
        },
        {
            key: 1,
            value: 'b',
            chain: -1 // -1은 체인의 마지막 항목을 의미
        },
        {
            key: 2,
            value: 'c',
            chain: -1
        },
        // 빈 슬롯
    ],
    nextSlot: 3, // 다음 빈 슬롯을 가리킴
    size: 3
};
```

- **삭제 과정**: 만약 `table.delete(0)`을 호출하여 항목을 삭제하면, 테이블의 내부 구조는 다음과 같이 변경됩니다

```js
const tableInternals = {
    hashTable: [0, 1],
    dataTable: [
        {
            key: undefined, // 삭제된 항목
            value: undefined,
            chain: 2
        },
        {
            key: 1,
            value: 'b',
            chain: -1
        },
        {
            key: 2,
            value: 'c',
            chain: -1
        },
        // 빈 슬롯
    ],
    nextSlot: 3,
    size: 2 // 갱신된 크기
};
```

- **추가적인 삽입** : 만약 두 개의 항목을 더 추가하려고 한다면, 현재 용량을 초과하게 되어 **재해싱(rehashing)** 이 필요합니다. 기존 데이터는 더 큰 해시 테이블로 옮겨져야 하며, 이 과정은 성능에 영향을 줄 수 있습니다.

## Set

- **Set** 은 `Map` 과 동일한 결정론적 해시 테이블 알고리즘을 사용합니다. `value` 프로퍼티가 없다는 것만 제외하고는 `Map`과 내부적으로 동일하게 동작합니다. 즉, `Set`은 유일한 값(key)만을 저장하며, 순차 실행 시 삽입된 순서를 보장합니다.

## 저장 및 삭제 과정

- 새로운 항목이 테이블에 삽입될때 마다 `dataTable` 의 인덱스 `nextSlot` 위치에 저장되며, `chain` 을 사용해 다음 항목으로 연결됩니다. 새로 저장된 항목이 버킷 체인의 마지막 요소로 업데이트 됩니다.
- 삭제 시, `Entry` 의 `key` 와 `value` 를 `undefined` 로 설정해 공간을 차지하지만 내용이 비워지며, 필요할 때 **리사이징(resizing)** 이 발생 합니다.
- **리사이징(resizing)** 은 테이블이 가득 찼거나(항목이 모두 차 있는 상태), 많은 항목이 삭제되어 빈 공간이 많아진 경우에 발생합니다. 리사이징 시 기존 데이터를 새 해시 테이블로 재배치하는 **재해싱(rehashing)** 이 이루어 집니다.

## 순차 실행 (Iteration)

- 이러한 구조에서는 `Map` 의 **순차 실행(iteration)** 이 단순히 `dataTable` 을 반복하는 것으로 이루어집니다. 즉, `dataTable` 을 통해서 항목들을 순서대로 접근하기 때문에 **삽입된 순서를 보장할 수 있습니다** 

## 해시 테이블의 저장용량(Capacity)

- V8 엔진에서 `Map` 의 저장 용량은 항상 **2의 거듭제곱** 형태를 가지며, 초기에는 2개의 버킷으로 시작합니다.
- **저장 계수(Load Factor)**  : 테이블의 용량은 `2 * number_of_buckets` 이며, 테이블이 특정 용량을 넘어서면 자동으로 **2배로 증가** 합니다.
- 최대 용량 : 64비트 시스템에서는 약 1,670만개의 항목을 저장 할 수 있습니다.
- **증가/축소 계수(Grow Factor/Shrink Factor)** : 용량을 **2배씩 증가** 또는 **축소** 합니다.
	- Map이 4개의 항목을 저장하면 다음 삽입부터는 기존의 2배 크기의 새로운 해시테이블을 만들어 재해싱합니다.
- 저장 계수(load factor)는 2와 같은 상수로 테이블의 저장 용량이 `2 * number_of_buckets` 임을 의미
- 비어 있는 Map을 생성하면 내부 해시테이블에 2개의 버킷이 있고, 이때 테이블은 4개 항목까지 저장 할 수 있다.

### 저장

```js
const map = new Map();
let prevBuckets = 0;
for (let i = 0; i < 100; i++) {
  if (prevBuckets !== map.buckets) {
    console.log(`size: ${i}, buckets: ${map.buckets}, capacity: ${map.buckets * 2}`);
    prevBuckets = map.buckets;
  }
  map.set({}, {});
}
```

```bash
size: 0, buckets: 2, capacity: 4
size: 5, buckets: 4, capacity: 8
size: 9, buckets: 8, capacity: 16
size: 17, buckets: 16, capacity: 32
size: 33, buckets: 32, capacity: 64
size: 65, buckets: 64, capacity: 128
```

> Map의 저장 용량은 다 차면 2의 거듭제곱 꼴로 커진다.

### 삭제

```js
const map = new Map();
for (let i = 0; i < 100; i++) {
  map.set(i, i);
}
console.log(`initial size: ${map.size}, buckets: ${map.buckets}, capacity: ${map.buckets * 2}`);

let prevBuckets = 0;
for (let i = 0; i < 100; i++) {
  map.delete(i);
  if (prevBuckets !== map.buckets) {
    console.log(`size: ${map.size}, buckets: ${map.buckets}, capacity: ${map.buckets * 2}`);
    prevBuckets = map.buckets;
  }
}
```

```bash
initial size: 100, buckets: 64, capacity: 128
size: 99, buckets: 64, capacity: 128
size: 31, buckets: 32, capacity: 64
size: 15, buckets: 16, capacity: 32
size: 7, buckets: 8, capacity: 16
size: 3, buckets: 4, capacity: 8
size: 1, buckets: 2, capacity: 4
```

> Map의 사이즈가 `number_of_buckets/2` 가 되도록 저장용량이 2배씩 축소 된다.

## 해시 함수와 충돌 처리

> V8 엔진에서 `Map` 의 키 값에 따라 적절한 해시 함수가 사용 됩니다.

- 숫자형 데이터 (예: Smis, heap number, BigInt 등) :  [충돌 확률이 낮다고 잘 알려진 해시 함수](https://github.com/nodejs/node/blob/238104c531219db05e3421521c305404ce0c0cce/deps/v8/src/utils/utils.h#L213) 를 사용
- 문자열과 유사한 값(string, symbol) : 문자열의 내용을 기반으로 해시 코드를 [계산](https://github.com/nodejs/node/blob/238104c531219db05e3421521c305404ce0c0cce/deps/v8/src/objects/string.cc#L1338) 한 다음 내부적으로 캐싱됩니다.
- 객체 데이터 : 난수를 기반으로 해시코드를 [계산](https://github.com/nodejs/node/blob/238104c531219db05e3421521c305404ce0c0cce/deps/v8/src/execution/isolate.cc?ref=jiwon.me#L3785) 되어 고유성을 보장하며, 내부적으로 캐싱됩니다.

## 시간 복잡도

- **평균 시간 복잡도** : `Map` 의 대부분의 연산 (`set` , `get` , `delete` )은 **O(1)** 의 시간 복잡도를 가집니다. 이는 해시 테이블의 특성상, 해시 함수가 항목을 고르게 분배하여 대부분의 경우 빠르게 접근할 수 있기 때문입니다.
- **최악의 경우** : 모든 항목이 동일한 해시 값을 가지게 되어 **하나의 버킷**에 모든 항목이 저장될 경우, **O(N)** 의 시간 복잡도가 발생할 수 있습니다. 이 경우 특정 항목을 찾기 위해 **N개의 항목을 순차적으로 탐색**해야 합니다. 특히, 테이블이 꽉 찼을 때 모든 항목이 하나의 체인으로 연결되어 있다면 성능이 급격히 저하될 수 있습니다.
- **최선의 경우** : 테이블이 가득 찼지만, 각 버킷에 **두 개의 항목만** 저장되어 있는 경우에는 **최대 2회 이동**만으로 항목을 찾을 수 있어 매우 효율적입니다.
- **재해싱 비용**: 해시 테이블이 용량을 초과하거나 너무 적을 때 **재해싱(rehashing)** 이 발생합니다. 재해싱은 **O(N)** 의 시간 복잡도를 가지며, 이는 새로운 해시 테이블을 힙(heap) 메모리에 할당하고 모든 기존 항목을 새로운 테이블로 옮기는 작업이 필요하기 때문입니다. 따라서, `map.set()` 연산이 예상보다 더 많은 비용이 발생할 수 있지만, **재해싱은 비교적 드물게 발생**하기 때문에 대부분의 경우에는 큰 문제가 되지 않습니다.
- **저장 용량 증가 (Grow)**  : 저장 용량이 다 차면 테이블은 재해싱을 통해 더 큰 크기의 새로운 해시 테이블로 데이터를 옮깁니다. 이 과정은 성능에 일시적인 영향을 미칠 수 있습니다.
- **저장 용량 축소 (Shrink)** : 반대로, 데이터가 줄어들어 용량이 충분히 적어지면 **용량 축소(shrinking)** 가 발생하여 메모리 사용을 최적화 합니다.

## Node.js에서 Map/Set 사용 최적화

### 1. 일괄 처리

[루프로 하나씩 추가하는 V8 코드 참조](https://github.com/v8/v8/blob/main/src/objects/ordered-hash-table.cc#L70) 
[모든 항목을 한번에 추가할 때 V8 코드 참조](https://github.com/v8/v8/blob/main/src/objects/ordered-hash-table.cc#L18) 

```js
// 방법 1: forEach
const map1 = new Map();
// 4개 추가 -> OK
// 5번째 추가 -> 재해싱 (capacity 8로 증가)
// 8개 추가 -> OK
// 9번째 추가 -> 재해싱 (capacity 16으로 증가)
data.forEach(item => map1.set(item.key, item.value));

// 방법 2: entries
const entries = data.map(item => [item.key, item.value]);
// 처음부터 capacity 16으로 테이블 생성
// 모든 항목 한 번에 삽입
const map2 = new Map(entries);
```

**루프로 하나씩 추가할 때**

1. 초기 capacity가 기본 4로 시작
2. 항목이 추가될 때마다 capacity 검사
3. capacity 초과 시 재 해싱 발생

**모든 항목을 한번에 추가할 때**

1. 초기 capacity를 미리 계산 할 수 있다.
2. 필요한 크기의 테이블을 한번에 할당.
3. 모든 항목을 한 번에 삽입한다.

> 결국 일괄 처리 하는 방식은 다음과 같은 이점을 가져 옵니다.

1. 재해싱 횟수 최소화
2. 메모리 재할당 횟수 감소
3. 전체적인 성능 향상

### 2. 메모리 관리

[delete 메서드 사용 V8 코드 참조](https://github.com/v8/v8/blob/main/src/objects/ordered-hash-table.cc#L349) 
[clear 메서드 사용 V8 코드 참조](https://github.com/v8/v8/blob/main/src/objects/ordered-hash-table.cc#L108) 


```js
// 방법 1: delete
keysToDelete.forEach(key => map1.delete(key));


// 방법 2: clear 후 필요한 부분 새 데이터로 한번에 초기화
// 대량 삭제 시 - 메모리 즉시 정리
map2.clear();
// 새 데이터로 한 번에 초기화
const entries = newData.map(item => [item.key, item.value]);
const newMap = new Map(entries);
```

**루프로 하나씩 삭제 할 때**

1. 삭제된 요소 자리는 hole로 남는다.
2. 메모리 단편화 발생
3. 삭제된 요소가 capacity의 절반 이상이면 자동 재해싱

**일괄 삭제 후 재 할당**

1. 새로운 빈 테이블로 교체
2. 이전 메모리 즉시 해제 한다.
3. 새로운 데이터를 한 번에 삽입 가능하다.

> 결국 일괄 삭제 후 재 할당 방식은 다음과 같은 이점을 가져 옵니다.

1. 재해싱 횟수 최소화
2. 즉시 메모리 정리, 새로운 할당으로 단편화 없음
3. 전체적인 성능 향상

# 결론

## 1. 내부 구현 방식

- **데이터 구조**: JavaScript의 `Map`과 `Set`은 일반적으로 **해시 테이블**을 기반으로 구현됩니다. 각 엔진(V8 등)은 ECMAScript 표준만 준수한다면 내부 최적화 방식을 자유롭게 사용할 수 있습니다.
- **저장 및 조회**:
    - 내부적으로 **OrderedHashTable**을 사용하여 삽입 순서를 유지합니다.
    - 각 엔트리는 체인 방식(단방향 링크드 리스트)으로 연결되어 충돌을 처리합니다.
- **Set** :  `value` 프로퍼티가 없다는 것만 제외하고는 `Map`과 내부적으로 동일하게 동작합니다. 즉, `Set`은 유일한 값(key)만을 저장하며, 순차 실행 시 삽입된 순서를 보장합니다.

## 2. 시간 복잡도

- **평균적인 경우**: 모든 기본 연산 (`set`, `get`, `delete`)은 일반적으로 **O(1)** 시간 복잡도를 가집니다.
- **최악의 경우**: 여러 요소가 같은 버킷에 저장되어 체인이 길어지면 **O(N)** 시간 복잡도로 성능이 저하될 수 있습니다.

## 3. 해시 함수와 충돌 처리

- **숫자형 키**: V8 엔진은 충돌을 최소화하는 잘 알려진 해시 함수를 사용합니다.
- **문자열 및 심볼 키**: 내용에 기반해 해시 코드를 계산하고 내부적으로 캐시합니다.
- **객체 키**: 난수를 기반으로 해시 코드를 계산하여 중복을 방지합니다. 내부적으로 캐싱됩니다.

## 4. 메모리 관리와 용량 조절

- 용량 : 초기 버킷 수는 항상 **2의 거듭제곱**입니다.
	- **Grow Factor** : 용량 초과 시, 해시 테이블의 저장 용량을 2배로 증가 시킵니다.
    - **Load Factor**: 엔트리 수가 버킷 수의 2배에 도달하면 해시 테이블의 용량이 **2배로 증가**합니다.
    - **Shrink Factor**: 엔트리가 버킷 수의 절반 이하로 줄어들면 해시 테이블의 용량이 **절반으로 축소**됩니다.
- **재해싱(Rehashing)**: 리사이징이 발생할 때 모든 요소를 새로운 테이블로 **재해싱**하기 때문에 잠깐 성능 저하가 발생할 수 있습니다.

# Reference

[참고링크1]([https://262.ecma-international.org/15.0/#sec-map-objects](https://262.ecma-international.org/15.0/#sec-map-objects) ) 
[참고링크2]([https://github.com/v8/v8/tree/main](https://github.com/v8/v8/tree/main) ) 
[참고링크3](https://itnext.io/v8-deep-dives-understanding-map-internals-45eb94a183df) 
[참고링크4](https://v8.github.io/api/head/classv8_1_1Object.html) 
[참고링크5](https://v8.dev/blog/hash-code) 
[참고링크6](https://v8.dev/features/weak-references) 
[참고링크7](https://github.com/puzpuzpuz/node/commit/3d319644c33d1c4933f7bd80b3abd53bdbba2212) 




