---
title: Try Catch와 Response Type
permalink: Try Catch와 Response Type
tags: 
layout: page
image: /assets/cat01.png
---
## Try Catch와 Response Type

---

### 📚 Contents

1. 개요
2. 문제
3. 문제 해결 및 결과

---

```ts
// get-sentence-use-case

export interface GetSentenceResponse {
    date: string;
    sentence: string;
    meaning: string;
    vocab: SentenceDto[];
    videoUrl: string;
}

export interface GetSentenceError {
    error: boolean;
    message: string;
}

@Injectable()
export class GetSentenceUseCase implements IGetSentenceUseCase {
    constructor(
        @Inject(SENTENCES_REPOSITORY_TOKEN)
        private readonly sentencesRepository: ISentencesRepository,
    ) {}

    async execute(
        date: string,
    ): Promise<GetSentenceResponse | GetSentenceError> {
        const koreanDate = new Date(date).toLocaleDateString("sv-SE", {
            timeZone: "Asia/Seoul",
        });

        const sentence =
            await this.sentencesRepository.findOneByDate(koreanDate);

        if (!sentence) {
            return {
                error: true,
                message: "해당 날짜에 문장이 없습니다.",
            };
        }

        return {
            date: new Date(sentence.createdAt).toLocaleDateString("sv-SE", {
                timeZone: "Asia/Seoul",
            }),
            sentence: sentence.sentence,
            meaning: sentence.meaning,
            vocab: sentence.vocabs.map((v) => ({
                word: v.word,
                definition: v.definition,
            })),
            videoUrl: sentence.video?.videoUrl ?? "",
        };
    }
}
```

NotFound Exceoption을 위한 use-case Response이다. 유니온 타입으로 2개의 타입을 넣어주었는데 
여기에 만약에 `Try Catch` 가 추가되거나 또 다른 Exception 상황이 생긴다면 확장성 및 가독성이 굉장히 안좋을것이다.

물론 하나의 type을 통해서 묶는 방법으로 제네릭에 하나의 타입만 넣을 수 있긴 하나 이는 코드를 줄이는 효과밖에 없고 근본적인 문제를 해결하지 못한다.

```ts
// 이렇게 하나에 정의 할 수 있음
type TGetSentenceResponse = GetSentenceResponse | GetSentenceError;
```

결과적으로 `use-case` 를 통해서 관심사를 분리하여 하나의 작은 단위로 처리하기 때문에 Exception 상황이 많아지더라도 크게 불편하지 않을 수 있지만 문제는 이러한 `use-case` 들을 호출해서 비지니스 로직을 처리하는 `service` 레이어에 있다.


(TODO 코드예시)

이렇게 되어 있다면 애플리케이션 규모가 커지면 커질수록 Service Layer에서 type에 대한 확장성과 점점 가독성이 매우 안좋아 지게 된다.

또한 이는 결국 Unit Test에도 영향을 주게 되면서 테스트 하기 어려운 코드 결과를 초래하게 된다.

## Try<T,E>

## Response Type 설계


## Use Case와 비지니스 로직

```ts
// get-sentence.usecase.ts
@Injectable()
export class GetSentenceUseCase implements IGetSentenceUseCase {
    constructor(
        @Inject(SENTENCES_REPOSITORY_TOKEN)
        private readonly sentencesRepository: ISentencesRepository,
    ) {}

    async execute(
        date: string,
    ): Promise<GetSentenceResponse | GetSentenceError> {
        const koreanDate = new Date(date).toLocaleDateString("sv-SE", {
            timeZone: "Asia/Seoul",
        });

        const sentence =
            await this.sentencesRepository.findOneByDate(koreanDate);

        if (!sentence) {
            return {
                error: true,
                message: "해당 날짜에 문장이 없습니다.",
            };
        }
        ...
        ...
    }
}
```

use-case에서 비지니스 로직을 가지게 되면 안된다. 해당 비지니스 로직은 Service Layer에서 처리해야 하고 도메인 로직은 도메인에서 처리해야한다. 즉, use-case는 독립적이어야 한다.

왜냐하면 

확장성

get-sentence-use-case가 존재 하는지 확인하는 비지니스 로직을 가지게 되면서 높은 결합도 인해서 추후에 다른 service로직에서 호출할때의 예를 생각 해보자.

(TODO 코드 예시)

즉, 이렇게 강합 결합도를 가지게 된다면 use-case를 만든 의미가 없어지게 된다.

테스트하기 힘든 코드

해당 비지니스 로직을 결국 use-case에서도 테스트 해야하고 service에서도 테스트 해야되는 중복 테스트 코드가 생성된다.

타입관점에서의 강한 결합도

결국 타입 시스템 관점에서도 강한 결합도로 인해서 하나의 타입을 수정하게 되면 해당 부분이 전파된다.



---

## Reference
