// MARK: Chaining — success channel
//
// Kotlin `map` → native `map`, `flatMap`/`andThen` → also native `flatMap`.

extension Result {
	/// Kotlin `andThen { }`: monadic bind (alias of `flatMap`, Kotlin name).
	@inlinable
	public func andThen<NewSuccess>(
		_ transform: (Success) -> Result<NewSuccess, Failure>
	) -> Result<NewSuccess, Failure> {
		flatMap(transform)
	}

	/// Async `andThen`, so chains can cross an `await` without leaving the monad.
	@inlinable
	public func andThen<NewSuccess>(
		_ transform: (Success) async -> Result<NewSuccess, Failure>
	) async -> Result<NewSuccess, Failure> {
		switch self {
		case let .success(value): await transform(value)
		case let .failure(error): .failure(error)
		}
	}

	/// Kotlin `and(result)`: keep `other` if this is a success, else keep the failure.
	@inlinable
	public func and<NewSuccess>(_ other: Result<NewSuccess, Failure>) -> Result<NewSuccess, Failure> {
		andThen { _ in other }
	}
}
