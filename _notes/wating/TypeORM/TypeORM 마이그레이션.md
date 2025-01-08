---
title: mokakbab-issue
permalink: /wating/마이그레이션
---

# TypeORM 마이그레이션

- [공식문서1](https://typeorm.io/migrations#running-and-reverting-migrations) 
- [공식문서2](https://typeorm.io/migrations#generating-migrations)
- [공식문서3](https://typeorm.io/migrations#running-and-reverting-migrations)
- [공식문서4](https://typeorm.io/migrations#generating-migrations) 
- [공식문서5](https://typeorm.io/changelog#breaking-changes-1) 


- [TypeORM 마이그레이션 실행시 js파일로 항상 변환하여 실행한다](https://github.com/f-lab-edu/Mokakbab/pull/72#discussion_r1905338113) 
- 실제 프로덕션 환경에서는 DML이 제한적으로 동작하는게 맞고 애플리케이션에서 이런 마이그레이션이 동작 하지 않게 하는경우가 많다.
- 애플리케이션 레벨에서 마이그레이션을 사용하는게 아니라 클라우드에서 제공하는것을 사용하는것 같다.
	- AWS DMS, Google Cloud SQL
