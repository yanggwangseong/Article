---
title: Go Defer Panic Recover
permalink: /Go/defer-panic-recover
tags:
  - go
layout: page
---

![](/assets/golang01.png)

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

TODO : 1. panic Recover, 2. pointer

## Reference

- [go defer-panic-and-recover](https://go.dev/blog/defer-panic-and-recover) 
- [a tour of go](https://go.dev/tour/flowcontrol/12) 
