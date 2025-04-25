---
title: avl-tree
permalink: /cs/data-structure/avl-tree
tags:
  - data-structure
layout: page
---

## Section

- BST(이진 탐색 트리)
	- 이진트리에서 자신에서 왼쪽 서브 트리가 자기보다 작은 값들만 가지고
	- 오른쪽 서브트리에는 자기보다 큰값을 가지는 이진트리 입니다.
- AVL Tree
	- 이진 탐색 트리(BST)의 한 종류로 스스로 Balancing(균형)을 잡는 트리 입니다.
	- 어떻게?
		- balance factor를 통해서 균형을 유지 합니다.
	- balance factor를 어떻게 구할까?
		- 특정 노드 x에 대해서
			- 왼쪽 서브트리의 높이 - 오른쪽 서브트리의 높이
		- EX) x의 왼쪽 서브트리의 높이 3, 오른쪽 서브트리의 높이 1라면
			- balance factor = 3 - 1 = 2

```ts
// balance factor
         50
        /  \
      30    70
        \   /  \
        40 60  90
               /  \
             80    99
```

- 만약 x가 50이라면?
	- x의 왼쪽 서브트리의 높이 : 1 (30 -> 40, 60)
	- x의 오른쪽 서브트리의 높이 : 2
	- balance factor : 1-2 = -1

## AVL Tree에서 Balancing

- Tree에서 삽입 혹은 삭제 후 balance factor가 `-1, 0, 1` 가 아닌 노드가 생긴다면 이때 Balancing 작업을 수행한다.
- **삽입과 삭제시에 발생한 위치에서 루트노드까지 balance factor가 `-1, 0, 1` 가 아닌 노드가 생긴다면 Rotation 시킨다.**

### CASE 오른쪽-오른쪽 편향

#### 최초 삽입시

```ts
// balance factor
         50
           \
            70
```

- 기본적으로 BST의 삽입과 동일하게 동작하고 50 노드의 오른쪽에 삽입된다.
- 이때 50의 balance factor를 확인 한다.
- BF(50) : 왼쪽 서브트리 높이 (없으니까 높이 -1) - 오른쪽 서브트리 높이 (0) = -1

#### 두번째 삽입시

```ts
// balance factor
         50
          \
           70
             \
              90
```

- BF(70) = -1 - 0 = -1
- BF(50) = -1 - 1 = -2
- 즉, 90을 삽입 했을때의 경우 50의 BF가 -2가 되어서 Balancing 하지 못한 상황이 발생 했다.
	- 이런 경우 **재조정 작업이 필요하다** 
 
```ts
         70
        /  \
      50    90

```

- 해결방법) 왼쪽으로 Rotation(회전) 시킨다.
- BF(70) = 0 - 0 = 0

## AVL Tree 시간 복잡도

- 삽입/삭제/탐색의 시간복잡도는 **O(logN)** 이다.
- BST보다 훨씬 개선된 시간 복잡도를 가진다.

## AVL Tree 의 단점

- **삽입/삭제시** 해당 위치에서부터 루트노드까지 balance factor를 확인하고 이를 유지하기 위한 재조정 작업에 의한 오버헤드가 발생한다.

## Reference

- [위키피디아 AVL 트리](https://en.wikipedia.org/wiki/AVL_tree) 
- [쉬운코드 AVL 트리](https://www.youtube.com/watch?v=syGPNOhsnI4&t=13s) 
