// MARK: Fold & two-channel transforms

extension Result {
	/// Consume the Result at the end of a chain: one handler per case, no `switch` at
	/// the call site (catamorphism).
	@inlinable
	public func fold<T>(
		onSuccess: (Success) -> T,
		onFailure: (Failure) -> T
	) -> T {
		switch self {
		case let .success(value): onSuccess(value)
		case let .failure(error): onFailure(error)
		}
	}

	/// Kotlin `mapBoth(success:failure:)` — identical to `fold`, kept for familiarity.
	@inlinable
	public func mapBoth<T>(success: (Success) -> T, failure: (Failure) -> T) -> T {
		fold(onSuccess: success, onFailure: failure)
	}

	/// Kotlin `mapEither(success:failure:)`: transform both channels at once.
	@inlinable
	public func mapEither<NewSuccess, NewFailure: Error>(
		success: (Success) -> NewSuccess,
		failure: (Failure) -> NewFailure
	) -> Result<NewSuccess, NewFailure> {
		switch self {
		case let .success(value): .success(success(value))
		case let .failure(error): .failure(failure(error))
		}
	}
}
