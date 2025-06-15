
## 중요도1

- GitHub 프로젝트 만들기 + fork
- 원격 브랜치에 push 후 PR
- Merge 방식 3가지 (Merge, Squash, Rebase)
- `git rebase` vs `git merge` 
- `git reset` (soft, mixed, hard)
- PR 코드 리뷰 흐름 익히기 - 코멘트 남기기, 수정 후 다시 푸시, resolve 하기
- Revert vs Reset vs Checkout

## 중요도2

- git stash - 작업 중간에 브랜치 변경 시 유용
- git cherry-pick - 특정 커밋만 다른 브랜치에 적용해야 할 때 사용

## 실전 예시

- **협업 중 작업 도중 급한 버그 패치** → `git stash`, 다른 브랜치 → 작업
- **코드 리뷰 요청 후 피드백 반영** → `git commit --amend` 또는 force-push
- **다른 팀원의 커밋 중 하나만 내 브랜치에 적용** → `git cherry-pick`
- **의도치 않은 커밋 올림** → `git reset` or `git revert`
