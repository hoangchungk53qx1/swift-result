// MARK: Chaining — failure channel
//
// Kotlin `mapError` → native `mapError`, `flatMapError` → also native `flatMapError`.

extension Result {
	/// Kotlin `orElse { }`: bind on the failure channel (alias of `flatMapError`).
	@inlinable
	public func orElse<NewFailure: Error>(
		_ transform: (Failure) -> Result<Success, NewFailure>
	) -> Result<Success, NewFailure> {
		flatMapError(transform)
	}

	/// Async `orElse` — e.g. retry from a fallback source.
	@inlinable
	public func orElse<NewFailure: Error>(
		_ transform: (Failure) async -> Result<Success, NewFailure>
	) async -> Result<Success, NewFailure> {
		switch self {
		case let .success(value): .success(value)
		case let .failure(error): await transform(error)
		}
	}

	/// Kotlin `or(result)`: keep this if it is a success, else `other`.
	@inlinable
	public func or(_ other: Result<Success, Failure>) -> Result<Success, Failure> {
		orElse { _ in other }
	}
}
