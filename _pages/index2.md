

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
	- 나만의 타입 컬렉션 모음
- type-challenges ✅
	- TS 타입 챌린지를 풀기
- DataStructure ✅ ⭐️
	- TS 기반으로 자료구조와 알고리즘을 연구
	- python 기본 문법 연습
- AlgoNote ✅ ⭐️
	- 알고리즘 문제를 풀면서 issue기반의 오답노트
- ts-oop (with Jest) ⭐️
	- TS 기반 OOP적인 사고를 향상 시키기 위해 연습
	- 디자인패턴
	- 상속, 합성, 믹스인
	- 객체, 협력, 책임, 메세지
	- SOLID
	- DI, DIP
- ts-toolkit (with Jest, codekata) ⭐️
	- TS 기반 유틸리티 함수들 연구 레포지토리
	- ts-number-utils : 숫자 관련 유틸 함수 모음 (OOP)
	- ts-string-utils : 문자열 관련 유틸 함수 모음 (OOP)
	- ts-date-utils : 날짜 관련 유틸 함수 모음 (OOP)
- nestjs-toolkit (with Jest)
	- pipe, guard, middleware, interceptor 등 연구
- nestjs-boilerplate
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
