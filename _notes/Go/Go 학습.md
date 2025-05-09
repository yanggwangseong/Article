---
title: Go 학습
permalink: /Go/tutorial
tags:
  - go
layout: page
---

![](/assets/golang01.png)

## Go학습

**Go 공식 문서가 생각보다 친절한 자료들이 많이 있습니다** 

1. [A Tour of Go](https://go.dev/tour/list) 
2. [Effective Go](https://go.dev/doc/effective_go) 

- [Go 공식문서](https://go.dev/doc/) 

## Basic

### `var`

> A `var` statement can be at package or function level. We see both in this example.

- 즉, variable의 범위가 package와 함수 level에만 존재 한다는걸 뜻합니다.

### `:= (Short Variable)`

```go
package main

import "fmt"

// var i, j int = 1, 2 선언과 초기화를 짧게 할 수 있다.

func main() {
	i := 1; j :=2
	var c, python, java = true, false, "no!"
	fmt.Println(i, j, c, python, java) // 1 2 false false false
}

```

- 자동으로 `int` 로 타입추론이 되는듯 합니다.

### Basic 타입

```go
bool

string

int  int8  int16  int32  int64
uint uint8 uint16 uint32 uint64 uintptr

byte // alias for uint8

rune // alias for int32
     // represents a Unicode code point

float32 float64

complex64 complex128
```

### Zero values

> 초기값 설정이 없는 변수에 자동으로 값이 할당 됩니다.

```go
package main

import "fmt"

func main() {
	var i int
	var f float64
	var b bool
	var s string
	fmt.Printf("%v %v %v %q\n", i, f, b, s) // 0 0 false ""
}
```

### `const`

```go
package main

import "fmt"


const golang bool = true

func main(){
	// golang = false 변경 불가
	fmt.Println(golang)
}

```

