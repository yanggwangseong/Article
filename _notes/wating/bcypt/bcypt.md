---
title: bcypt
permalink: /wating/bcypt
---

# bcypt의 salt

- `bcypt` 의 기본값 10을 넣었을때 성능과 5를 넣었을때 성능이 왜이렇게 다를까?
- bcypt는 내부적으로 `Blowfish 암호화 알고리즘` 을 사용한다.
- `salt rounds = 10`이면 해싱 과정에서 **2¹⁰ = 1024번의 연산**이 이루어지고, `salt rounds = 5`이면 **2⁵ = 32번의 연산**만 이루어집니다.


- https://github.com/kelektiv/node.bcrypt.js?tab=readme-ov-file
- https://en.wikipedia.org/wiki/Bcrypt
- https://mail-index.netbsd.org/tech-crypto/2002/05/24/msg000204.html

