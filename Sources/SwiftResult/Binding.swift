// MARK: Binding (monad comprehension)

extension Result {
	/// Kotlin `.bind()`: the success value, or throw the *typed* failure.
	/// Unlike the stdlib `get()` (which throws `any Error`), the thrown type is
	/// `Failure`, so it composes with `binding { }` without erasing the error type.
	@inlinable
	public func bind() throws(Failure) -> Success {
		switch self {
		case let .success(value): return value
		case let .failure(error): throw error
		}
	}
}

/// Kotlin-result `binding { }`, built on Swift typed throws: inside the body,
/// `try someResult.bind()` plays the role of Kotlin's `.bind()` — the first failure
/// short-circuits the whole block into a `.failure`.
///
///     let result: Result<Int, AppError> = binding {
///         let page = try pageResult.bind()
///         let detail = try detailResult.bind()
///         return page.totalCount + detail.categories.count
///     }
@inlinable
public func binding<V, E: Error>(_ body: () throws(E) -> V) -> Result<V, E> {
	do throws(E) {
		return .success(try body())
	} catch {
		return .failure(error)
	}
}

/// Async `binding { }` — the comprehension can `await` between binds.
@inlinable
public func binding<V, E: Error>(_ body: () async throws(E) -> V) async -> Result<V, E> {
	do throws(E) {
		return .success(try await body())
	} catch {
		return .failure(error)
	}
}
