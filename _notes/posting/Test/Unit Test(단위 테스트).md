---
title: Unit Test(단위 테스트)
permalink: /unit-test
tags:
  - TDD
  - unit-test
layout: page
category: 
image: /assets/cat04.png
timepoint: 4h
realtimepoint:
---

## Unit Test

---

### 📚 Contents

1. 개요
2. 문제
3. 문제 해결 및 결과

---

- **beforeAll, beforeEach, afterEach, afterAll** 등의 테스트 라이프사이클 훅

1. 직접 모킹 방식 

- pure mock 객체 패턴
- 실제 메서드가 존재하지 않아도 동작

- jest.spyOn
- 진짜 메서드가 있는 객체 감시
- 원래 메서드를 감싸고 추적 가능
- 기존 객체의 일부만 mock 처리하고 싶을 때 유용

**`jest.fn()` 객체에는 `spyOn()` 쓰지 마세요 – 중복이고, 불필요** 

- spyOn은 실제 인스턴스또는 클래스의 메서드를 감시하거나 오버라이드 할때 사용한다.

```ts
// 실제 구현체를 감시하고 싶을 때
const realUseCase = new CreateSubscriberUseCase(...);
jest.spyOn(realUseCase, 'execute').mockResolvedValue(...);
```

- 모킹 객체는 전역에 선언하지 않아야 한다.

```ts
❌
const mockRepository = {
    findOne: jest.fn(),
    save: jest.fn(),
};

describe("SubscribersRepository", () => {
    let subscribersRepository: SubscribersRepository;
    let repository: Repository<SubscribersEntity>;

    beforeEach(async () => {
        const module: TestingModule = await Test.createTestingModule({
            providers: [
                SubscribersRepository,
                {
                    provide: getRepositoryToken(SubscribersEntity),
                    useValue: mockRepository,
                },
            ],
        }).compile();
...
✅
```

다른 테스트에 영향을 줄 수 있습니다.


## NestJS의 Test의 강력함

```ts
/**
 * sentences 모듈
 * @description 문장 관리 모듈
 * @author 양광성
 * @todo Dynamic Provider 설계가 필요함
 */
@Module({
    ...
    ...
    providers: [
        {
            provide: SENTENCES_SERVICE_TOKEN, // 의존성 주입 부분
            useClass: SentencesService,
        },
        {
            provide: SENTENCES_REPOSITORY_TOKEN,
            useClass: SentencesRepository,
        },
        {
            provide: GET_SENTENCE_USECASE_TOKEN,
            useClass: GetSentenceUseCase,
        },
        {
            provide: GET_WEEKLY_SENTENCES_USECASE_TOKEN,
            useClass: GetWeeklySentencesUseCase,
        },
        VocabsRepository,
        VideosRepository,
    ],
    exports: [],
})
// controller unit test
describe("sentencesController", () => {
    let controller: SentencesController;

    let mockSentencesService: jest.Mocked<ISentencesService>;

    beforeEach(async () => {
        mockSentencesService = {
            getSentences: jest.fn(),
            getWeeklySentences: jest.fn(),
        };

        const module: TestingModule = await Test.createTestingModule({
            controllers: [SentencesController],
            providers: [
                {
                    provide: SENTENCES_SERVICE_TOKEN,// 의존성 주입 부분
                    useValue: mockSentencesService,
                },
            ],
        }).compile();

        controller = module.get<SentencesController>(SentencesController);
    });
```

의존성 주입 부분을 실제 모듈로직과 Unit Test 코드에서의 의존성 주입 로직을 하나의 공통 관심사로 분리하여 관리 할 수 있다.

이는 매우 강력한 기능이라고 생각하고 종종 Unit Test 작성시에 의존성 주입에 대한 테스트 실패에서 자유로울 수 있게 되고 의존성 주입 코드를 추가적인 팩토리 패턴 함수를 통해서 관리하게 된다면 유지보수 측면에서 굉장히 유리하다. 즉, 좀 더 로직에 집중할 수 있게 된다.


---

## Reference
