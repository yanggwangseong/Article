
- OLTP (Online Transaction Processing)이란?
- OLAP (Online Analytical Processing)이란?

- RBAC(Role-Based Access Control)
- ABAC(Attribute-Based Access Control)

- 일급객체란?
	1. 무명의 리터럴로 생성할 수 있다. 즉, 런타임에 생성이 가능하다.
	2. 변수나 자료구조(객체, 배열 등)에 저장할 수 있다.
	3. 함수의 매개 변수에 전달할 수 있다.
	4. 함수의 반환값으로 사용 할 수 있다.
- call by value 과 call by reference란?
	- JS관점에서 이건 살짝 모순인것 같다.
	- call by value라는것은 string 같은경우 예를 들어보면 힙메모리에 저장되고
	- 해당 참조값을 변수에 할당해서 string-constant-pool을 통해서 값의 immutable을 보장합니다.
	- 여기서 또 call by reference도 js 관점에서 다시 생각 해야되는게
	- V8 엔진에서 Sharp 또는 Hidden Class라고 하는 공간에 값만 저장되고 이를 통한 재사용성과 메모리 효율을 극대화하는게 목적이죠.




- 면접 말하기 연습을 어떻게 하면 좋을라나
- 이제 포폴은 준비 될텐데 면접을 잘보는게 진짜 중요한데.

#### DataStructure
- *(TODO중요)* 해시맵 해시함수 해시충돌 

#### OS
- *6~8 살짝 아쉬움 다시 공부*  
- (TODO) 동시성 제어 복습
- (TODO) 데드락 복습
- 메모리 가상메모리 굳
- 프로세스 스레드 굳
- (TODO) 프로세스간 통신 IPC복습.

#### Network
- 현재 진행중인것은 공부 할때 한번에 정리 필요.
- (TODO) 1장 패킷 교환 회선교환, 패킷 교환 지연과 손실 (중요)
- 2장 한줄정리 복습
- 3장 한줄정리 필요

#### Database

#### Node.js
