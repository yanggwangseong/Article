---
title: Go Defer Panic Recover
permalink: /Go/defer-panic-recover
tags:
  - go
  - post
layout: page
image: /assets/golang01.png
category: Go
description: Go 언어에서 defer는 함수 종료 시점에 호출되는 지연 실행 메커니즘으로, 리소스 정리와 오류 처리에 유용하게 사용됩니다. panic은 예기치 못한 오류 상황에서 프로그램 흐름을 중단시키며, recover는 panic 상태에서도 흐름을 복구할 수 있도록 도와줍니다. 이 글에서는 defer의 평가 시점, 실행 순서, named return과의 관계를 다루고, panic과 recover를 활용한 예외 복구 패턴까지 실용적인 예제 중심으로 정리했습니다.
---

![](/assets/golang01.png)

## 📚 Contents

1. Defer
2. Panic
3. Recover

---

## Defer

### Defer

- Defer 명령문은 **주변 함수가 반환될 때까지 함수의 실행을 방어합니다** 
- 지연된 호출의 인수는 즉시 평가되지만 주변 함수가 반환될때까지 기능 호출이 실행되지 않습니다.

```go
func main(){
	// defer
	/*
	* defer 키워드를 사용하면 주변 함수가 반환될때까지 실행 되지 않는 성질을 가지고 있는것 같다.
	*/
	defer fmt.Println("world")

	fmt.Println("hello1")
	fmt.Println("hello2")
	fmt.Println("hello3")
	fmt.Println("hello4")
	/*
	* 출력 결과
	*	hello1
		hello2
		hello3
		hello4
		world --> 다른 함수들이 다 출력되고 난 후 출력된다.
	*/
}
```

### Stacking defers

- Defer 호출이 스택으로 밀려 나옵니다.
- 함수가 반환되면 연기된 호출은 마지막으로 최후의 순서로 실행됩니다.

```go
func stackingDefer() {
	fmt.Println("counting")
	for i := range 10 {
		defer fmt.Println(i)
	}
	fmt.Println("done")
}
/*
* 출력 결과
* counting
* done
* 9
* 8
* 7
* 6
* 5
* 4
* 3
* 2
* 1
* 0
*/
```

두 파일을 열고 한 파일의 내용을 다른 파일에 복사하는 함수

```go
func CopyFile(dstName, srcName string) (written int64, err error) {
    src, err := os.Open(srcName)
    if err != nil {
        return
    }

    dst, err := os.Create(dstName) // 실패 했을때 파일을 닫지 않는 문제
    if err != nil {
        return
    }

    written, err = io.Copy(dst, src)
    dst.Close()
    src.Close()
    return
}
```

문제점

- `os.create` 로의 호출이 실패하면 소스 파일을 닫지 않고 함수가 반환 됩니다.
	- 두번째 리턴 명령문 전에 `SRC.Close` 에 호출을함으로써 쉽게 해결할 수 있습니다.
- 하지만 함수가 더욱 복잡해지게 되는 경우에 문제를 쉽게 알아 차리고 해결되지 않을 수 있습니다.
- 이때 `Defer` 를 통해서 **파일이 항상 닫혀 있는지 확인 할 수 있습니다.** 

```go
func CopyFile(dstName, srcName string) (written int64, err error) {
    src, err := os.Open(srcName)
    if err != nil {
        return
    }
    defer src.Close()

    dst, err := os.Create(dstName)
    if err != nil {
        return
    }
    defer dst.Close()

    return io.Copy(dst, src)
}
```

- `Defer` 를 사용하면 **열린 직후 각 파일을 닫는 것에 대해 생각할 수 있으며, 함수의 리턴 명령문 수에 관계없이 파일이 닫히게 됩니다.** 

### Defer의 3가지 규칙

#### 1. defer로 등록한 함수의 인자(argument)는 defer문이 실행되는 순간에 평가된다.

```go
package main

import "fmt"

func main() {
    x := 10
    defer fmt.Println("Deferred:", x)
    x = 20
}
// 출력 : Deferred: 10
```

- `defer fmt.Println("Deferred:", x)` 이 줄이 실행될 **순간** → `x`의 값인 **10**이 이미 평가되어 **함수 인자로 저장**됩니다.
- 나중에 `main()` 종료 시 `fmt.Println()`이 실행되지만, 그때의 `x` 값 **(20)** 과는 관계없이 **이미 평가된 10**이 사용됩니다.

#### 2. defer로 등록된 함수들은 주변 함수가 반환된 후, 등록된 역순(LIFO)으로 실행된다.

```go
package main

import "fmt"

func main() {
    defer fmt.Println("1")
    defer fmt.Println("2")
    defer fmt.Println("3")
}
// 출력 
// 3
// 2
// 1
```

- **스택처럼** 나중에 `defer`한 함수부터 먼저 실행 됩니다.

#### 3. defer 함수는 리턴되는 함수의 이름이 지정된 반환 변수(named return value)를 읽거나 수정할 수 있다.

```go
func example() (result int) {
    defer func() {
        result = 42 // named return
    }()
    return 0
}
// 출력
// 42
```

- defer 함수는 주변 함수가 먼저 실행 함수의 `return 0` 문이 실행되면, 리턴값 `result`에 **0이 일단 할당**됨
- 그 후 **`defer` 함수가 실행되며 `result = 42`로 덮어씀**
- 최종적으로 `result`가 리턴됨

```go
func c() (i int) {
    defer func() { i++ }()
    return 1
}
// 출력
// 2
```

- 먼저 return 1이 실행된 후 defer 함수가 실행되면서 i값을 증가 시킨다.
- 1 + 1을 증가시켜서 최종적으로 2를 리턴한다.

**이러한 성질을 활용하여 함수의 오류 반환 값을 수정하는 데 편리합니다** 

## Panic

- `panic`은 일반적인 제어 흐름을 중단시키고 **"패닉 상태(panicking)"** 를 시작하는 Go의 내장 함수입니다.
- 함수 `F`에서 `panic`이 호출되면, `F`의 실행은 즉시 중단되고 `F` 내에서 `defer`로 예약된 함수들이 정상적으로 실행됩니다.
- 그 이후 `F`는 호출자에게 반환되지만, 호출자 입장에서는 마치 `panic`이 호출된 것처럼 동작합니다.
- 이러한 과정은 **현재 고루틴의 스택을 따라 거슬러 올라가며** 계속되며, 모든 함수가 반환되면 최종적으로 **프로그램은 크래시(비정상 종료)** 됩니다.
- `panic`은 직접 호출할 수도 있고, **배열 인덱스를 벗어난 접근** 같은 **런타임 오류**에 의해서도 자동으로 발생할 수 있습니다.

## Recover

`recover`는 **panic 상태에 빠진 고루틴의 제어권을 회복**하는 내장 함수입니다.  
`recover`는 **`defer` 함수 내부에서만 유용**하게 동작합니다.

- **정상적인 실행 중**에는 `recover()`를 호출해도 `nil`을 반환하며 아무런 효과가 없습니다.
- 하지만 **현재 고루틴이 panic 상태일 경우**, `recover()`는 `panic()`에 전달된 값을 **잡아내고(pick up)**, 프로그램 흐름을 **정상적으로 재개**할 수 있게 해줍니다.

---

## Reference

- [Go Docs](https://go.dev/doc/) 
