---
title: NestJS Slack WebHook
permalink: /nestjs/NestJS Slack WebHook
---

## NestJS Slack WebHook

- 앱추가 방식
- 앱생성 방식

앱 생성 방식을 선택하는것이 좋다. 왜냐하면 웹훅을 생성한 사용자가 Disable할 경우 웹훅 URL도 함께 비활성화 된다.

https://api.slack.com/apps

![[Pasted image 20250517203407.png]]

- From scratch > 앱이름(소문자와 '-'로 구성) 과 슬랙 워크스페이스 선택 > Create App

![[Pasted image 20250517203459.png]]

3) Collaborators > 동료 또는 또는 절대삭제 안되는 공용계정 추가 <- 이래야 퇴사자 발생 시 방어됩니다.

![[Pasted image 20250517203544.png]]

4) On 선택 후 아래로 내려서 Add New Webhook

![[Pasted image 20250517203716.png]]

**웹 생성 방식과 공통으로 사용하는 사용자를 Collaborator에 등록하자** 

![[Pasted image 20250517204452.png]]

성공!

