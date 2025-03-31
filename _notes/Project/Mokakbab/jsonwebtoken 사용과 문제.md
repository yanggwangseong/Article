---
title: jsonwebtoken 사용과 문제
permalink: /project/mokakbab/trouble-shooting/1
tags:
  - jwt
  - Troubleshooting
  - mokakbab
  - nestjs
layout: page
---

## jsonwebtoken 사용과 문제

- 🐙 **[모각밥 프로젝트(GitHub)](https://github.com/f-lab-edu/Mokakbab)** 
- 📑 [**V1 프로젝트 리포트**](https://curvy-wood-aa3.notion.site/V1-192135d46c8f803caaa6f10c2faeb4b2?pvs=4) 

---

### 📚 Contents

1. 개요
2. 문제
3. 문제 해결 및 결과

---

### 개요

- NestJS와 jwt 호출 개요 
 


---

### 문제

1. jsonWebtoken의 createPublicKey
2. async와 sync

[개선전 수정 X 게시물 리스트 API 노션 링크](https://curvy-wood-aa3.notion.site/X-API-180135d46c8f80479b51c7e751f0f72d?pvs=4)

초당 처리 할 수 있는 요청의 수인 (RPS)가 `0.987/s` 로 처참한 모습입니다.

문제를 확인 하기 위해서 플레임 그래프를 지원하는 도구인 **Clinicjs** 를 활용 하였습니다.

![](/assets/Mokakbab01.png)

문제가 발생하고 있는 구간을 살펴보면 **createPublicKey** 라는것을 알 수 있습니다.

#### createPublicKey

**jsonWebtoken 라이브러리에서 `verfiy.js` 에서 호출되는 함수 입니다. 정확히는 nodejs의 crypto 모듈에서 호출되는 함수입니다.** 

대칭키, 비대칭키에 대한것이 있고 검증할때 항상 `createPublicKey` 를 호출 합니다.

암호화 알고리즘에 따라서 호출하는 순서가 달라지긴 하나 `createPublicKey` 와 `createSecretKey` 함수를 crypto에서 호출 하는것은 변하지 않았습니다.

즉, 매번 요청마다 지속적으로 해당 함수들을 호출하고 있고 해당 `crypto` 모듈에서 제공하는 함수들은 **굉장히 CPU Intensive한 작업이기 때문에** 그만큼 CPU 바운드 문제가 발생 했습니다.

```js
// jsonwebtoken L120 ~ L130
if (secretOrPublicKey != null && !(secretOrPublicKey instanceof KeyObject)) {
      try {
        secretOrPublicKey = createPublicKey(secretOrPublicKey);
      } catch (_) {
        try {
          secretOrPublicKey = createSecretKey(typeof secretOrPublicKey === 'string' ? Buffer.from(secretOrPublicKey) : secretOrPublicKey);
        } catch (_) {
          return done(new JsonWebTokenError('secretOrPublicKey is not valid key material'))
        }
      }
    }

```

이를 해결하기 위해서 먼저 개요에서 나타나는것처럼 호출 순서와 지속적인 호출을 막기위해서 해결 할 수 있는 방법이 필요 하였습니다.
#### async와 sync

```ts
// auth.service.ts 모각밥 프로젝트에서 verify 코드
...
...
verifyToken(token: string) {
try {
	return this.jwtService.verify(token, {
		secret: this.configService.get<string>(ENV_JWT_SECRET_KEY),
	});
} catch {
	throw new BusinessErrorException(MemberErrorCode.INVALID_TOKEN);
}
...
...
```

**jwtService에서 검증을 위한 verify 메서드를 호출하게 되면 이는 Promise를 지원하지 않은 Sync작업으로** 

Event-Loop가 Blocking되어 효율적인 Non-Blocking 작업처리가 되지 않았습니다.

`@nestjs/jwt` 에서 제공하는 `verifyAsync` 메서드로 변경하여 이를 해결 하였습니다.

---

### 문제 해결 및 결과

- 📘 **[노션 결과 리포트](https://curvy-wood-aa3.notion.site/v1-1-API-180135d46c8f804abf2bd6be14255686?pvs=4)** 
- 🔗 **[PR #72 이슈 링크](https://github.com/f-lab-edu/Mokakbab/pull/72)** 

1. jsonWebtoken의 createPublicKey
2. async와 sync

#### jsonWebtoken의 createPublicKey

- NestJS Module에서 key를 미리 생성하기

```ts
@Module({
    imports: [
        JwtModule.registerAsync({
            inject: [ConfigService],
            useFactory: (configService: ConfigService) => {
                const secretKeyString =
                    configService.get<string>(ENV_JWT_SECRET_KEY) || "secret";

                const keyObject = createSecretKey(Buffer.from(secretKeyString));

                return {
                    secret: keyObject as unknown as string,

                    signOptions: {
                        expiresIn: configService.get<string>(
                            ENV_JWT_ACCESS_TOKEN_EXPIRATION,
                        ),
                    },
                };
            },
        }),
        MembersModule,
    ],
    controllers: [AuthController],
    providers: [AuthService, MailsService],
    exports: [AuthService],
```

Module에서 JwtModule의 의존성을 주입할때 `useFactory` 를 통해서 **createSecretKey** 를 미리 생성하여 사용 할 수 있게 하였습니다.

![](/assets/Mokakbab02.png)

**이를 통해서 createSecretKey 호출이 사라진 결과의 플레임그래프를 볼 수 있었습니다** 
#### verifyAsync 메서드로 변경

- `verifyAsync` 메서드를 통해서 Promise를 지원할 수 있게 변경 하였습니다.

