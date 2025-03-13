
1. Spring Boot에서는 E2E 테스트 환경을 전역으로 유지 가능

Spring Boot에서는 **테스트 환경을 전역으로 띄워놓고 재사용**할 수 있습니다.

- `@SpringBootTest`는 **애플리케이션을 한 번 띄운 후 여러 개의 테스트 케이스에서 재사용**이 가능합니다.
- **싱글턴 컨텍스트**를 유지하기 때문에 API 호출을 반복적으로 수행하는 경우에도 서버가 다시 초기화되지 않음.

Spring Boot E2E 테스트 예제

```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureMockMvc
public class GlobalE2ETest {

    @Autowired
    private TestRestTemplate restTemplate; // 전역적으로 재사용 가능

    @Test
    public void testCreateUser() {
        UserRequest request = new UserRequest("testUser", "test@example.com");
        ResponseEntity<UserResponse> response = restTemplate.postForEntity("/users", request, UserResponse.class);
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
    }

    @Test
    public void testGetUser() {
        ResponseEntity<UserResponse> response = restTemplate.getForEntity("/users/1", UserResponse.class);
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
    }
}

```

- Spring에서는 `@SpringBootTest`로 애플리케이션을 한 번만 띄운 후 여러 테스트 케이스에서 재사용 가능
- 서버가 여러 테스트 간 공유되므로, 여러 API 테스트를 효율적으로 수행 가능


2. NestJS에서는 supertest가 기본적으로 매 테스트마다 새로운 서버를 부트스트랩

NestJS에서 `supertest`를 사용하는 경우, 일반적으로 **매 테스트마다 새로운 서버 인스턴스를 생성**합니다.

- 각 테스트에서 `app.init()`을 호출할 때마다 NestJS 서버가 새로 실행됨.
- 따라서 하나의 서버를 전역적으로 유지하면서 여러 개의 테스트를 수행하기 어려움.

NestJS supertest E2E 테스트 (기본적인 방식)

```ts
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';

describe('Users E2E Test', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('/users (POST)', async () => {
    return request(app.getHttpServer())
      .post('/users')
      .send({ username: 'testUser', email: 'test@example.com' })
      .expect(201);
  });

  it('/users (GET)', async () => {
    return request(app.getHttpServer())
      .get('/users/1')
      .expect(200);
  });
});
```

- 여기서는 `beforeAll()`에서 한 번만 `app.init()`을 호출하여 전역적으로 NestJS 인스턴스를 유지하는 방식
- 하지만, 테스트가 많아지면 `supertest`에서 서버가 공유되지 않는 문제가 발생할 수 있음


# QA)

- 스프링에서는 전역 컨텍스트를 통해서 각각의 E2E 테스트마다 컨텍스트를 재사용 할 수 있다.
- 하지만 NestJS에서는 기본적으로 하나의 E2E 테스트에서 앱을 부트스트랩하고 종료한다.
- 그렇다면 여러 API인 경우에 NestJS에서는 어떻게 E2E 테스트들을 한번에 실행 시키거나 시나리오 테스트를 할 수 있을까?
	- E2E API 테스트가 여러개인경우 Script 명령어로 한번에 e2e 테스트를 실행하는경우
	- 유저 시나리오 테스트 즉, 인수 테스트를 실행하는 경우


방법 1: `test-utils.ts`를 이용한 전역 NestJS E2E 컨텍스트 유지

이 방법은 **NestJS 애플리케이션을 한 번만 생성하고, 이를 여러 E2E 테스트에서 재사용**할 수 있도록 `test-utils.ts` 파일을 만들어 **전역적으로 `app`을 캐싱하는 방식**입니다.

1. `test-utils.ts` 파일 생성 (전역 앱 유지)

```ts
// test-utils.ts
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { AppModule } from '../src/app.module';

let app: INestApplication;

export async function getApp(): Promise<INestApplication> {
  if (!app) {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  }
  return app;
}

export async function closeApp() {
  if (app) {
    await app.close();
  }
}
```

