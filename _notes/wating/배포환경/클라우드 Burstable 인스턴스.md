---
title: mokakbab-issue
permalink: /wating/Burstable 인스턴스
---

- [참고1](https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/ec2-on-demand-instances.html) 
- [참고2](https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/burstable-performance-instances.html) 
- [참고3](https://www.reddit.com/r/aws/comments/18xq1a8/in_ecs_is_there_a_way_to_limit_a_container_by_cpu/) 
- [참고4](https://isn-t.tistory.com/38) 
- [참고5](https://docs.docker.com/engine/containers/resource_constraints/) 
- [참고6](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html) 
- [참고7](https://aws.amazon.com/ko/blogs/containers/how-amazon-ecs-manages-cpu-and-memory-resources/) 
- [참고8](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html) 
- [참고9](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html) 


# 버스터블 인스턴스 리소스 리미트 불가능

- 리눅스 `cgoup` 
- 도커 하드 limit를 사용해도 제어 불가능
- AWS 굳이 써서 부하 테스트를 하고 싶으면 2가지 방법 존재
	- npn-burstable 인스턴스 생성 - 유료
	- EC2 대신 Fargate 사용 - 유료

