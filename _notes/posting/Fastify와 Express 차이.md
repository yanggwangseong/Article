---
title: fastify와 express 차이
permalink: 
tags:
  - fastify
  - express
  - nestjs
layout: page
---

- [Express Adaptor Repository](https://github.com/f-lab-edu/Mokakbab/tree/feature/express-adaptor) 
- [Fastify Adaptor Repository](https://github.com/f-lab-edu/Mokakbab/tree/feature/88-change-adaptor-for-performance) 

# 서론

[NestJS 공식문서에서도 Performance로 Fastify가 소개 되어있습니다](https://docs.nestjs.com/techniques/performance) 
NestJS에서 밴치마크 결과도 제공 해주고 있습니다 [링크](https://github.com/nestjs/nest/blob/master/benchmarks/all_output.txt) 

```ts
-----------------------
nest (with "@nestjs/platform-express")
-----------------------
Running 10s test @ http://localhost:3000
1024 connections

┌─────────┬───────┬───────┬───────┬───────┬──────────┬──────────┬────────┐
│ Stat    │ 2.5%  │ 50%   │ 97.5% │ 99%   │ Avg      │ Stdev    │ Max    │
├─────────┼───────┼───────┼───────┼───────┼──────────┼──────────┼────────┤
│ Latency │ 61 ms │ 64 ms │ 71 ms │ 94 ms │ 65.44 ms │ 17.35 ms │ 325 ms │
└─────────┴───────┴───────┴───────┴───────┴──────────┴──────────┴────────┘
┌───────────┬─────────┬─────────┬─────────┬─────────┬─────────┬────────┬─────────┐
│ Stat      │ 1%      │ 2.5%    │ 50%     │ 97.5%   │ Avg     │ Stdev  │ Min     │
├───────────┼─────────┼─────────┼─────────┼─────────┼─────────┼────────┼─────────┤
│ Req/Sec   │ 14183   │ 14183   │ 15767   │ 15991   │ 15640   │ 501.13 │ 14182   │
├───────────┼─────────┼─────────┼─────────┼─────────┼─────────┼────────┼─────────┤
│ Bytes/Sec │ 3.06 MB │ 3.06 MB │ 3.41 MB │ 3.45 MB │ 3.38 MB │ 108 kB │ 3.06 MB │
└───────────┴─────────┴─────────┴─────────┴─────────┴─────────┴────────┴─────────┘

Req/Bytes counts sampled once per second.

156k requests in 10.24s, 33.8 MB read

-----------------------
nest (with "@nestjs/platform-fastify")
-----------------------
Running 10s test @ http://localhost:3000
1024 connections

┌─────────┬───────┬───────┬───────┬───────┬──────────┬──────────┬────────┐
│ Stat    │ 2.5%  │ 50%   │ 97.5% │ 99%   │ Avg      │ Stdev    │ Max    │
├─────────┼───────┼───────┼───────┼───────┼──────────┼──────────┼────────┤
│ Latency │ 31 ms │ 33 ms │ 38 ms │ 52 ms │ 34.41 ms │ 11.73 ms │ 245 ms │
└─────────┴───────┴───────┴───────┴───────┴──────────┴──────────┴────────┘
┌───────────┬─────────┬─────────┬────────┬─────────┬─────────┬─────────┬─────────┐
│ Stat      │ 1%      │ 2.5%    │ 50%    │ 97.5%   │ Avg     │ Stdev   │ Min     │
├───────────┼─────────┼─────────┼────────┼─────────┼─────────┼─────────┼─────────┤
│ Req/Sec   │ 24911   │ 24911   │ 30031  │ 30335   │ 29470.4 │ 1564.48 │ 24907   │
├───────────┼─────────┼─────────┼────────┼─────────┼─────────┼─────────┼─────────┤
│ Bytes/Sec │ 3.81 MB │ 3.81 MB │ 4.6 MB │ 4.64 MB │ 4.51 MB │ 239 kB  │ 3.81 MB │
└───────────┴─────────┴─────────┴────────┴─────────┴─────────┴─────────┴─────────┘

Req/Bytes counts sampled once per second.

295k requests in 10.17s, 45.1 MB read
```

평균 Latency값만 비교하면 2배나 차이난다는것을 밴치마크 결과 지표로 알려주고 있습니다.
그렇다면 Express에서 Fastify로 변경 하기만해도 높은 performance를 얻을것이라고 예상이 되었습니다.

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

## 테스트 결과 비교
### 테스트 환경

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
### 대상 API

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

## Fastify가 왜 빠를까?




# Reference

- https://docs.nestjs.com/techniques/performance

- https://fastify.dev/docs/latest/Reference/Routes/

- https://github.com/nestjs/nest/tree/master/packages/platform-express

- https://github.com/nestjs/nest/tree/master/packages/platform-fastify


