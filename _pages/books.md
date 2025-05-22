---
layout: books
title: Book Library
permalink: /books/
---

## 📚 읽은 책들

<div class="book-grid">
  <div class="book-card has-notes">
    <div class="book-cover">
      <img src="/assets/books/book1.jpg" alt="리팩터링 2판">
      <div class="notes-badge">📚 학습노트 보기</div>
    </div>
    <div class="book-info">
      <h3>리팩터링 2판</h3>
      <p class="author">마틴 파울러</p>
      <div class="tags">
        <a href="/tags/개발방법론" class="tag">개발방법론</a>
        <a href="/tags/클린코드" class="tag">클린코드</a>
      </div>
      <p class="review">객체지향 프로그래밍의 핵심 개념과 원칙을 배울 수 있는 책</p>
      <a href="/notes/books/리팩터링-2판-정리" class="notes-link">📝 학습 내용 보러가기</a>
    </div>
  </div>

  <div class="book-card">
    <div class="book-cover">
      <img src="/assets/books/book2.jpg" alt="클린 아키텍처">
    </div>
    <div class="book-info">
      <h3>클린 아키텍처</h3>
      <p class="author">로버트 C. 마틴</p>
      <div class="tags">
        <a href="/tags/아키텍처" class="tag">아키텍처</a>
        <a href="/tags/설계" class="tag">설계</a>
      </div>
      <p class="review">소프트웨어 아키텍처의 근본 원칙을 다룬 명저</p>
    </div>
  </div>

  <div class="book-card">
    <div class="book-cover">
      <img src="/assets/books/book2.jpg" alt="클린 아키텍처">
    </div>
    <div class="book-info">
      <h3>database system concepts 7th</h3>
      <p class="author">Abraham Silberschatz , Henry F. Korth , S. Sudarshan 저자</p>
      <div class="tags">
        <a href="/tags/Database" class="tag">Database</a>
      </div>
      <p class="review">데이터베이스</p>
    </div>
  </div>
</div>


## 책

- OOP와 DDD 그리고 VO, TO, DTO, 불변성
	- VO
	    - Fowler 2003의 486쪽.
	    - [http://martinfowler.com/bliki/ValueObject.html](http://martinfowler.com/bliki/ValueObject.html)
	- TO , DTO
	    - Alur 2001의 7.7절(번역판 472쪽).
	    - [http://www.oracle.com/technetwork/java/transferobject-139757.html](http://www.oracle.com/technetwork/java/transferobject-139757.html)
	    - Fowler 2003 401쪽.
	    - [http://martinfowler.com/eaaCatalog/dataTransferObject.html](http://martinfowler.com/eaaCatalog/dataTransferObject.html)
	-  [http://findbugs.sourceforge.net/bugDescriptions.html#EI_EXPOSE_REP](http://findbugs.sourceforge.net/bugDescriptions.html)  
	- [http://findbugs.sourceforge.net/bugDescriptions.html#EI_EXPOSE_REP2](http://findbugs.sourceforge.net/bugDescriptions.html)
	- [http://blog.benelog.net/viewer/2173103](http://blog.benelog.net/viewer/2173103) 참조
	- Joshua Bloch의 "How to Design a Good API & Why it Matters" 강연([http://www.infoq.com/presentations/effective-api-design](http://www.infoq.com/presentations/effective-api-design)) 에서도 강조되는 원칙이다.
	-  [http://spring.io/blog/2009/11/17/spring-3-type-conversion-and-validation/](http://spring.io/blog/2009/11/17/spring-3-type-conversion-and-validation/)  
	-  [https://java.net/projects/jsr-310/](https://java.net/projects/jsr-310/)
	- [https://jira.springsource.org/browse/SPR-9641](https://jira.springsource.org/browse/SPR-9641)
	- VO의 불변성이 왜 좋은 설계인지 대해서는 다음 자료에 자세히 설명되어 있다.
		- Evans 2004의 99 ~ 103쪽.
		- Fowler 2003의 486쪽.
		- Bloch 2008의 73 ~ 80쪽. Item 15 : Minimize mutability.
	- OOP와 DDD
		- 토끼책, 오브젝트
		- Core j2Ee Patterns(Alur 2001)
		- Patterns of Enterprise Application Architecture(Fowler 2003)
		- Effective Java(Bloch 2008)
		- DDD 블루북(Domain-Driven Design: Tackling Complexity in the Heart of Software, Eric Evans), 레드북
- 테스트
	- Unit Test 책
