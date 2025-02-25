
- Trie 자료구조란?
	- 문자열의 한 문자를 저장
	- Root에서부터 자식 노드를 따라가며 문자열을 구성
	- 문자열의 공통 접두사(Prefix)를 공유하여 저장 공간을 절약.
- Silver Bullet(실버 불렛)
	- 모든 문제를 완벽하게 해결하는 마법 같은 해결책은 없다.

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

- SRT(Secure Reliable Transport) 프로토콜
	- 보안성과 신뢰성을 강화한 저지연 비디오 전송 프로토콜로, 인터넷 환경에서도 안정적인 영상 스트리밍을 가능하게 함.
- RTMP(Real-Time Messaging Protocol) 프로토콜
	- Adobe가 개발한 저지연 스트리밍 프로토콜로, 주로 라이브 스트리밍과 비디오 전송에 사용됨.
- FFmpeg
	- 오디오, 비디오 인코딩, 디코딩, 변환, 스트리밍 등을 지원하는 멀티미디어 프레임워크

- 시간복잡도
	- O(1) < O(log N) < O(N) < O(N log N) < O(N²) < O(2ⁿ) < O(N!)
	- **O(1) (상수 시간)**
	    - 입력 크기(N)에 상관없이 항상 일정한 시간이 걸리는 연산
	    - 예: 배열에서 인덱스를 사용해 특정 원소 접근 (`arr[i]`)
	- **O(N) (선형 시간)**
	    - 입력 크기에 비례해 시간이 증가하는 연산
	    - 예: 배열 전체 순회 (`for` 루프)
	- **O(N log N) (선형 로그 시간)**
	    - 분할 정복 기반 알고리즘에서 자주 나오는 복잡도
	    - 예: **퀵 정렬(평균), 병합 정렬, 힙 정렬**
	- **O(N²) (제곱 시간)**
	    - 중첩된 루프가 있을 때 발생하는 복잡도
	    - 예: **버블 정렬, 선택 정렬, 삽입 정렬(최악)**
	- **O(log N) (로그 시간)**
	    - 입력 크기가 증가할 때 비교적 느리게 증가하는 복잡도
	    - 예: **이진 탐색(Binary Search)**
	- **O(2ⁿ) (지수 시간)**
	    - 입력 크기가 증가할수록 급격하게 증가하는 복잡도
	    - 예: **재귀적인 피보나치 구현, 백트래킹 알고리즘(최악의 경우)**
	- **O(N!) (팩토리얼 시간)**
	    - 가장 비효율적인 시간 복잡도로, 작은 N에서도 실행 시간이 급격히 증가
	    - 예: **순열 생성(Permutation), 브루트포스 TSP(외판원 문제)**

- Obtaining, obtain, obtained
	- In order to obtain a block of IP addresses for use within an organization’s subnet
	- Obtaining a Block of Addresses
	- Once an organization has obtained a block of addresses, it can assign individual IP addresses to the host and router interfaces in its organization

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
