// MARK: Sequences of Results

extension Sequence {
	/// Kotlin `combine(results)`: all successes → `[V]`, else the first failure.
	@inlinable
	public func combine<V, E>() -> Result<[V], E> where Element == Result<V, E> {
		var values: [V] = []
		for result in self {
			switch result {
			case let .success(value): values.append(value)
			case let .failure(error): return .failure(error)
			}
		}
		return .success(values)
	}

	/// Kotlin `getAll()`: every success value, failures dropped.
	@inlinable
	public func getAll<V, E>() -> [V] where Element == Result<V, E> {
		compactMap(\.value)
	}

	/// Kotlin `getAllErrors()`: every failure value, successes dropped.
	@inlinable
	public func getAllErrors<V, E>() -> [E] where Element == Result<V, E> {
		compactMap(\.error)
	}

	/// Kotlin `partition()`: split into `(values, errors)` in one pass.
	@inlinable
	public func partition<V, E>() -> (values: [V], errors: [E]) where Element == Result<V, E> {
		var values: [V] = []
		var errors: [E] = []
		for result in self {
			switch result {
			case let .success(value): values.append(value)
			case let .failure(error): errors.append(error)
			}
		}
		return (values, errors)
	}
}
