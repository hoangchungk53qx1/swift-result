// MARK: Optional interop

extension Optional {
	/// Kotlin `toResultOr(error)`: lift an optional into the monad.
	@inlinable
	public func toResultOr<E: Error>(_ error: @autoclosure () -> E) -> Result<Wrapped, E> {
		switch self {
		case let .some(value): .success(value)
		case .none: .failure(error())
		}
	}
}
