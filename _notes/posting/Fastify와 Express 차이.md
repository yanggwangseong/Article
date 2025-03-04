---
title: fastify와 express 차이
permalink: 
tags:
  - fastify
  - express
  - nestjs
layout: page
---
https://yokan.netlify.app/fastify%EC%99%80-express-%EC%B0%A8%EC%9D%B4


# 서론

*NestJS*의 프로젝트에서 기본 설정값인 *Express Adaptor*에서 *Fastify Adaptor*로 변경만으로 RPS가 급격하게 증가하고 반대로 특정 API에서는 RPS가 오히려 줄어드는 경험을 하였습니다.

(TODO) 결과 표시

# NestJS에서 어떻게 호출할까?

```ts
// FastifyAdaptor로 교체 하기 위해서 2번째 인자값에 넣어주면 됩니다.
// 비어 있을경우 default는 express adaptor입니다.
const app = await NestFactory.create<NestFastifyApplication>(
	AppModule,
	new FastifyAdapter(),
	options,
);

export declare class NestFactoryStatic {
    private readonly logger;
    private abortOnError;
    private autoFlushLogs;
    /**
     * Creates an instance of NestApplication.
     *
     * @param module Entry (root) application module class
     * @param options List of options to initialize NestApplication
     *
     * @returns A promise that, when resolved,
     * contains a reference to the NestApplication instance.
     */
    create<T extends INestApplication = INestApplication>(module: any, options?: NestApplicationOptions): Promise<T>;
    /**
     * Creates an instance of NestApplication with the specified `httpAdapter`.
     *
     * @param module Entry (root) application module class
     * @param httpAdapter Adapter to proxy the request/response cycle to
     *    the underlying HTTP server
     * @param options List of options to initialize NestApplication
     *
     * @returns A promise that, when resolved,
     * contains a reference to the NestApplication instance.
     */
    create<T extends INestApplication = INestApplication>(module: any, httpAdapter: AbstractHttpAdapter, options?: NestApplicationOptions): Promise<T>;
```

`NestFactory` 클래스의 static 메서드인 `create` 메서드는 인자값에 따라 오버로딩 할 수 있게 구현체가 구현 되어 있습니다.
즉, httpAdapter 부분이 비어 있는 경우는 default 값인 `express adaptor` 를 자동으로 사용합니다.

여기서 흥미로웠던점은 NestJS에서는 앞단의 adaptor 패턴을 통해서 express와 fastify뿐만 아닌 다른 http 프레임워크를 고려하여 `AbstractHttpAdapter` 를 상속 받아 구현 할 수 있게 제공 하고 있었습니다.

```ts
// https://github.com/nestjs/nest/blob/master/packages/platform-fastify/adapters/fastify-adapter.ts

export class FastifyAdapter<
  TServer extends RawServerBase = RawServerDefault,
  TRawRequest extends FastifyRawRequest<TServer> = FastifyRawRequest<TServer>,
  TRawResponse extends
    RawReplyDefaultExpression<TServer> = RawReplyDefaultExpression<TServer>,
  TRequest extends FastifyRequest<
    RequestGenericInterface,
    TServer,
    TRawRequest
  > = FastifyRequest<RequestGenericInterface, TServer, TRawRequest>,
  TReply extends FastifyReply<
    RouteGenericInterface,
    TServer,
    TRawRequest,
    TRawResponse
  > = FastifyReply<RouteGenericInterface, TServer, TRawRequest, TRawResponse>,
  TInstance extends FastifyInstance<
    TServer,
    TRawRequest,
    TRawResponse
  > = FastifyInstance<TServer, TRawRequest, TRawResponse>,
> extends AbstractHttpAdapter<TServer, TRequest, TReply> {

// https://github.com/nestjs/nest/blob/master/packages/platform-express/adapters/express-adapter.ts

export class ExpressAdapter extends AbstractHttpAdapter<
  http.Server | https.Server
> {

// https://github.com/nestjs/nest/blob/master/packages/core/adapters/http-adapter.ts
export abstract class AbstractHttpAdapter<
  TServer = any,
  TRequest = any,
  TResponse = any,
> implements HttpServer<TRequest, TResponse>
{
```

