
|주제|핵심 키워드|이유|
|---|---|---|
|**Rate Limiter** 구현|고정 윈도우, 슬라이딩 윈도우, 토큰 버킷|API 남용 방지, 실시간 처리와 연관|
|**Unique ID Generator**|Twitter Snowflake, timestamp + shard|분산 시스템에서 ID 충돌 없는 생성|
|**Log Aggregation**|Windowed count, deduplication|로그 기반 이벤트 집계 문제|
|**Leaderboard 구현**|Heap, BST, Redis Sorted Set|실시간 정렬, 랭킹 갱신 처리|
|**Sliding Window Median**|Heap, multiset|실시간 통계, anomaly detection|
|**Search Autocomplete**|Trie, Priority Queue|입력 예측, 문자열 알고리즘|
|**Real-time Notification Queue**|Pub/Sub, priority queue|메시지 우선순위 큐 설계|
|**Time-based Key-Value Store**|HashMap + Binary Search|Redis-like 기능 인터뷰|
|**Job Scheduler**|Topological Sort, Priority Queue|DAG 스케줄링, cron-like 로직|
|**Cache System**|LRU/LFU, TTL, Memory Eviction|Redis-like 기능 구현|

**예시** 

- “N개의 서버에 부하를 균등하게 분산시키는 방법을 구현하라” → **Consistent Hashing**
- “실시간으로 들어오는 로그의 최근 5분치 에러율을 구하라” → **Sliding Window, Reservoir Sampling**
- “1초당 1000개의 요청만 허용하는 시스템을 설계하라” → **Token Bucket**


## General Problem List

- https://leetcode.com/problem-list/xoqag3yj/
- [리트코드 LRU 문제](https://leetcode.com/problems/lru-cache/description/) 

|분류|대표 문제|
|---|---|
|Array|Two Sum, Best Time to Buy and Sell Stock|
|Linked List|Merge Two Sorted Lists, Linked List Cycle|
|Stack/Queue|Valid Parentheses, Daily Temperatures|
|Heap|Merge K Sorted Lists|
|Tree|Maximum Depth of Binary Tree, Lowest Common Ancestor|
|Graph|Number of Islands, Clone Graph|
|DP|House Robber, Longest Increasing Subsequence|
|Sliding Window|Longest Substring Without Repeating Characters|
|Design|LRU Cache|

### System Design

|패턴|대표 문제|링크|
|---|---|---|
|캐시|LRU Cache|[LRU Cache](https://leetcode.com/problems/lru-cache)|
|데이터 스트림|Median from Data Stream|[Median](https://leetcode.com/problems/find-median-from-data-stream)|
|시간 기반 저장소|Time-based Key-Value Store|[TimeMap](https://leetcode.com/problems/time-based-key-value-store)|
|랭킹|Design Leaderboard|[Leaderboard](https://leetcode.com/problems/design-a-leaderboard/)|
|예약/스케줄링|Meeting Rooms II|[Meeting](https://leetcode.com/problems/meeting-rooms-ii)|
|로그 처리|Logger Rate Limiter|[Logger](https://leetcode.com/problems/logger-rate-limiter/)|
|메신저 구조|Design Twitter|[Twitter](https://leetcode.com/problems/design-twitter/)|
|해시 설계|Insert Delete GetRandom O(1)|[Random](https://leetcode.com/problems/insert-delete-getrandom-o1/)|

### Design Interview Essentials

|유형|문제 스타일|대표 키워드|
|---|---|---|
|Rate Limiter|Token Bucket, Leaky Bucket|API Gateways, DOS 방어|
|Cache|LRU, LFU 구현|Redis-like|
|ID 생성기|Snowflake|Timestamp, Shard ID|
|Pub/Sub 시스템|Kafka 기반 구현|비동기 메시징|
|URL Shortener|Base62 인코딩|데이터 압축 + ID 매핑|
|Web Crawler|BFS + Multi-threading|크롤링, 중복 방지|
|File Storage|Dropbox Clone|Chunking, Metadata 관리|

