
# 안녕 NestJS

<p style="padding: 3em 1em; background: #f5f7ff; border-radius: 4px;">
  Take a look at <span style="font-weight: bold">[[Your first note]]</span> to get started on your exploration.
</p>

This digital garden template is free, open-source, and [available on GitHub here](https://github.com/maximevaillancourt/digital-garden-jekyll-template).

The easiest way to get started is to read this [step-by-step guide explaining how to set this up from scratch](https://maximevaillancourt.com/blog/setting-up-your-own-digital-garden-with-jekyll).

<strong>Recently updated notes</strong>

<ul>
  {% assign recent_notes = site.notes | sort: "last_modified_at_timestamp" | reverse %}
  {% for note in recent_notes limit: 5 %}
    <li>
      {{ note.last_modified_at | date: "%Y-%m-%d" }} — <a class="internal-link" href="{{ site.baseurl }}{{ note.url }}">{{ note.title }}</a>
    </li>
  {% endfor %}
</ul>

<style>
  .wrapper {
    max-width: 46em;
  }
</style>


# Articles

- 메인은 간단 소개 및 추천
	- 책 리스트
	- 기본기를 가장 중요하게 생각하고 어쩌고 저쩌고
- 아티클 탭에 아티클 list 표시

## Database

- LOCK
- Index
- Connection Pool

# my (2025~)

- type-collection ✅
	- **필요한 타입들 모음집** 
	- 나만의 타입 컬렉션 모음
- type-challenges ✅
	- **고급 타입연습** 
	- TS 타입 챌린지를 풀기
- DataStructure ✅ ⭐️⭐️⭐️⭐️⭐️
	- **(중요) 좋은 자료구조** 
	- TS 기반으로 자료구조와 알고리즘을 연구
	- python
- AlgoNote ✅ ⭐️⭐️⭐️⭐️⭐️
	- 알고리즘 문제를 풀면서 issue기반의 오답노트
	- TS 기반으로 여러 알고리즘 연구 (OS, 네트워크 등)
- ts-toolkit (with Jest, codekata) ⭐️⭐️⭐️⭐️⭐️
	- **(중요) 좋은 비지니스 로직** 
	- TS 기반 유틸리티 함수들 연구 레포지토리
	- ts-number-utils : 숫자 관련 유틸 함수 모음
	- ts-string-utils : 문자열 관련 유틸 함수 모음
	- ts-date-utils : 날짜 관련 유틸 함수 모음
- ts-oop (with Jest)
	- **(중요) 좋은 OOP 설계**
	- TS 기반 OOP적인 사고를 향상 시키기 위해 연습
	- 디자인패턴
	- 상속, 합성, 믹스인
	- 객체, 협력, 책임, 메세지
	- SOLID
	- DI, DIP
- nestjs-toolkit (with Jest)
	- pipe, guard, middleware, interceptor 등 연구
- nestjs-boilerplate
	- 여러가지 셋팅 설정
	- Nestia + typia 세팅
	- NestJS + SWC + Webpack 세팅
- react-boilerplate ✅
	- react 18기준 템플릿
- YDS (Yang Design System)
	- Shacdn ui + tailwind + Storybook


# Book

## CS

- 운영체제
	- 공룡책 ✅
	- [Operating Systems: Three Easy Pieces](https://product.kyobobook.co.kr/detail/S000001732370) 
- 네트워크
	- 탑다운 어프로치 ✅
	- [성공과 실패를 결정하는 1%의 네트워크 원리](https://product.kyobobook.co.kr/detail/S000000559964) 
- 데이터베이스
	- [데이터베이스 시스템 7판](https://product.kyobobook.co.kr/detail/S000001693775) - 돛단배 책 ✅
	- [데이터베이스 시스템 3판](https://product.kyobobook.co.kr/detail/S000214032509) 
	- RealMysql 1권, 2권
	- [데이터 중심 애플리케이션 설계](https://product.kyobobook.co.kr/detail/S000001766328) 
- 자료구조
- 알고리즘

## 시스템 디자인

- 시스템 디자인
	- 가상면접으로 배우는 시스템 디자인 1편,2편


Book
- 객체지향의 사실과 오해
- 오브젝트책
- 이펙티브 TS
- 아는만큼보이는데이터베이스설계와구축
- 코어자바스크립트
- 모던JS딥다이브
- 공룡책
- 네트워크탑다운
- 데이터베이스 시스템
- UnitTest (Reading)
- RealMysql (Reading)
- 데이터중심애플리케이션설계 (Plan)
- 가상 면접 사례로 배우는 대규모 시스템 설계 기초 (Plan)
## 기록없음
- NestJS로 배우는 백엔드 프로그래밍
- 혼자 공부하는 컴퓨터 구조+운영체제
- 혼자 공부하는 네트워크
- 면접을 위한 CS 전공지식 노트
- 코딩 자율학습 제로초의 자바스크립트 입문
- Node.js 교과서
- 함께 자라기
- 실용주의 프로그래머
- 소프트웨어 장인
- 개발자를 위한 레디스

