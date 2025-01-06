---
title: mokakbab-issue
permalink: /wating/issue
---
- `innoDB` 스토리지 엔진에서는 왜 외래키 제약이 설정되면자동으로 칼럼에 인덱스를 생성 하는걸까??


> MySQL requires indexes on foreign keys and referenced keys so that foreign key checks can be fast and not require a table scan. In the referencing table, there must be an index where the foreign key columns are listed as the _first_ columns in the same order. Such an index is created on the referencing table automatically if it does not exist. This index might be silently dropped later if you create another index that can be used to enforce the foreign key constraint. _`index_name`_, if given, is used as described previously.


- 그렇다 자동 인덱스를 형성하게 `InnoDB` 스토리지 엔진에서 구성 되어 있다.
- 그런데 말이지 내가 분명히 복합 인덱스로 PK로 인덱스 설정을 해두었는데 그 둘중에 왜 한개만 또 다시 인덱스가 자동으로 생성 되는거지?

# TypeORM 이슈인가?

```ts
import { Entity, JoinColumn, ManyToOne, PrimaryColumn } from "typeorm";

import { ArticleEntity } from "./article.entity";
import { MemberEntity } from "./member.entity";

@Entity("article_likes")
export class ArticleLikeEntity {
    @PrimaryColumn({
        type: "int",
    })
    memberId!: number;

    @PrimaryColumn({ type: "int" })
    articleId!: number;

    @ManyToOne(() => MemberEntity, (member) => member.articleLikes)
    @JoinColumn({ name: "memberId", referencedColumnName: "id" })
    member!: MemberEntity;

    @ManyToOne(() => ArticleEntity, (article) => article.articleLikes)
    @JoinColumn({ name: "articleId", referencedColumnName: "id" })
    article!: ArticleEntity;
}

```

- 분명히 복합 인덱스를 설정 하였는데 사용자가 명시적으로 인덱스를 설정 하였다면 `fk` 에는 자동 인덱스가 생성 되지 않는게 `InnoDB` 특성인것 같은데 근데 왜 `memberId` 에 개별 인덱스가 생성 되는거지?

# Reference

- https://dev.mysql.com/doc/refman/8.4/en/create-table-foreign-keys.html
- https://stackoverflow.com/questions/304317/does-mysql-index-foreign-key-columns-automatically

