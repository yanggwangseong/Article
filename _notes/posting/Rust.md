---
title: Rust
permalink: /rust
tags:
  - Rust
layout: page
---

# Rust

```rust
let / let mut  
→ 불변/가변 변수 선언. 기본은 불변으로 안전성 확보

fn  
→ 함수 선언 키워드

Ownership (소유권)  
→ 메모리 안전을 위한 핵심 개념. 값의 소유자는 단 하나

Borrowing (&, &mut)  
→ 소유권을 넘기지 않고 값 참조 가능. 불변/가변 차이 있음

Lifetimes ('a)  
→ 참조자가 유효해야 할 범위 명시. Use-after-free 방지

match  
→ 모든 경우를 명시해야 하는 패턴 매칭. exhaustive check

enum  
→ 여러 상태를 표현하는 열거형. Algebraic Data Types(ADT)

Option / Result  
→ Null과 예외 없는 안전한 값 처리. 명시적 오류 처리 방식

trait  
→ 인터페이스 추상화. 다형성 구현 (Go의 interface와 유사)

impl  
→ 구조체/열거형에 메서드 구현. OOP 스타일 지원

macro_rules!  
→ 매크로 시스템. 반복 제거 및 DSL 제작에 사용 가능

async / await  
→ 비동기 프로그래밍. Future 기반으로 non-blocking 처리

move  
→ 클로저에서 캡처한 값의 소유권을 이동시킴

unsafe  
→ 메모리 안전성 검사 우회. 고급 시스템 프로그래밍용

Box / Rc / Arc  
→ 힙 할당(Box), 참조 카운팅(Rc), 멀티스레드용 공유(Arc)
```

