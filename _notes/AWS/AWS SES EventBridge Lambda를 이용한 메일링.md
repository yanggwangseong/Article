---
title: AWS SES EventBridge Lambda를 이용한 메일링
permalink: /AWS/SES-EventBridge-Lambda를 이용한 메일링
tags:
  - aws
  - post
layout: page
image: 
category: AWS
description: EventBridge Lambda SES를 이용한 메일 전송
---

## 워크 플로우

- EventBridge Lambda SES

## SES 생성

![](/assets/aws-lambda-01.png)

- SES 이메일을 등록하고 생성한 후에 반드시 해당 레코드들을 추가 해주어야 한다.

![](/assets/aws-lambda-02.png)

- ~~Route53에서 도메인을 관리하고 있기 때문에 시키는대로 레코드를 추가하면 된다.~~
- **Route53을 사용한다면 아래에서 나와있듯이 자격증명 -> 도메인 선택 -> Route53에 레코드 등록을 누르면 된다** 

![](/assets/aws-lambda-03.png)

- 도메인 인증이 완료되면 전송 도메인 확인 작업이 완료된 작업으로 된다. 레코드를 등록하고 어느정도 시간이 소요 되는것 같다.

![](/assets/aws-lambda-04.png)

- 자격증명에 갔는데도 오랫동안 확인 보류중이라면 문제가 있는거다.

![](/assets/aws-lambda-05.png)

- 자격증명 -> 도메인 클릭 -> DKIM에서 Route53에 레코드 등록을 해두었는데 아직 대기중으로 뜨는걸 보면 이부분들이 완료되어야 검증 상태가 되는것 같다.

## AWS Lambda

![](/assets/aws-lambda-06.png)

- 새로 생성으로 Lambda 함수를 생성하고 자동으로 새 역할이 생성되게 설정한다.

### 역할 추가

![](/assets/aws-lambda-07.png)

- **Lambda의 IAM Role에 AmazonSESFullAccess** 
- Lambda에서 SES를 통한 전송을 할 수 있게 역할을 추가합니다.

### Lambda 함수 작성

1. Amazon RDS에 연결하여 구독자들의 email 주소 리스트들을 가져오기
2. SES를 통해서 이메일 전송

![](/assets/aws-lambda-08.png)

```js
import { Signer } from "@aws-sdk/rds-signer";
import mysql from 'mysql2/promise';

async function createAuthToken() {
  // Define connection authentication parameters
  const dbinfo = {

    hostname: process.env.ProxyHostName,
    port: process.env.Port,
    username: process.env.DBUserName,
    region: process.env.AWS_REGION,

  }

  // Create RDS Signer object
  const signer = new Signer(dbinfo);

  // Request authorization token from RDS, specifying the username
  const token = await signer.getAuthToken();
  return token;
}

async function dbOps() {

  // Obtain auth token
  const token = await createAuthToken();
  // Define connection configuration
  let connectionConfig = {
    host: process.env.ProxyHostName,
    user: process.env.DBUserName,
    password: token,
    database: process.env.DBName,
    ssl: 'Amazon RDS'
  }
  // Create the connection to the DB
  const conn = await mysql.createConnection(connectionConfig);
  // Obtain the result of the query
  const [res,] = await conn.execute('select ?+? as sum', [3, 2]);
  return res;

}

export const handler = async (event) => {
  // db 연동 테스트
  const result = await dbOps();

  const response = {
    statusCode: 200,
    body: JSON.stringify("The selected sum is: " + result[0].sum)
  };
  return response;
};
```

- Lambda -> 함수 -> 구성 -> 환경변수에서 DB 접속 정보를 넣어주고 공식문서에서 제공하는 테스트 코드를 넣는다.
- Cannot find package 'mysql2' imported from /var/task/index.mjs 이를 위한 node_modules를 추가 해줘야 하는것 같다.
- `@aws-sdk/rds-signer` 와 `mysql2` 를 설치한 후 해당 코드를 zip으로 Lambda에 올려준다.

```bash
$ zip -r lambda.zip index.mjs node_modules package.json package-lock.json
```

![](/assets/aws-lambda-09.png)

- 배포가 완료되었다! 이제 테스트를 실행하여서 DB와 연동이 되는지 체크

```json
{
  "errorType": "Sandbox.Timedout",
  "errorMessage": "RequestId: 8ae02711-a9ac-422f-9bb1-0798d2a48327 Error: Task timed out after 3.00 seconds"
}
```

![](/assets/aws-lambda-10.png)

- Lambda -> 구성에서 RDS 연결을 해주어야 한다.
- 연결이 완료되면 VPC며 람다 함수를 업데이트한다.
- 완료되면 RDS 데이터베이스 연결에 표시된다.

