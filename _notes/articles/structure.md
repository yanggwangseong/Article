---
title: structure
permalink: /project/structure
tags:
---

- [코드리뷰 각각의 도메인별로 묶기 언급](https://github.com/f-lab-edu/Mokakbab/pull/84#discussion_r1929514190) 기존의 프로젝트 폴더 구조를 변경해야 될것 같습니다.
- 왜 각각의 도메인별로 묶는것이 좋을까?
- 현재 프로젝트구조는 레이어드아키텍쳐
- 레이어드 아키텍쳐 정리 *링크 추가.* 
- 운영체제 가상 메모리 파트 *링크 추가* 
- 운영체제 메모리 파트 다이나믹 로딩 *링크 추가* 
- 레이어드 관점에서 왜 묶는것이 좋은지 설명.
- 캐시 지역성 Locality 관점으로 왜 좋은지 설명.
- 동적 로딩 사용시에서의 이점.
- 내 생각 코멘트.

```
// 기존 프로젝트 구조

- controllers/
- dtos/
- entities/
- modules/
- repositories/
- services
```

# Reference

- [toss 함께 수정되는 파일 함께 두기](https://frontend-fundamentals.com/code/examples/code-directory.html) 
- [toss 함께 수정되는 파일 함께두기 지역성 토론](https://github.com/toss/frontend-fundamentals/discussions/44#discussion-7822532) 
- [마틴 파울러 Presentation Domain Data Layering](https://martinfowler.com/bliki/PresentationDomainDataLayering.html) 
- [계층형 아키텍쳐](https://jojoldu.tistory.com/603) 



