---
title: Use Case에서 왜 비지니스 로직(도메인 로직)을 가지면 안될까?
permalink: /Use Case에서 왜 비지니스 로직(도메인 로직)을 가지면 안될까?
tags:
layout: page
image: /assets/cat01.png
---

## Use Case에서 왜 비지니스 로직(도메인 로직)을 가지면 안될까?

---

### 📚 Contents

1. 개요
2. 문제
3. 문제 해결 및 결과

---

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

## TODO 어떻게 분리할까?

- 도메인 생성 후 도메인 로직 빼야할까?
- middleware를 통해서 해당 `NotFound` 에 대한 관심사를 분리할까?

## 후기

테스트하기 좋은 방법을 찾으면서 리팩토링을 하다보니 점점 좋은 코드로 개선되어가는것 같습니다. 근본적으로 결국 이게 TDD가 아닌가 싶습니다.

---

## Reference
