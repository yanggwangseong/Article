---
title: stream-vs-buffer
permalink: /cs/os/operation-system/stream-vs-buffer
tags:
  - OS
layout: page
---

- Buffer
	- 데이터를 모으는 동작
- Stream
	- 데이터를 조금씩 전송 하는 동작

## Buffer와 Stream의 차이

✔ **Buffer**: 데이터를 **모아두는 그릇**  
✔ **Stream**: 데이터를 **조각(chunk) 단위로 흘려보내는 개념**

**즉, 버퍼(Buffer)는 데이터를 임시 저장하는 공간이고, 스트림(Stream)은 데이터를 조금씩(chunk 단위로) 보내거나 받는 방식**입니다.

### 🎯 **버퍼(Buffer) 개념**

- 메모리(RAM)에 데이터를 **임시로 저장**하는 역할
- 네트워크 통신, 파일 읽기/쓰기 등에서 사용됨
- 데이터가 일정량(버퍼 크기)만큼 모이면 한 번에 처리

💡 **예제: 버퍼 개념**

```js
const buffer = Buffer.from("Hello, World!");
console.log(buffer);
```

✔ **출력:** `<Buffer 48 65 6c 6c 6f 2c 20 57 6f 72 6c 64 21>`  
✔ **버퍼 역할:** `"Hello, World!"` 데이터를 **바이트 형태로 저장**

### 🎯 **스트림(Stream) 개념**

- 데이터를 **한 번에 전송하는 것이 아니라, chunk 단위로 나눠서 처리**
- **메모리를 효율적으로 사용**할 수 있음 (전체 데이터를 한 번에 로드하지 않음)
- **읽기(Read) 스트림 / 쓰기(Write) 스트림**으로 구분됨

💡 **예제: 스트림 개념 (파일 읽기)**

```js
const fs = require('fs');

const readStream = fs.createReadStream('example.txt', { encoding: 'utf-8' });

readStream.on('data', (chunk) => {
  console.log(`Received chunk: ${chunk}`);
});

readStream.on('end', () => {
  console.log('File read complete');
});
```

✔ **스트림 역할:** `example.txt`를 한 번에 다 읽지 않고 **chunk 단위로 조금씩 읽어옴**

### 🎯 **Buffer와 Stream의 관계**

✔ **버퍼(Buffer)** 는 데이터를 **모아두는 공간**  
✔ **스트림(Stream)** 은 데이터를 **버퍼에서 chunk 단위로 가져가서 처리**

📌 **비유하자면?**  
🚰 **수도꼭지(스트림)** 에서 물(데이터)이 나오는데, **양동이(버퍼)** 에 물이 차면 일정량씩 사용한다고 생각하면 됩니다.



# Reference

- https://f-lab.kr/insight/stream-vs-buffer
- [Buffer 위키피디아](https://en.wikipedia.org/wiki/Data_buffer) 




