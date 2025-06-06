---

excalidraw-plugin: parsed
tags: [excalidraw]

---
==⚠  Switch to EXCALIDRAW VIEW in the MORE OPTIONS menu of this document. ⚠== You can decompress Drawing data with the command palette: 'Decompress current Excalidraw file'. For more info check in plugin settings under 'Saving'


# Excalidraw Data
## Text Elements
Query Processing ^7wu1C85S

- Operation ^TOfhN659

- Selection Operation (선택 연산) ^9WJheWnq

- Sorting (정렬) ^TDGGQcyt

- Join Operation (조인 연산) ^47ZkYlQ8

- Other Operations (기타 연산) ^MUWjCI1z

- Evaluation of Expressions (표현식 평가) ^5pmevOZR

- Query Processing 이란? ^HDOVs1XC

- Query Processing 과정 ^mDipLY60

SELECT salary FROM instructor WHERE salary < 75000; ^86DPVc91

1. σ_salary<75000 (π_salary (instructor))
	- 먼저 `instructor` 테이블에서 `salary` 열만 선택 (`π_salary`)
	- 그 다음에 그 중에서 `salary < 75000` 조건을 만족하는 것만 선택 (`σ_salary<75000`)
	- 즉, **컬럼을 먼저 선택한 후 조건 필터링**
2. π_salary (σ_salary<75000 (instructor))
	- 먼저 `salary < 75000` 조건을 만족하는 행만 필터링 (`σ_salary<75000`)
	- 그 후에 `salary` 열만 선택 (`π_salary`)
	- 즉, **조건을 먼저 필터링한 후 컬럼 선택** ^ka0MOrUe

%%
## Drawing
```compressed-json
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=
```
%%