✅ getApp()
→ 앱이 존재하지 않으면 초기화하고 반환 (전역적으로 유지)
✅ closeApp()
→ 테스트 종료 시 애플리케이션을 한 번만 종료

2. 개별 E2E 테스트에서 `getApp()` 사용 

E2E 테스트 1

```ts
import * as request from 'supertest';
import { getApp } from './test-utils';

describe('Users E2E Test', () => {
  let app;

  beforeAll(async () => {
    app = await getApp();
  });

  it('/users (POST)', async () => {
    return request(app.getHttpServer())
      .post('/users')
      .send({ username: 'testUser', email: 'test@example.com' })
      .expect(201);
  });

  it('/users (GET)', async () => {
    return request(app.getHttpServer())
      .get('/users/1')
      .expect(200);
  });
});

```

E2E 테스트 2

```ts
import * as request from 'supertest';
import { getApp } from './test-utils';

describe('Auth E2E Test', () => {
  let app;

  beforeAll(async () => {
    app = await getApp();
  });

  it('/auth/login (POST)', async () => {
    return request(app.getHttpServer())
      .post('/auth/login')
      .send({ username: 'testUser', password: 'password123' })
      .expect(200);
  });
});
```

E2E 테스트 3

```ts
import * as request from 'supertest';
import { getApp, closeApp } from './test-utils';

describe('Products E2E Test', () => {
  let app;

  beforeAll(async () => {
    app = await getApp();
  });

  it('/products (GET)', async () => {
    return request(app.getHttpServer())
      .get('/products')
      .expect(200);
  });

  afterAll(async () => {
    await closeApp(); // 마지막 테스트에서 애플리케이션 종료
  });
});

```

### 동작 방식

1. **`getApp()`을 호출하면 앱이 존재하지 않을 경우 한 번만 초기화** → 모든 E2E 테스트에서 동일한 앱 인스턴스를 재사용  
2. **각 테스트 케이스에서 `app.getHttpServer()`로 API 요청 수행**  
3. **마지막 테스트(`Products E2E Test`)에서 `closeApp()`을 호출하여 애플리케이션 종료**

### 결과

- **NestJS 애플리케이션이 한 번만 부트스트랩됨**
- **각 테스트 간 애플리케이션 컨텍스트가 공유됨**
- **마지막 테스트가 종료될 때 `app.close()`가 호출되어 서버가 정상 종료됨**


방법 2: Jest의 `setup` & `teardown` 활용 (`globalSetup` & `globalTeardown`)

Jest의 `globalSetup`과 `globalTeardown`을 활용하면,  
**NestJS 앱을 처음 한 번만 부트스트랩하고, 테스트가 끝날 때 종료하도록 설정**할 수도 있습니다.

1. Jest 설정 파일 (`jest.config.js`) 추가

```js
module.exports = {
  globalSetup: './test/global-setup.js',
  globalTeardown: './test/global-teardown.js',
};
```

2. `global-setup.js` (앱 초기화)

```js
const { Test } = require('@nestjs/testing');
const { AppModule } = require('../src/app.module');

global.__APP__ = null;

module.exports = async function () {
  const moduleFixture = await Test.createTestingModule({
    imports: [AppModule],
  }).compile();

  global.__APP__ = moduleFixture.createNestApplication();
  await global.__APP__.init();
};
```

- `global.__APP__`을 이용해 **전역 NestJS 애플리케이션 인스턴스를 생성**

3. `global-teardown.js` (앱 종료)

```js
module.exports = async function () {
  if (global.__APP__) {
    await global.__APP__.close();
  }
};
```

### 동작 방식

1. **Jest가 실행될 때 `global-setup.js`가 실행되어 NestJS 앱을 한 번만 띄움**  
2.  **각 테스트에서 `global.__APP__`을 통해 동일한 앱을 사용**  
3.  **모든 테스트가 종료되면 `global-teardown.js`에서 `app.close()`를 호출하여 종료**

### 결과

- **NestJS 애플리케이션이 한 번만 부트스트랩됨** (모든 테스트에서 공유)
- **Jest 실행이 끝날 때 자동으로 종료**
- **테스트 실행 속도가 빨라짐**

