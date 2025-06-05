
## 1. nullish coalescing operator

- Prefer using nullish coalescing operator (`??`) instead of a logical or (`||`), as it is a safer operator.

The nullish coalescing operator `??` allows providing a default value when dealing with `null` or `undefined`. It only coalesces when the original value is `null` or `undefined`. Therefore, it is safer and shorter than relying upon chaining logical `||` expressions or testing against `null` or `undefined` explicitly.

This rule reports when disjunctions (`||`) and conditionals (`?`) can be safely replaced with coalescing (`??`).

The TSConfig needs to set `strictNullChecks` to `true` for the rule to work properly.

```ts
return applyDecorators(
	ApiOperation(options),
	multiSuccessResponse(
		options.status || HttpStatus.OK,
		SuccesResponseOptions,
	),
	multiExceptionResponse(
		options.status || HttpStatus.BAD_REQUEST,
		ExceptionResponseOptions,
	),
	...additionalDecorators,
);
// 만약 status가 0이라면?
options.status = 0;
options.status || HttpStatus.OK // → HttpStatus.OK (0은 falsy이므로 무시됨)
options.status ?? HttpStatus.OK // → 0 유지 (null, undefined 아님)
```

`"||"` 지양하고 nullish coalescing operator를 사용


## RegExp.exec()

- Use the "RegExp.exec()" method instead.

`String.match()` behaves the same way as `RegExp.exec()` when the regular expression does not include the global flag `g`. While they work the same, `RegExp.exec()` can be slightly faster than `String.match()`. Therefore, it should be preferred for better performance.

The rule reports an issue on a call to `String.match()` whenever it can be replaced with semantically equivalent `RegExp.exec()`.

```ts
// ❌
'foo'.match(/bar/);
// ✅
/bar/.exec('foo');
```

