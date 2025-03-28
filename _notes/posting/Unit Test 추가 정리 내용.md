
# Unit Test

- Unit Test란?
- Mock, Stub, Fake란?
- First-Class Test (좋은 테스트 코드의 특징)
- F.I.R.S.T 원칙 (Fast, Independent, Repeatable, Self-validating, Timely)
- 패턴
	- AAA 패턴
	- Given-When-Then 패턴
		- given-when-then 패턴이란 1개의 단위 테스트를 3가지 단계로 나누어 처리하는 패턴으로, 각각의 단계는 다음을 의미한다.
- Case
	- Edge-Case와 Corner Case
- **유닛 테스트 작성 범위**
	- 다른곳에서 제공하는 단위다? 외부 라이브러리나 프레임워크에서 제공하는 기능
		- 유닛 테스트를 해당 라이브러리나 프레임워크에서 보장한다고 가정하고 위임
	- 개발자가 작성한 단위 service, repository라면 unit test 작성
	- **controller에 단위테스트를 작성 해야하나요?** 
		- e2e 테스트를 통해서 controller 코드도 테스트 하기 떄문에 커버리지가 올라가는데 그렇다면 controller의 unit test는 작성하지 않아도 되지 않나?
- 단일 책임 원칙 (SRP)과 유닛 테스트의 관계
- 의존성 주입(DI)과 테스트 용이성
- 부작용(Side Effect)이 없는 코드 = 테스트하기 쉬운 코드
- 과도한 Mocking은 smell이 될 수 있다
- 테스트 커버리지 맹신 X


- [망나니 개발자 Test 1편](https://mangkyu.tistory.com/143) 
- [망나니 개발자 Test 2편](https://mangkyu.tistory.com/144) 
- [망나니 개발자 Test 3편](https://mangkyu.tistory.com/145) 
- [유닛 테스트 AAA패턴, 테스트 픽스터, 명명법](https://kukim.tistory.com/47) 
- **Mock, Stub, Fake** 
- First-Class Test (좋은 테스트 코드의 특징)
- F.I.R.S.T 원칙 (Fast, Independent, Repeatable, Self-validating, Timely)
- AAA 패턴
- Given-When-Then 패턴
	- given-when-then 패턴이란 1개의 단위 테스트를 3가지 단계로 나누어 처리하는 패턴으로, 각각의 단계는 다음을 의미한다.
- Test Pyramid (테스트의 계층 구조: Unit > Integration > E2E)
- 유닛 테스트는 어디까지 작성해야할까?
	- controller?, service?, repository?
	-  왜 `gaurd, pipe, filter, decorator` 등은 Unit Test를 작성하지 않는 걸까?
- **질문) 유닛 테스트 작성 범위**
	- 다른곳에서 제공하는 단위다? 외부 라이브러리나 프레임워크에서 제공하는 기능
		- 유닛 테스트를 해당 라이브러리나 프레임워크에서 보장한다고 가정하고 위임
	- 개발자가 작성한 단위 service, repository라면 unit test 작성
- **질문) Mock, Stub, Fake 범위** 
- **질문 중요) controller에 단위테스트를 작성 해야하나요?** 
	- e2e 테스트를 통해서 controller 코드도 테스트 하기 떄문에 커버리지가 올라가는데 그렇다면 controller의 unit test는 작성하지 않아도 되지 않나?
- Test 커버리지란?
- Edge-Case와 Corner Case


# Reference

- [nestjs docs - Testing](https://docs.nestjs.com/fundamentals/testing) 
- [jest docs](https://jestjs.io/docs/using-matchers) 

