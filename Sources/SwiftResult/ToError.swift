// MARK: Validation

extension Result {
	/// Kotlin `toErrorIf(predicate) { }`: demote matching successes to failures.
	@inlinable
	public func toErrorIf(
		_ predicate: (Success) -> Bool,
		_ transform: (Success) -> Failure
	) -> Result<Success, Failure> {
		andThen { value in
			predicate(value) ? .failure(transform(value)) : .success(value)
		}
	}

	/// Kotlin `toErrorUnless(predicate) { }`.
	@inlinable
	public func toErrorUnless(
		_ predicate: (Success) -> Bool,
		_ transform: (Success) -> Failure
	) -> Result<Success, Failure> {
		toErrorIf({ !predicate($0) }, transform)
	}
}
