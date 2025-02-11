
```sql
mysql> SELECT student.student_name,COUNT(*)
       FROM student,course
       WHERE student.student_id=course.student_id
       GROUP BY student_name;
```

- [mysql 8.0 function_count 공식문서](https://dev.mysql.com/doc/refman/8.0/en/aggregate-functions.html#function_count) - 일치하는 행이 없는 경우 COUNT()는 0을 반환합니다. COUNT(NULL)은 0을 반환합니다.
- over_clause가 있는 경우 이 함수는 윈도우 함수로 실행됩니다.
- window 함수가 뭔데?
	- [mysql 8.0 window-function](https://dev.mysql.com/doc/refman/8.0/en/window-functions-usage.html) 
	- `SUM, MAX, MIN` 같은 집계 함수 말하는거였구나.
	- window 함수는 select절과 ORDER BY 절에서만 허용된다.
	- 쿼리 결과 행은 FROM절에서 WHERE, GROUP BY, HAVING 처리 후에 결정
	- 윈도우 실행은 ORDER BY, LIMIT, SELECT DISTINT 이전에 이루어진다.

1. 동작 원리를 공부해보고 개수를 늘려서 테스트 해보는 방향이 필요할것 같다.

https://dev.mysql.com/doc/refman/8.0/en/counting-rows.html
https://dev.mysql.com/doc/refman/8.0/en/group-by-handling.html


- 릴마큐 인프런 강의 COUNT 튜닝 목차가 있네!
- 릴마큐 책 2편 count 부분 정독.

```sql
SELECT o.custid, c.name, MAX(o.payment)
  FROM orders AS o, customers AS c
  WHERE o.custid = c.custid
  GROUP BY o.custid;
```

- SQL-92 및 이전 버전에서 select 목록, HAVING 조건 또는 ORDER BY 목록이 GROUP BY 절에 명명되지 않은 집계되지 않은 열을 참조하는 쿼리는 허용되지 않는다.

