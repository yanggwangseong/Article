---
title: Swagger 문서
permalink: /wating/5
---

```json
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';
import * as fs from 'fs';

async function generateSwaggerJson() {
    const app = await NestFactory.create(AppModule);

    /*
    * 이 구간을 develop에서만 동작하게
    */
    const config = new DocumentBuilder()
        .setTitle('API Documentation')
        .setDescription('The API description')
        .setVersion('1.0')
        .build();
    const document = SwaggerModule.createDocument(app, config);

    // Swagger JSON 파일 저장
    fs.writeFileSync('./swagger.json', JSON.stringify(document, null, 2));
    /*
    * 이 구간을 develop에서만 동작하게
    */
    
    await app.close();
}

generateSwaggerJson();

```

- swagger 문서나 swagger 데코레이터를 배포서버에 그대로 서빙하게 되면 빌드 속도에 조금이라도 영향을 줄 수 있다. 그렇기 때문에 swagger 문서는 개발 환경에서 정적으로 스크리핑 하여서 배포하는게 좋아보인다.
- 프로덕션 환경에서 swagger를 json파일로 정적으로 호스팅 해야한다.
- `Babel` 에서`babel-plugin-transform-remove-decorators` 를 사용하여 swagger 관련된 모든 데코레이터를 빌드시에 다 삭제 해버린다.

```bash
$ npm install babel-plugin-transform-remove-decorators --save-dev
```

```json
{
  "plugins": [
    ["transform-remove-decorators", { "decorators": ["ApiProperty", "ApiResponse"] }]
  ]
}
```


- [해당 이슈](https://github.com/nestjs/swagger/issues/92)  Nestjs에서 `ApiExcludeController` 를 통해서 숨길 수 있다는데 모르겠네

- Webpack + SWC + Babel 셋을 사용 해야하는걸까...
	- Babel remove decorator 없이 어떻게 특정 데코레이터들을 지울 수 있을까?
	- SWC remove decorator 플러그인이 없다. 만들면 꽤 인기 많을것 같은데...
	- SWC와 Babel을 같이 사용하는것은 좋아 보이지 않는다.

