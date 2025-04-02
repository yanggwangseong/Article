---
title: Go
permalink: /go
tags:
  - go
layout: page
---

# Go

```go
var / const  
→ 변수 선언 / 상수 선언

// 구조체 (struct)
// Go의 구조체는 복합 데이터를 표현하는 기본적인 타입입니다.
type Person struct {
    Name string
    Age  int
}

// 인터페이스 (interface)
// 인터페이스를 통해 다형성과 추상화를 구현할 수 있습니다.
type Greeter interface {
    Greet() string
}

// 동시성: 고루틴 (Goroutines)
// 'go' 키워드를 사용해 가벼운 스레드인 고루틴을 생성하여 동시성을 구현합니다.
func printMessage() {
    fmt.Println("Hello from a goroutine")
}

// 채널 (Channels)
// 고루틴 간의 통신 및 동기화를 위해 사용되는 기본 수단입니다.
func channelExample() {
    ch := make(chan int)
    go func() {
        ch <- 42  // 고루틴에서 채널에 값 전송
    }()
    val := <-ch  // 채널로부터 값 수신
    fmt.Println("Received:", val)
}

// select  
→ 여러 채널을 동시에 기다림. 채널 기반 조건 분기 처리


// defer
// 함수 종료 직전에 실행할 코드를 예약하여 자원 해제나 정리 작업에 사용합니다.
func main() {
    defer fmt.Println("Cleanup on exit")
    
    fmt.Println("Sum:", add(3, 5))
    
    // 고루틴 실행 예제
    go printMessage()
    
    // 채널 예제 실행
    channelExample()
    
    // 잠시 대기 (동시성 예제 때문에)
    fmt.Scanln()
}

// error  
→ Go의 오류 처리 기본 타입. 다중 반환으로 오류 전달

// panic / recover  
→ 예외 처리 메커니즘. 패닉 회복 시 사용

// defer / panic / recover
→ 예외 대신 오류를 값으로 다루는 설계 철학과, 예외가 아닌 제어 가능한 패닉 처리 흐름에 대한 이해 반영

```

구조체 + 인터페이스
→ Go의 객체지향 철학(구체적인 상속보다 인터페이스 기반 추상화, 암묵적 구현 철학 등)을 다룸

고루틴 + 채널 + select
→ Go의 동시성 모델(CSP 기반), Don't communicate by sharing memory; share memory by communicating 철학이 잘 담김

defer / panic / recover
→ 예외 대신 오류를 값으로 다루는 설계 철학과, 예외가 아닌 제어 가능한 패닉 처리 흐름에 대한 이해 반영

error 타입
→ 전통적인 예외가 아닌, 명시적인 다중 반환을 통해 오류를 처리하는 방식을 Go는 선호함

