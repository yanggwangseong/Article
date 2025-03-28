---
title: C++
permalink: /cpp
tags:
  - cpp
layout: page
---

# C++

```C++
1. pointer (*) / reference (&)
→ C++을 C++답게 만드는 메모리 주소/참조 개념

2. struct vs class
→ 둘 다 사용자 정의 타입이지만 기본 접근 제어자(public vs private) 차이 존재

3. this
→ 객체 자신을 가리키는 포인터. 메서드 내부에서 자기 자신 명확히 표현할 때 사용

4. constructor / destructor
→ 객체 생성/소멸 시 자동으로 호출. 메모리 및 자원 관리의 핵심

5. new / delete
→ 동적 메모리 직접 할당/해제. C++의 저수준 메모리 제어를 가능하게 함

6. RAII (Resource Acquisition Is Initialization)
→ 자원 관리를 객체 수명에 묶는 C++ 고유 철학 (키워드 X지만 개념적으로 핵심)

7. inline
→ 성능 최적화를 위한 함수 인라인화 지시어. 함수 호출 오버헤드 감소 목적

8. template
→ 제네릭 프로그래밍의 핵심. 타입을 매개변수처럼 다루는 기능

9. operator overloading
→ 연산자(+, -, == 등)를 클래스에 맞게 재정의. C++ 특유의 문법 표현력 강화

10. friend
→ 클래스 외부에서 내부 멤버에 접근 가능하게 해줌. 캡슐화 타협용

11. virtual / override / final
→ 다형성과 가상 함수 구조의 핵심. 런타임 바인딩 제어

12. pure virtual ( = 0 )
→ 추상 클래스 선언. 반드시 자식 클래스에서 구현하도록 강제

13. static
→ 클래스 단위의 멤버 변수/함수 선언 (인스턴스 없이 접근)

14. mutable
→ const 객체 안에서도 해당 멤버는 변경 가능

15. explicit
→ 생성자에서 암묵적인 타입 변환을 막기 위한 키워드

16. namespace
→ 이름 충돌 방지를 위한 C++만의 범위 지정

17. type aliasing (`typedef`, `using`)
→ 긴 타입을 짧게 정의. 특히 템플릿과 결합 시 유용
```

- [큰돌 C++](https://www.inflearn.com/course/10%EC%A3%BC%EC%99%84%EC%84%B1-%EC%BD%94%EB%94%A9%ED%85%8C%EC%8A%A4%ED%8A%B8-%ED%81%B0%EB%8F%8C) 