![](/assets/aws-lambda-11.png)

- Lambda 역할 설정에 AmazonRDSFullAccess로 접근 역할 추가
- [공식문서 참고](https://docs.aws.amazon.com/ko_kr/lambda/latest/dg/services-rds.html) 

### RDB ProxyHost는 요금이 발생한다

- 일반 접속으로 처리하자.

```js
import mysql from "mysql2/promise";

async function dbOps() {
  const connectionConfig = {
    host: process.env.DB_HOST,
    port: parseInt(process.env.DB_PORT, 10),
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
  };

  const conn = await mysql.createConnection(connectionConfig);
  const [res] = await conn.execute("SELECT ?+? AS sum", [3, 2]);
  return res;
}

export const handler = async (event) => {
  // db 연동 테스트
  const result = await dbOps();

  const response = {
    statusCode: 200,
    body: JSON.stringify("The selected sum is: " + result[0].sum),
  };
  return response;
};
```


![](/assets/aws-lambda-12.png)

- **성공~!!!!**

### SES 전송

```js
import mysql from "mysql2/promise";
import { SESClient, SendEmailCommand } from "@aws-sdk/client-ses";

const sesClient = new SESClient({ region: process.env.AWS_REGION });

// ... 중략
// ... 중략

async function sendTestEmail(emailList, sentences, periodTitle, periodRange) {
  const htmlBody = makeNewsletterHTML(sentences, periodTitle, periodRange);

  const params = {
    Source: process.env.SENDER_EMAIL,
    Destination: {
      ToAddresses: emailList,
    },
    Message: {
      Subject: {
        Data: periodTitle,
        Charset: "UTF-8",
      },
      Body: {
        Html: {
          Data: htmlBody,
          Charset: "UTF-8",
        },
        Text: {
          Data: "내용이 보이지 않을 경우 https://www.daily-sentence.co.kr/weekly에서 확인 할 수 있습니다.",
          Charset: "UTF-8",
        },
      },
    },
  };

  try {
    const command = new SendEmailCommand(params);
    const result = await sesClient.send(command);
    return result;
  } catch (error) {
    console.error("Error sending email:", error);
    throw error;
  }
}

export const connectionConfig = {
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT, 10),
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
};

export async function dbOps() {
  const conn = await mysql.createConnection(connectionConfig);
  const [res] = await conn.execute("SELECT email FROM subscribers;");
  const { startDateStr, endDateStr } = await getCalculatedDate();
  const sentences = await getWeeklySentences(startDateStr, endDateStr);
  return {
    emailList: res.map((row) => row.email),
    sentences: sentences,
    startDate: startDateStr,
    endDate: endDateStr,
  };
}

// ... 중략
// ... 중략

export const handler = async (event) => {
  try {
    // db에서 이메일 리스트 가져오기
    const dbResult = await dbOps();

    // 이메일 주소만 추출하여 배열로 변환
    const { emailList, sentences, startDate, endDate } = dbResult;
    // 주간 문장 가져오기
    const { periodTitle, periodRange } = getKoreanWeekInfo(startDate, endDate);
    const emailResult = await sendTestEmail(
      emailList,
      sentences,
      periodTitle,
      periodRange
    );

    const response = {
      statusCode: 200,
      body: JSON.stringify({
        emailList: emailList,
        emailResult: "Email sent successfully: " + emailResult.MessageId,
      }),
    };
    return response;
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({
        error: error.message,
      }),
    };
  }
};

```

- Lambda에서 db에서 리스트 가져온 다음에 `@aws-sdk/client-ses` 이용하여 이메일을 전송 해주면 된다.

## AWS EventBridge

![](/assets/aws-lambda-13.png)

- 일정 -> EventBridge Scheduler -> 규칙 생성으로 이동

![](/assets/aws-lambda-14.png)

- 매주 월요일 오전 8시마다 실행 할 수 있게 크론식을 작성한다

![](/assets/aws-lambda-15.png)

- 이전에 만들어둔 Lambda 함수를 선택 해준다.
- 매주 월요일마다 Lambda를 통해서 메일링 배치 작업 스케줄을 등록 했다.

## Reference

- [https://docs.aws.amazon.com/ko_kr/sdk-for-javascript/v2/developer-guide/ses-examples-creating-template.html](https://docs.aws.amazon.com/ko_kr/sdk-for-javascript/v2/developer-guide/ses-examples-creating-template.html) 
- [https://docs.aws.amazon.com/ko_kr/lambda/latest/dg/example_serverless_connect_RDS_Lambda_section.html](https://docs.aws.amazon.com/ko_kr/lambda/latest/dg/example_serverless_connect_RDS_Lambda_section.html) 
