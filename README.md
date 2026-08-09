# swift-result

A Swift port of the operator surface of [kotlin-result](https://github.com/michaelbull/kotlin-result) (Michael Bull), built on top of Swift's native `Result<Success, Failure>` — no new type, just the missing operators.

Requires Swift 6.0+ (typed throws).

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/<you>/swift-result.git", from: "0.1.0")
]
// target dependency: "SwiftResult"
```

## Operator mapping

| kotlin-result | SwiftResult |
|---|---|
| `get()` / `component1()` | `.value` |
| `getError()` / `component2()` | `.error` |
| `isOk` / `isErr` | `.isOk` / `.isErr` |
| `getOr` / `getOrElse` | `getOr(_:)` / `getOrElse(_:)` |
| `getErrorOr` / `getErrorOrElse` | `getErrorOr(_:)` / `getErrorOrElse(_:)` |
| `expect { }` | `expect(_:)` |
| `map` / `mapError` | native `map` / `mapError` |
| `mapBoth` / `mapEither` | `mapBoth` / `mapEither` |
| `fold` | `fold(onSuccess:onFailure:)` |
| `andThen` / `flatMap` | `andThen` (sync & async), native `flatMap` |
| `orElse` / `flatMapError` | `orElse` (sync & async), native `flatMapError` |
| `and` / `or` | `and(_:)` / `or(_:)` |
| `recover` / `recoverIf` / `recoverUnless` | same names |
| `toErrorIf` / `toErrorUnless` | same names |
| `onSuccess` / `onFailure` | same names |
| `zip` (2–5) | `zip` (2–5) |
| `zipOrAccumulate` (2–5) | `zipOrAccumulate` (2–5), failure wrapped in `AccumulatedErrors` |
| `combine` / `getAll` / `getAllErrors` / `partition` | `Sequence` extensions, same names |
| `toResultOr` | `Optional.toResultOr(_:)` |
| `.bind()` | `try result.bind()` (typed throws — stdlib `get()` throws `any Error`) |
| `binding { .bind() }` | `binding { try result.bind() }` (sync & async, typed throws) |
| `runCatching` | `runCatchingCancellationSafe` (cancellation propagates, domain errors become `.failure`) |

## Examples

```swift
import SwiftResult

// Monad comprehension — `try .bind()` is Kotlin's `.bind()`.
// Multi-statement closures need the explicit typed-throws signature.
let result: Result<Int, AppError> = binding { () throws(AppError) -> Int in
    let page = try pageResult.bind()
    let detail = try detailResult.bind()
    return page.totalCount + detail.categories.count
}

// Validation with error accumulation
let user = zipOrAccumulate(nameResult, emailResult) { User(name: $0, email: $1) }

// Async chains without leaving the monad
let books = await fetchPage(1)
    .andThen { page in await fetchDetails(page) }
    .orElse { _ in await loadFromCache() }

// Cancellation-safe bridge from the `throws` world
let data = try await runCatchingCancellationSafe { try await api.load() }
```
