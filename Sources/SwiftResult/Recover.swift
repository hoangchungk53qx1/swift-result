// MARK: Recovery

extension Result {
	/// Kotlin `recover { }`: turn any failure into a success.
	@inlinable
	public func recover(_ transform: (Failure) -> Success) -> Result<Success, Failure> {
		fold(onSuccess: { .success($0) }, onFailure: { .success(transform($0)) })
	}

	/// Kotlin `recoverIf(predicate) { }`: recover only matching failures.
	@inlinable
	public func recoverIf(
		_ predicate: (Failure) -> Bool,
		_ transform: (Failure) -> Success
	) -> Result<Success, Failure> {
		orElse { error in
			predicate(error) ? .success(transform(error)) : .failure(error)
		}
	}

	/// Kotlin `recoverUnless(predicate) { }`: recover only non-matching failures.
	@inlinable
	public func recoverUnless(
		_ predicate: (Failure) -> Bool,
		_ transform: (Failure) -> Success
	) -> Result<Success, Failure> {
		recoverIf({ !predicate($0) }, transform)
	}
}
