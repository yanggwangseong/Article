---
title: TypeORM Seeding 성능 문제
permalink: /project/mokakbab/trouble-shooting/2
tags:
  - Troubleshooting
  - mokakbab
  - nestjs
  - typeorm
layout: page
---

![](/assets/Mokakbab06.png)

## TypeORM Seeding 성능 문제

- 🐙 **[모각밥 프로젝트(GitHub)](https://github.com/f-lab-edu/Mokakbab)** 
- 🔗 **[PR #67 이슈 링크](https://github.com/f-lab-edu/Mokakbab/pull/67)** 

---

### 📚 Contents

1. 개요
2. 문제
3. 문제 해결 및 결과

---

### 개요

**테스트 환경을 위해서 Bulk Insert를 진행 하기 위해서 typeorm를 사용하고 있어서 typeorm-extension 이용하였습니다** 

#### 왜 typeorm-extension을 사용?

- typeorm의 호환성과 seeds와 fatories로 Bulk Insert에 대한 쿼리를 관리가 용이 했습니다.
- `dummy` 데이터를 삽입하기 위해서 `fakerjs` 가 필요 했는데 해당 라이브러리가 내장되어서 제공 하고 있습니다.


---

### 문제

1. `typeorm-extension` 에서 `saveMany` 메서드 문제

![](/assets/Mokakbab07.png)

- `typeorm-extension`의 `saveMany`가 내부적으로는 루프를 돌면서 저장을 하였습니다.
- `typeorm`의 `save` 메서드는 내부적으로 QueryBuilder를 사용하여 select 쿼리를 실행한 후, 데이터가 존재하면 update, 존재하지 않으면 insert를 실행 하였습니다.

**saveMany메서드 호출시 너무 많은 save 메서드 호출 문제와 save 메서드 실행시 select 쿼리를 실행한 후, 데이터가 존재하면 update, 존재하지 않으면 insert를 하기 때문에 성능 문제가 발생 했습니다** 

---

### 문제 해결 및 결과

1. `typeorm` 의 쿼리빌더를 사용하여 `Bulk Insert` 하여서 해당 문제를 해결 하였습니다.

```ts
export default class ParticipationSeeder implements Seeder {
    public async run(
        dataSource: DataSource,
        factoryManager: SeederFactoryManager,
    ): Promise<void> {
        const participationFactory = factoryManager.get(ParticipationEntity);
        const queryRunner = dataSource.createQueryRunner();

        const batchSize = 1000;
        const totalParticipations = 200000;
        const iterations = Math.ceil(totalParticipations / batchSize);

        let totalCreated = 0;

        try {
            await queryRunner.connect();
            await queryRunner.startTransaction();

            for (let i = 0; i < iterations; i++) {
                const participations = await Promise.all(
                    Array.from({ length: batchSize }, () =>
                        participationFactory.make(),
                    ),
                );

                const result = await queryRunner.manager
                    .createQueryBuilder()
                    .insert()
                    .into(ParticipationEntity)
                    .values(participations)
                    .orIgnore()
                    .execute();

                totalCreated += result.identifiers.length;
                console.log(
                    `${i + 1}번째 배치 참여 생성 완료: ${result.identifiers.length}`,
                );
            }

            await queryRunner.commitTransaction();
            console.log(`총 참여 생성 완료: ${totalCreated}`);
        } catch (error) {
            await queryRunner.rollbackTransaction();
            throw error;
        } finally {
            await queryRunner.release();
        }
    }
}
```

- **빠른 insert를 위해 작업을 여러 개의 배치로 나누어 Bulk Insert가 가능하도록 개선하였습니다.** 

---

## Reference

- [typeorm-extension saveMany 코드 링크](https://github.com/tada5hi/typeorm-extension/blob/cf8e640d8a65a28e0d18ea16161f8663af4f2d82/src/seeder/factory/module.ts#L76)
- [typeorm save 구현체](https://github.com/typeorm/typeorm/blob/19a6954d8b80ef23f0c3fb759c470c6a946d41a2/src/entity-manager/EntityManager.ts#L404)
- [typeorm save에서 호출하는 excutor](https://github.com/typeorm/typeorm/blob/master/src/persistence/EntityPersistExecutor.ts)
- [typeorm excutor에서 호출하는 subject-excutor](https://github.com/typeorm/typeorm/blob/19a6954d8b80ef23f0c3fb759c470c6a946d41a2/src/persistence/SubjectExecutor.ts)
