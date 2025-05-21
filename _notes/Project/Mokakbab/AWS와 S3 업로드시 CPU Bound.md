---
title: AWS와 S3 업로드시 CPU Bound
permalink: /project/mokakbab/trouble-shooting/6
tags:
  - Troubleshooting
  - mokakbab
  - nestjs
  - s3
  - aws
  - post
layout: page
image: /assets/Mokakbab06.png
category: NestJS
---

![](/assets/Mokakbab06.png)

## AWS와 S3 업로드시 CPU Bound

- 🐙 **[모각밥 프로젝트(GitHub)](https://github.com/f-lab-edu/Mokakbab)** 
- 🔗 **[PR #82 이슈 링크](https://github.com/f-lab-edu/Mokakbab/pull/82)** 

---

### 📚 Contents

1. 개요
2. 문제
3. 문제 해결 및 결과

---

### 개요

**동작 Flow** 

![](/assets/Mokakbab13.png)

- `@nestjs/platform-express` - `MulterModule` - `multer` 
-  `@aws-sdk/client-s3`
- `multer-s3` 
- `lib-storage` 
- `AWS SDK JS` - `signature-v4`

1. `@nestjs/platform-express` 에서 `multer` 를 사용하기 위한 `MulterModule` 을 제공 해줍니다.
2. `@aws-sdk/client-s3` 를 통해서 AWS 인증 정보 및 S3 정보를 통해서 인증 처리를 위한 `s3` 객체를 생성합니다.
3. `multer-s3` 에서 해당 `s3` 객체를 가지고 파일 업로드를 진행 합니다.
	- `multer-s3` 란?
		- `multer` 에서 [Multer Storage Engine](https://github.com/expressjs/multer/blob/master/StorageEngine.md) 을 규격에 맞게 커스텀하면 `multer` 에서 사용 할 수 있게 커스텀 엔진을 제공 해주는데 해당 라이브러리가 `multer` 과 `s3` 에서 사용 할 수 있게 해당 엔진을 커스텀한 라이브러리 입니다.
4. `multer-s3` 에서 파일 업로드를 위한 `lib-storage` 를 호출합니다.
5. `lib-storage` 에서 파일 업로드 요청을 위해서 `signature-v4` 를 통해서 `sign` 하여 파일 업로드를 실행 합니다.

---

### 문제

![](/assets/Mokakbab12.png)

- 가장 CPU 사용률이 높은곳 `signature-v4` 인증관련 라이브러리입니다.

```js
// 라인 159줄
var getPayloadHash = /* @__PURE__ */ __name(async ({ headers, body }, hashConstructor) => {
  for (const headerName of Object.keys(headers)) {
    if (headerName.toLowerCase() === SHA256_HEADER) {
      return headers[headerName];
    }
  }
  if (body == void 0) {
    return "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855";
  } else if (typeof body === "string" || ArrayBuffer.isView(body) || (0, import_is_array_buffer.isArrayBuffer)(body)) {
    const hashCtor = new hashConstructor();
    hashCtor.update((0, import_util_utf82.toUint8Array)(body));
    return (0, import_util_hex_encoding.toHex)(await hashCtor.digest());
  }
  return UNSIGNED_PAYLOAD;
}, "getPayloadHash");
```

- `getPayloadHash` 부분이 문제이고 이를 호출 하는 부분은 `signRequest` 입니다.

```js
// 470줄
  async signRequest(requestToSign, {
    signingDate = /* @__PURE__ */ new Date(),
    signableHeaders,
    unsignableHeaders,
    signingRegion,
    signingService
  } = {}) {
const credentials = await this.credentialProvider();
    this.validateResolvedCredentials(credentials);
    const region = signingRegion ?? await this.regionProvider();
    const request = prepareRequest(requestToSign);
    const { longDate, shortDate } = formatDate(signingDate);
    const scope = createScope(shortDate, region, signingService ?? this.service);
    request.headers[AMZ_DATE_HEADER] = longDate;
    if (credentials.sessionToken) {
      request.headers[TOKEN_HEADER] = credentials.sessionToken;
    }
    const payloadHash = await getPayloadHash(request, this.sha256);
    if (!hasHeader(SHA256_HEADER, request.headers) && this.applyChecksum) {
      request.headers[SHA256_HEADER] = payloadHash;
    }
```

- 업로드 요청시에 `signRequest` 를 요청하는데 `getPayloadHash` 에 영향을 줄 수 있는 요소들은 바로 `request` 와 관련된것들입니다.

### getPayloadHash

- headers에 toLowerCase한게 SHA256_HEADER와 같은지 확인하고 아니라면 바꿔주는곳 입니다.
- 하나의 파일 업로드 상황에서는 항상 바뀝니다.

```js
} else if (typeof body === "string" || ArrayBuffer.isView(body) || (0, import_is_array_buffer.isArrayBuffer)(body)) {
```

- `header` 값
	- `x-amz-context- sha256-"f1c59f2091f6fbfa77f462998cc5d53d96bee00df6a3efdfb9d8d011b7cf3c68"`  

**S3 업로드시에 x-amz-context 헤더값을 업로드 요청마다 항상 포함해서 전송합니다** 

파일 업로드시에 보안적인 이슈 때문에 해당 파일 업로드 요청에 대한 헤더값에 항상 암호화 하여 업로드 하기 때문에 해당 부분의 CPU Bound 문제가 발생합니다.

---

### 문제 해결 및 결과

**파일 업로드시 보안적인 이슈 때문에 해당 파일을 항상 암호화 하여 업로드 하기 때문에 추후에 성능 개선을 위해서는 서버 리소스를 늘리는 방법이 필요합니다.** 

