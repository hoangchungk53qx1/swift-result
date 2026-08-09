// MARK: Binding (monad comprehension)

/// Kotlin-result `binding { }`, built on Swift typed throws: inside the body,
/// `try someResult.get()` plays the role of Kotlin's `.bind()` — the first failure
/// short-circuits the whole block into a `.failure`.
///
///     let result: Result<Int, AppError> = binding {
///         let page = try pageResult.get()
///         let detail = try detailResult.get()
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
