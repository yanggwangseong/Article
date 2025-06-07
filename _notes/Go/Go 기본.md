---
title: Go 기본
permalink: /Go/tutorial
tags:
  - go
layout: node
image: /assets/golang01.png
category: Go
description: Go Basic 타입과 var와 const
---

![](/assets/golang01.png)

## Go학습

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

## Pointer

```go
func main() {
	i, j := 42, 2701

	p:= &i // i의 pointer
	fmt.Println(*p) // p는 i의 pointer가 담겨 있으니까 *를 통해서 해당 포인터의 값 출력 
	*p = 21 // 포인터 p의 값이 21 &p->i , *p = 21 -> i = 21
	fmt.Println(i) // 21

	p = &j
	*p = *p / 37 // *p = 2701 /37 이 결과값을 다시 포인터p에 할당하니까 j도 같이 바뀐다.
	fmt.Println(j) // 73

	fmt.Println("test") // test
	
}

```

## Struct

```go
// struct
type Vertex struct {
	x int
	y int
}



// func main(){
// 	fmt.Println(Vertex{1, 2})
// }

func main(){
	v := Vertex{1, 2}
	v.x = 10
	fmt.Println(v.x) // 10
}

```


## Reference

- [Go Docs](https://go.dev/doc/) 
