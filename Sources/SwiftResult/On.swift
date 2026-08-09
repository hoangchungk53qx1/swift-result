// MARK: Side effects

extension Result {
	/// Kotlin `onSuccess { }`: peek at the success channel, pass `self` through.
	@discardableResult
	@inlinable
	public func onSuccess(_ action: (Success) -> Void) -> Result<Success, Failure> {
		if case let .success(value) = self { action(value) }
		return self
	}

	/// Kotlin `onFailure { }`: peek at the failure channel, pass `self` through.
	@discardableResult
	@inlinable
	public func onFailure(_ action: (Failure) -> Void) -> Result<Success, Failure> {
		if case let .failure(error) = self { action(error) }
		return self
	}
}