주목 해야 할 부분은 3가지 입니다.

- `platform-express`
- `platform-fastify`
- `AbstractHttpAdapter` 

(TODO) 엑스칼라 드로우 그림
express, fastify는 AbstractHttpAdapter를 상속 받는 Adapter 구현체
`NestFactory.create` 메서드를 통해서 사용자가 지정한 adapter를 기준으로 하여 NestJS 인스턴스를 생성 합니다.

(TODO) Adapter 패턴이란?

# Express와 Fastify에서 차이

## 테스트 환경

```ts
scenarios: {
	spike_test: {
		executor: "ramping-vus",
		startVUs: 0,
		stages: [
			{ duration: "2m", target: 500 }, // 1분 동안 VUs를 500으로 증가
			{ duration: "1m", target: 0 }, // 30초 동안 VUs를 0으로 감소
		],
	},
},
thresholds: {
	http_req_failed: ["rate<0.01"],
	http_req_duration: ["p(95)<2000"],
},
```

- 테스트 환경은 동일하게 진행 했고 `k6` 를 사용 하였습니다.
## 대상 API

```ts
@Controller("participations")
export class ParticipationsController {
    constructor(
        private readonly participationsService: ParticipationsService,
        private readonly articlesService: ArticlesService,
    ) {}

    @UseGuards(TokenOnlyGuard)
    @Get("articles/:articleId")
    async getParticipationsByArticle(
        @Param("articleId", new ParseIntPipe()) articleId: number,
        @Query("cursor", new ParseIntPipe()) cursor: number,
        @Query("limit", new ParseIntPipe()) limit: number,
    ) {
        const [participation, article] = await Promise.all([
            this.participationsService.getParticipationsByArticleId(
                articleId,
                cursor,
                limit,
            ),
            this.articlesService.findById(articleId),
        ]);

        return {
            ...participation,
            article,
        };
    }
}
```

- 특정 아티클 ID에 해당하는 참여자 리스트를 가져오는 간단한 GET api입니다.

**Express Adaptor**

|항목|값|설명|
|---|---|---|
|**Latency (P90)**|352.96ms|90% 요청 응답 시간|
|**RPS**|1070/s|초당 처리된 요청 수|
|**startVUs**|0|시작 사용자 수|
|**MaxVUs**|500|최대 가상 사용자 수|

**Fastify Adaptor** 

| 항목                  | 값        | 설명              |     |
| ------------------- | -------- | --------------- | --- |
| **Latency (P90)**   | 137.13ms | 90% 요청 응답 시간    |     |
| **RPS**             | 2000/s   | 초당 처리된 요청 수     |     |
| **PreAllocatedVUs** | 0        | 미리 할당된 가상 사용자 수 |     |
| **MaxVUs**          | 500      | 최대 가상 사용자 수     |     |

아무런 최적화를 하지도 않았고 정말 단순히 앞단의 *adaptor* 를 *fastify* 로 변경만 하였는데 RPS가 2배나 늘어난걸 알 수 있었습니다.
처음에는 저는 *fastify* 자체가 *express* 보다 엄청난 성능을 가지고 있는건가 생각이 들었습니다.


## 문제 

여기서 재밌는점은 *POST API* 는 오히려 성능저하가 발생 했습니다.

### 대상 API

- 유저 생성 POST API

```ts
@IsPublicDecorator(IsPublicEnum.PUBLIC)
@Post("sign-up")
signUp(@Body() dto: RegisterMemberDto) {
	return this.authService.registerByEmail(dto);
}
```


**Express Adaptor**

(TODO) 결과

**Fastify Adaptor**

(TODO) 결과


## 원인

문제의 원인은 정확히는 `Express` 와 `Fastify` 의 차이가 아니라 `Fastify` 의 동작 방식의 차이에 있었습니다.