---
title: Go Provider 패턴과 DI(Dependency Injection)
permalink: /go/provider-di
tags: 
layout: note
image: /assets/golang01.png
category: 
description: Go Provider 패턴과 DI(Dependency Injection)
---

![](/assets/golang01.png)

## 1. Go Provider 패턴과 DI(Dependency Injection)

Go Provider 패턴과 DI(Dependency Injection)


---


- Go의 설계 철학은 뭘까?
	- Go의 설계 철학 (단순성, 명시적 구성, 코드 생성보다 조립)
	- DI 기피 성향의 철학적 배경 설명
- DI(Dependency Injection)는 왜 필요할까?
- Go에서 DI(Dependency Injection) Strategy
	- constructor injection
	- manual wiring
	- provider pattern
- Uber의 Go Fx 라이브러리
	- DI framework 도입의 필요성과 이점
- Go Provider 패턴과 DI(Dependency Injection)
	- Go 언어의 minimal한 철학에 맞춘 예제

```go
package main

import "fmt"

type Logger struct{}
func NewLogger() *Logger {
    fmt.Println("Logger initialized")
    return &Logger{}
}
func (l *Logger) Log(msg string) {
    fmt.Println("[LOG]:", msg)
}

type UserService struct {
    logger *Logger
}
func NewUserService(logger *Logger) *UserService {
    return &UserService{logger: logger}
}
func (u *UserService) CreateUser(name string) {
    u.logger.Log("Creating user: " + name)
}

type App struct {
    userService *UserService
}
func NewApp(userService *UserService) *App {
    return &App{userService: userService}
}
func (a *App) Run() {
    a.userService.CreateUser("Alice")
}

func main() {
    logger := NewLogger()
    userService := NewUserService(logger)
    app := NewApp(userService)

    app.Run()
}

```


---

## Reference

- [Go Compile-time Dependency Injection Docs](https://go.dev/blog/wire) 
- [Uber Go Fx](https://github.com/uber-go/fx) 
- [jetbrain go DI](https://www.jetbrains.com/guide/go/tutorials/dependency_injection_part_one/) 
