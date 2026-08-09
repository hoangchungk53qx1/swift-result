// MARK: Predicates & getters

extension Result {
	/// Kotlin `component1()` / `get()`: the success value, or `nil`.
	@inlinable
	public var value: Success? {
		if case let .success(value) = self { return value }
		return nil
	}

	/// Kotlin `component2()` / `getError()`: the failure value, or `nil`.
	@inlinable
	public var error: Failure? {
		if case let .failure(error) = self { return error }
		return nil
	}

	/// Kotlin `isOk`.
	@inlinable
	public var isOk: Bool {
		if case .success = self { return true }
		return false
	}

	/// Kotlin `isErr`.
	@inlinable
	public var isErr: Bool { !isOk }

	/// Kotlin `getOr(default)`.
	@inlinable
	public func getOr(_ defaultValue: @autoclosure () -> Success) -> Success {
		value ?? defaultValue()
	}

	/// Kotlin `getOrElse { }`.
	@inlinable
	public func getOrElse(_ transform: (Failure) -> Success) -> Success {
		fold(onSuccess: { $0 }, onFailure: transform)
	}

	/// Kotlin `getErrorOr(default)`.
	@inlinable
	public func getErrorOr(_ defaultValue: @autoclosure () -> Failure) -> Failure {
		error ?? defaultValue()
	}

	/// Kotlin `getErrorOrElse { }`.
	@inlinable
	public func getErrorOrElse(_ transform: (Success) -> Failure) -> Failure {
		fold(onSuccess: transform, onFailure: { $0 })
	}

	/// Kotlin `expect { }`: unwrap or crash with a message. Debug/test seams only.
	@inlinable
	public func expect(_ message: @autoclosure () -> String) -> Success {
		guard let value else { fatalError(message()) }
		return value
	}
}
