
# stable sort
- *Stable Sort* 는 정렬이 되어서도 같은 키값이라도 먼저 들어온 녀석이 먼저 앞에 있는다.같은 키를 가진 사람이 A B 가 있는데, 정렬 후에도 이 순서는 유지가 된다는 것이다.
- 안정된 정렬

```js title="js sort로 구현"
const data = [
  { name: 'A', score: 90 },
  { name: 'B', score: 90 },
  { name: 'C', score: 80 },
  { name: 'D', score: 70 },
];
const stableSortedData = [...data].sort((a, b) => a.score - b.score);
console.log(stableSortedData);
```
# Unstable sort
- 정렬 후에는 이 순서가 무너질 수 있다.
- 같은 키를 가진 사람이 A B 순서로 도착했지만 어떠한 경우에서 B A 순서가 될 수 있다.
- 먼저 온 A 입장에서는 억울한 경우이다.
- 불안정된 정렬

```js title="js sort로 score가 같았을때 순서를 보장 안함"
const data = [
  { name: 'A', score: 90 },
  { name: 'B', score: 90 },
  { name: 'C', score: 80 },
  { name: 'D', score: 70 },
];
function unstableSort(arr) {
  return arr.sort((a, b) => {
    // 점수가 같으면 무작위로 정렬 (unstable 특성 구현)
    if (a.score === b.score) {
      return Math.random() - 0.5;
    }
    return a.score - b.score;
  });
}

const unstableSortedData = unstableSort([...data]);
console.log(unstableSortedData);
```

| 분류      | 정렬 알고리즘        | 시간복잡도                                  | 설명                                                        |
| ------- | -------------- | -------------------------------------- | --------------------------------------------------------- |
| 안정한 정렬  | Insertion Sort | O(n²)                                  | 정렬되지 않은 원소를 선택해서 정렬된 자리를 찾아 삽입. Swap 과정이 없으므로 안정된 정렬.     |
|         | Merge Sort     | O(n log n)                             | 배열을 분할 후 정렬된 배열을 합침. Swap 과정이 없으므로 안정된 정렬.                |
|         | Bubble Sort    | O(n²)                                  | 두 개의 원소를 비교하여 Swap하며 정렬. Swap이 이웃 원소 사이에서만 일어나므로 안정된 정렬.  |
|         | Counting Sort  | O(n + k) (n: 입력 크기, k: 범위)             | 원소를 등장 횟수만큼 저장 후 순서대로 꺼내어 정렬. 순서 유지가 보장되므로 안정된 정렬.        |
| 불안정한 정렬 | Selection Sort | O(n²)                                  | 가장 작은 원소를 찾아 Swap하여 정렬. Swap으로 인해 순서가 변경될 수 있으므로 불안정한 정렬. |
|         | Heap Sort      | O(n log n) (모든 경우 동일)                  | Heap 구조에서 부모 노드와의 Swap으로 인해 순서가 역전될 수 있으므로 불안정한 정렬.       |
|         | Quick Sort     | O(n log n),<br>O(n²) (피벗이 최악으로 선택된 경우) | Pivot을 기준으로 Swap하며 정렬. Swap 과정에서 안정성이 깨질 수 있으므로 불안정한 정렬.  |

# In place Sort
- **추가적인 메모리를 사용하지 않는 것** 
- 대표적으로 Bubble Sort 경우 추가적인 메모리 필요 없이 인접한 원소를 끼리 비교하고 서로 Swap 하므로메모리 공간의 복잡도는 O(1) 이 된다.
# Not in place
- Merge Sort
- 합병 정렬하는 과정에서 N개의 Problem을 1 / 2 로 쪼개 각각의 SubProblem을 분할해가며,나중에 정렬된 두 개의 SubProblem 을 Merge 하는 과정에서 추가적인 메모리 공간이 필요하게 된다.메모리 공간의 복잡도는 O(N)이다.

| 분류            | 정렬 알고리즘  | 공간 복잡도 | 설명                                                                                     |
|-----------------|----------------|-------------|------------------------------------------------------------------------------------------|
| In-Place Sort   | Insertion Sort | O(1)        | 정렬되지 않은 원소를 하나 선택 후 값을 기억하고, 자리를 만들면서 삽입. 한 칸씩 이동하며 정렬. |
|                 | Selection Sort | O(1)        | 작은 원소를 찾아 정렬 위치와 Swap. Swap 과정에서 Temp 공간 필요.                           |
|                 | Bubble Sort    | O(1)        | 인접한 두 원소를 Swap. Swap 과정에서 Temp 공간 필요.                                       |
|                 | Heap Sort      | O(1)        | 부모와 자식 노드 비교 후 필요 시 Swap. Swap 과정에서 Temp 공간 필요.                       |
|                 | Quick Sort     | O(1)        | Pivot과 left, right 포인터 간의 Swap 과정에서 Temp 공간 필요.                              |
| Not In-Place Sort | Merge Sort    | O(N)        | Merge 과정에서 추가 메모리 공간 필요.                                                      |
|                 | Counting Sort  | O(N)        | 추가 메모리 공간을 사용하여 등장 횟수를 저장하고 순서대로 정렬.                              |
|                 | Radix Sort     | O(N)        | Bucket이라는 추가 메모리 공간 사용.                                                        |

- JS Tim Sort

