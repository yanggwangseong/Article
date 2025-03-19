---
title: fastify와 express 차이
permalink: 
tags:
  - fastify
  - express
  - nestjs
layout: page
---

- [모각밥 프로젝트 Express Adaptor Repository 브랜치](https://github.com/f-lab-edu/Mokakbab/tree/feature/express-adaptor) 
- [모각밥 프로젝트 Fastify Adaptor Repository 브랜치](https://github.com/f-lab-edu/Mokakbab/tree/feature/88-change-adaptor-for-performance) 

# 서론

[NestJS 공식문서에서도 Performance로 Fastify가 소개 되어있습니다](https://docs.nestjs.com/techniques/performance) 
NestJS에서 밴치마크 결과도 제공 해주고 있습니다 [벤치마크 결과 링크](https://github.com/nestjs/nest/blob/master/benchmarks/all_output.txt) 

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

💡`nestjs/platform` 패키지는 NestJS 버전에 맞게 Express와 Fastify를 특정 의존성 버전 패키지를 설치하고 그것에 맞게 동작 할 수 있게 랩핑한 라이브러리입니다. 정확히는 `Express` 와 `Fastify` 와 완전히 똑같이 동작한다고 볼 수 없습니다. 그래서 위의 링크에 NestJS에서 제공하는 밴치마크 결과도 4개이고 미약하게나마 차이는 있습니다.

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
platform 랩핑 라이브러리 언급 NestJS 버전에 맞는 express와 fastify 관리

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

- 특정 아티클 ID에 해당하는 참여자 리스트를 가져오는 간단한 GET API 입니다.

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

### platform-fastify와 platform-express 동작 차이

#### Request 차이

```ts
// https://github.com/nestjs/nest/blob/master/packages/core/adapters/http-adapter.ts#L24
// AbstractHttpAdapter
public get(handler: RequestHandler);
  public get(path: any, handler: RequestHandler);
  public get(...args: any[]) {
    return this.instance.get(...args);
  }

  public post(handler: RequestHandler);
  public post(path: any, handler: RequestHandler);
  public post(...args: any[]) {
    return this.instance.post(...args);
  }


// https://github.com/nestjs/nest/blob/master/packages/platform-fastify/adapters/fastify-adapter.ts#L294
// platform-fastify
...
public get(...args: any[]) {
    return this.injectRouteOptions('GET', ...args);
  }

  public post(...args: any[]) {
    return this.injectRouteOptions('POST', ...args);
  }

  public head(...args: any[]) {
    return this.injectRouteOptions('HEAD', ...args);
  }

  public delete(...args: any[]) {
    return this.injectRouteOptions('DELETE', ...args);
  }
...

// platform-express
// 부모 클래스 AbstractHttpAdapter 메서드를 그대로 상속 받아서 사용 합니다.
```

- `platform-express` 는 부모 클래스인 `AbstractHttpAdapter` 를 그대로 상속 받아 해당 `get, post` 등 메서드를 호출 하는 모습 입니다.
- `platform-fastify` 은 `get, post` 등의 메서드를 오버라이딩하여 `injectRouteOptions` 메서드를 호출하여 리턴 하고 있습니다.

**injectRouteOptions** 가 핵심인것 같습니다. 이는 아래에서 다시 다뤄보겠습니다.

#### Response 차이

```ts
// https://github.com/nestjs/nest/blob/00bb79721a27a5cf548c6c2fef7a8f6ac03ce9b0/packages/core/adapters/http-adapter.ts#L154C3-L154C65
// AbstractHttpAdapter
abstract reply(response: any, body: any, statusCode?: number);

 // https://github.com/nestjs/nest/blob/00bb79721a27a5cf548c6c2fef7a8f6ac03ce9b0/packages/platform-fastify/adapters/fastify-adapter.ts#L367
  // platform-fastify
public reply(
    response: TRawResponse | TReply,
    body: any,
    statusCode?: number,
  ) {
    const fastifyReply: TReply = this.isNativeResponse(response)
      ? new Reply(
          response,
          {
            [kRouteContext]: {
              preSerialization: null,
              preValidation: [],
              preHandler: [],
              onSend: [],
              onError: [],
            },
          },
          {},
        )
      : response;

    if (statusCode) {
      fastifyReply.status(statusCode);
    }

...
...
...

// https://github.com/nestjs/nest/blob/00bb79721a27a5cf548c6c2fef7a8f6ac03ce9b0/packages/platform-express/adapters/express-adapter.ts#L62
// platform-express
public reply(response: any, body: any, statusCode?: number) {
    if (statusCode) {
      response.status(statusCode);
    }
    if (isNil(body)) {
      return response.send();
    }
    if (body instanceof StreamableFile) {
      const streamHeaders = body.getHeaders();
      if (
        response.getHeader('Content-Type') === undefined &&
        streamHeaders.type !== undefined
      ) {
        response.setHeader('Content-Type', streamHeaders.type);
      }
  ...
  ...

```

- `platform-express` 와 `platform-fastify` 둘다 부모 클래스의 `reply` 추상 메서드를 오버라이딩 하는 모습 입니다.
- 이는 다른 Adaptor를 새로 추가 하더라도 수행 해야 하는 작업인것 같습니다. 부모 클래스인 `AbstractHttpAdapter` 에서는 `reply` 뿐만 아니라 오버라이딩이 필요한 메서드는 추상메서드로 선언 해두었습니다. [추상 메서드 코드 링크](https://github.com/nestjs/nest/blob/00bb79721a27a5cf548c6c2fef7a8f6ac03ce9b0/packages/core/adapters/http-adapter.ts#L154C3-L154C65) 를 보게 되면 해당하는 추상 메서드들을 adaptor에서 구현체를 구현하게끔 의도하는 목적인것 같습니다.

### 차이점 분석

#### injectRouteOptions

```ts
// platform-fastify
private injectRouteOptions(
    routerMethodKey: Uppercase<HTTPMethods>,
    ...args: any[]
  ) {
    const handlerRef = args[args.length - 1];
    const isVersioned =
      !isUndefined(handlerRef.version) &&
      handlerRef.version !== VERSION_NEUTRAL;
    const routeConfig = Reflect.getMetadata(
      FASTIFY_ROUTE_CONFIG_METADATA,
      handlerRef,
    );

    const routeConstraints = Reflect.getMetadata(
      FASTIFY_ROUTE_CONSTRAINTS_METADATA,
      handlerRef,
    );

    const hasConfig = !isUndefined(routeConfig);
    const hasConstraints = !isUndefined(routeConstraints);

    const routeToInject: RouteOptions<TServer, TRawRequest, TRawResponse> &
      RouteShorthandOptions = {
      method: routerMethodKey,
      url: args[0],
      handler: handlerRef,
    };

    if (isVersioned || hasConstraints || hasConfig) {
      const isPathAndRouteTuple = args.length === 2;
      if (isPathAndRouteTuple) {
        const constraints = {
          ...(hasConstraints && routeConstraints),
          ...(isVersioned && {
            version: handlerRef.version,
          }),
        };

        const options = {
          constraints,
          ...(hasConfig && {
            config: {
              ...routeConfig,
            },
          }),
        };

        const routeToInjectWithOptions = { ...routeToInject, ...options };

        return this.instance.route(routeToInjectWithOptions);
      }
    }
    return this.instance.route(routeToInject);
  }
```

- `handleRef`

```ts
// handlerRef
async (req, res, next) => {
  try {
      await targetCallback(req, res, next);
  }
  catch (e) {
      const host = new execution_context_host_1.ExecutionContextHost([req, res, next]);
      exceptionsHandler.next(e, host);
      return res;
  }
}


```

- `this.instance.route` 

```ts
// instance.route 메서드를 호출 할때 route는 fastify 메서드 입니다.
// https://github.com/fastify/fastify/blob/dd358cb1f3c6e7f7c7e6fe9273e2c26f86dec7a1/fastify.js#L284
...

// extended route
route: function _route (options) {
  // we need the fastify object that we are producing so we apply a lazy loading of the function,
  // otherwise we should bind it after the declaration
  return router.route.call(this, { options })
},

...

```

즉, Fastify의 Route 옵션들을 예를 들면 [NestJS 문서에서 Fastify Route Config](https://docs.nestjs.com/techniques/performance#route-config) ,  [NestJS 문서에서 Fastify route-constraints](https://docs.nestjs.com/techniques/performance#route-constraints) 등의 옵션들을 추가할 수 있게 하기 위한 오버라이딩 메서드입니다.

### Reply

```ts
// platform-fastify
	reply(response, body, statusCode) {
        const fastifyReply = this.isNativeResponse(response)
            ? new Reply(response, {
                [symbols_1.kRouteContext]: {
                    preSerialization: null,
                    preValidation: [],
                    preHandler: [],
                    onSend: [],
                    onError: [],
                },
            }, {})
    ...
    ...
    return fastifyReply.send(body);
}
// https://github.com/fastify/fastify/blob/dd358cb1f3c6e7f7c7e6fe9273e2c26f86dec7a1/lib/reply.js#L126

```

- Response시에 `platform-fastify` -> `fastify/lib/reply.js Reply.send` 메서드를 호출합니다.

### NestJS router-execution-context

```ts
// https://github.com/nestjs/nest/blob/00bb79721a27a5cf548c6c2fef7a8f6ac03ce9b0/packages/core/router/router-execution-context.ts#L414

public createHandleResponseFn(
    callback: (...args: unknown[]) => unknown,
    isResponseHandled: boolean,
    redirectResponse?: RedirectResponse,
    httpStatusCode?: number,
  ): HandleResponseFn {
    const renderTemplate = this.reflectRenderTemplate(callback);
    if (renderTemplate) {
      return async <TResult, TResponse>(result: TResult, res: TResponse) => {
        return await this.responseController.render(
          result,
          res,
          renderTemplate,
        );
      };
    }
    if (redirectResponse && isString(redirectResponse.url)) {
      return async <TResult, TResponse>(result: TResult, res: TResponse) => {
        await this.responseController.redirect(result, res, redirectResponse);
      };
    }
    const isSseHandler = !!this.reflectSse(callback);
    if (isSseHandler) {
      return <
        TResult extends Observable<unknown> = any,
        TResponse extends HeaderStream = any,
        TRequest extends IncomingMessage = any,
      >(
        result: TResult,
        res: TResponse,
        req: TRequest,
      ) => {
        this.responseController.sse(
          result,
          (res as any).raw || res,
          (req as any).raw || req,
          { additionalHeaders: res.getHeaders?.() as any },
        );
      };
    }
    return async <TResult, TResponse>(result: TResult, res: TResponse) => {
      result = await this.responseController.transformToResult(result);
      !isResponseHandled &&
        (await this.responseController.apply(result, res, httpStatusCode));
      return res;
    };
  }
```

1. `render Template` 이 있는 경우
2. `redirect` 가 있는경우
3. `SSE` 가 있는경우
4. 일반적인 Restful API의 Response의 경우 


**즉, Fastify의 Reply send 이후의 결과가 마지막으로 NestJS router-execution-context에 의해 처리 되고 있습니다.** 

## ⚠️ 잘못된 지식

1. [Fastify](https://fastify.dev/docs/v4.29.x/Reference/Validation-and-Serialization/#validation-and-serialization) 의 핵심 코어 기능중에서 [JSON Schema](https://json-schema.org/) 를 베이스로한 `Reqeust Validation` 에서는 [Ajv](https://www.npmjs.com/package/ajv) 를 `Response Serialization` 에서는 [fast-json-stringify](https://www.npmjs.com/package/fast-json-stringify) 를 사용 합니다. ❌
2. Express와 Fastify중에서 Fastify만 Routing에 Promise를 지원 합니다. ❌
	- 아래에서 Express 콜백기반과 Fastify의 Promise기반 처리를 다루겠습니다.

### 1. JSON Schema

`NestJS에서 platform-fastify를 사용할때` `class-transformer` 와 `class-validation` 을 사용하여 Validation과 Serialization을 사용하기 때문에 해당 Fastify의 JSON Schema 방식으로 사용하고자 한다면 따로 설정을 해주어야 합니다.

### 2. Routing Promise

```ts
// fastify
fastify.get('/', options, async function (request, reply) {}
// express ❌
app.get('/example/b', (req, res, next) => {}
// express ✅
app.get('/example/b', async (req, res, next) => {}
```

- Express 공식문서의 [best-practice-performance](https://expressjs.com/en/advanced/best-practice-performance.html#use-promises) 부분을 보면 `use promise` 즉, Promise를 사용하라는 내용이 나와 있습니다.

# Core 1: Routing

## Express

```js
// express.js
app.use = function use(fn) {
  // ......
  var fns = flatten.call(slice.call(arguments, offset), Infinity);
  
  fns.forEach(function (fn) {
    router.use(path, fn);  // 라우터에 순차적으로 추가
  }, this);
  // ......
};
```

- Express는 라우팅이 O(N)만큼 탐색 합니다.

## Fastify

### Fastify의 라우팅 엔진: find-my-way

- [find-my-way](https://www.npmjs.com/package/find-my-way/v/7.5.0) 는 Fastify에서 사용하는 요청 URL을 빠르게 라우팅 하기 위해서 **Radix Tree** 기반의 **라우팅 라이브러리** 입니다.

### Radix Tree란?

- **Radix Tree**는 접두사(Prefix)를 공유하는 트리 구조로, 라우트 탐색을 최적화 합니다.
- URL이 공유하는 **공통 접두사를 하나의 노드로** 사용하여 **검색 속도를 줄이고 메모리 사용을 최적화** 합니다.

```ts
            ""
          /    \
     users   posts
      /  \
    :id  create

```




# Core 2: 비동기 처리

## Express

- **Express는 handler에서 비동기 처리에 대한 최적화되어 있지 않습니다.** 
- 콜백 기반 미들웨어 체인
	- `각 미들웨어는 (req, res, next) 형태의 콜백 체인으로 연결됩니다` 
- 즉, router 함수에서 `async` 를 통해서 handler 함수를 호출 하더라도 `Express` 내부적으로는 콜백기반으로 처리 되고 있습니다.

```js
app.handle = function handle(req, res, callback) {
  // final handler
  var done = callback || finalhandler(req, res, {
    env: this.get('env'),
    onerror: logerror.bind(this)
  });

  // set powered by header
  if (this.enabled('x-powered-by')) {
    res.setHeader('X-Powered-By', 'Express');
  }

  // set circular references
  req.res = res;
  res.req = req;

  // alter the prototypes
  Object.setPrototypeOf(req, this.request)
  Object.setPrototypeOf(res, this.response)

  // setup locals
  if (!res.locals) {
    res.locals = Object.create(null);
  }

  this.router.handle(req, res, done);
};
```

## Fastify

```js
// fastify/lib/route.js L420 routeHandler
// HTTP request entry point, the routing has already been executed

function routeHandler (req, res, params, context, query) {
...
...
    if (context.onRequest !== null) {
      onRequestHookRunner(
        context.onRequest,
        request,
        reply,
        runPreParsing
      )
    } else {
      runPreParsing(null, request, reply)
    }
...
...
```

1. 비동기 파이프라인 패턴을 구현하여 요청 처리를 단계별로 분리
2. onRequest -> runPreParsing -> handleRequest로 이어지는 명확한 비동기 실행 흐름



- 비동기 훅 실행 최적화
	- Fastify는 모든 훅(hook)들을 비동기적으로 실행하며, 콜백 체인을 통해 다음 단계로 진행합니다. 이는 각 단계가 이벤트 루프를 블로킹하지 않도록 보장합니다.

```ts
if (context.onRequest !== null) {
  onRequestHookRunner(
	context.onRequest,
	request,
	reply,
	runPreParsing
  )
} else {
  runPreParsing(null, request, reply)
}
```




```ts
// lib/wrapThenable.js
function wrapThenable (thenable, reply, store) {
  if (store) store.async = true
  thenable.then(function (payload) {
    // ... 비동기 응답 처리
  })
}
```

- 모든 핸들러의 응답을 Promise로 래핑하여 비동기 처리를 보장합니다.

# Reference

- [ https://docs.nestjs.com/techniques/performance]( https://docs.nestjs.com/techniques/performance) 

- [https://fastify.dev/docs/latest/Reference/Routes/](https://fastify.dev/docs/latest/Reference/Routes/) 

- [https://github.com/nestjs/nest/tree/master/packages/platform-express](https://github.com/nestjs/nest/tree/master/packages/platform-express) 

- [https://github.com/nestjs/nest/tree/master/packages/platform-fastify](https://github.com/nestjs/nest/tree/master/packages/platform-fastify) 
- [Radix Tree](https://en.wikipedia.org/wiki/Radix_tree)
- [라우팅 최적화](https://ankitpandeycu.medium.com/unleashing-the-potential-of-radix-tree-35e6c5d3b49d) 
