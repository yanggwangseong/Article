
## 중요도1

- GitHub 프로젝트 만들기 + fork
- 원격 브랜치에 push 후 PR
- Merge 방식 3가지 (Merge, Squash, Rebase)
- `git rebase` vs `git merge` 
- `git reset` (soft, mixed, hard)
- PR 코드 리뷰 흐름 익히기 - 코멘트 남기기, 수정 후 다시 푸시, resolve 하기
- Revert vs Reset vs Checkout
	- **협업 중 실수를 되돌리고 싶으면 무조건 `revert`!** 
	- **혼자 작업 중 실수했을 땐 `reset`이나 `checkout`도 OK!**

## 중요도2

- git stash - 작업 중간에 브랜치 변경 시 유용
- git cherry-pick - 특정 커밋만 다른 브랜치에 적용해야 할 때 사용

## 실전 예시

- **협업 중 작업 도중 급한 버그 패치** → `git stash`, 다른 브랜치 → 작업
- **코드 리뷰 요청 후 피드백 반영** → `git commit --amend` 또는 force-push
- **다른 팀원의 커밋 중 하나만 내 브랜치에 적용** → `git cherry-pick`
- **의도치 않은 커밋 올림** → `git reset` or `git revert`

Merge 선택 기능

- `Create a merge commit`: 기본 옵션
- `Squash and merge`: 커밋을 하나로 합침
- `Rebase and merge`: 커밋을 선형으로 병합

|머지 방식|히스토리 구조|커밋 개수|특징|
|---|---|---|---|
|**Create a merge commit**|병합 커밋이 생기고 브랜치 히스토리가 그대로 유지됨|N+1개|_히스토리 보존, 병합 흔적 남김_|
|**Squash and merge**|모든 커밋을 하나로 압축한 후 머지|1개|_히스토리 단순화, 깔끔한 main 유지_|
|**Rebase and merge**|PR 커밋들을 base 브랜치 위에 재배치 후 머지|N개 (병합 커밋 없음)|_히스토리를 선형(linear)하게 만듦_|

### ⏱️ 1시간차: Git 핵심 협업 루틴 복습

|항목|실습 내용|
|---|---|
|✅ PR 리뷰 흐름|팀원인 척, 코멘트 남기고 수정 후 `push` → resolve|
|✅ merge 전략 3종|squash / rebase / 일반 merge 비교 실습|
|✅ rebase vs merge|`git log`, `git diff`로 결과 비교 (선형 이력 vs 머지 이력)|
|✅ revert vs reset vs checkout|실수 커밋 시 복구 방법 테스트 (상황별 써보기)|

### ⏱️ 2시간차: 협업 중 자주 쓰는 유틸 커맨드 복습

|항목|실습 내용|
|---|---|
|✅ `git stash`|코드 작성 도중 stash → 다른 브랜치 → 복원|
|✅ `git cherry-pick`|메인 브랜치 커밋을 기능 브랜치에 적용|
|✅ `git commit --amend`|기존 커밋 메시지나 코드 수정 후 덮어쓰기|
|✅ `git push --force`|강제 푸시 실습 (주의점 메모)|
