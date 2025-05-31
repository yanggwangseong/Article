---
title: Spring Data JDBC에서 N+1 Problem
permalink: /java/Spring Data JDBC에서 N+1 Problem
tags: 
layout: note
image: /assets/812.jpg
category: Java
description: Spring Data JDBC에서 N+1 Problem
---

## 1. Spring Data JDBC에서 N+1 Problem

---


정확히는 @MappedCollection 사용시 N+1 문제 발생



## 해결방법

- Spring Data JDBC 3.2.0-M2부터는 이러한 문제를 해결하기 위한 **Single Query Loading** 기능이 도입되었습니다. 이 기능은 Aggregate와 그에 속한 컬렉션들을 단일 SELECT 문으로 조회할 수 있게 해줍니다.



---

## Reference

- [Spring Data JDBC N+1](https://spring.io/blog/2023/08/31/this-is-the-beginning-of-the-end-of-the-n-1-problem-introducing-single-query) 
- [spring-jdbc-plus](https://github.com/naver/spring-jdbc-plus) 
