import Foundation

// MARK: runCatching (cancellation-safe)

/// Cancellation-safe async `runCatching`: `CancellationError` propagates (typed throws),
/// every other failure becomes `.failure`. This is the single bridge from the `throws`
/// world into the `Result` monad — cancellation stays a control-flow signal, domain
/// errors become values.
@inlinable
public func runCatchingCancellationSafe<V>(
	_ body: () async throws -> V
) async throws(CancellationError) -> Result<V, any Error> {
	do {
		return .success(try await body())
	} catch let cancellation as CancellationError {
		throw cancellation // propagate — the caller's `try?` swallows only this
	} catch {
		return .failure(error) // domain error → Result
	}
}

extension Result where Failure == any Error {
	/// Monadic bind with an async transform. Handles cancellation and errors internally,
	/// so the enclosing function does not need `throws`.
	public func asyncFlatMap<NewSuccess>(
		_ transform: (Success) async throws -> NewSuccess
	) async -> Result<NewSuccess, any Error> {
		switch self {
		case let .success(value):
			guard !Task.isCancelled else { return .failure(CancellationError()) }
			do {
				return .success(try await transform(value))
			} catch {
				return .failure(error)
			}
		case let .failure(error):
			return .failure(error)
		}
	}
}
