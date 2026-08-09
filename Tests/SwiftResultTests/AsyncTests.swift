import Foundation
import Testing
@testable import SwiftResult

@Suite("Async operators")
struct AsyncOperatorTests {
	private let ok: Result<Int, TestError> = .success(2)
	private let err: Result<Int, TestError> = .failure(.notFound)

	@Test func asyncAndThen() async {
		let result = await ok.andThen { value async -> Result<Int, TestError> in
			.success(value + 1)
		}
		#expect(result == .success(3))

		let failed = await err.andThen { value async -> Result<Int, TestError> in
			.success(value + 1)
		}
		#expect(failed == .failure(.notFound))
	}

	@Test func asyncOrElse() async {
		let recovered = await err.orElse { _ async -> Result<Int, TestError> in
			.success(0)
		}
		#expect(recovered == .success(0))

		let untouched = await ok.orElse { _ async -> Result<Int, TestError> in
			.success(0)
		}
		#expect(untouched == .success(2))
	}

	@Test func asyncBinding() async {
		let result: Result<Int, TestError> = await binding { () async throws(TestError) -> Int in
			let a = try ok.get()
			await Task.yield()
			let b = try Result<Int, TestError>.success(3).get()
			return a + b
		}
		#expect(result == .success(5))

		let failed: Result<Int, TestError> = await binding { () async throws(TestError) -> Int in
			await Task.yield()
			return try err.get()
		}
		#expect(failed == .failure(.notFound))
	}
}

@Suite("runCatchingCancellationSafe & asyncFlatMap")
struct RunCatchingTests {
	@Test func successBecomesSuccess() async throws {
		let result = try await runCatchingCancellationSafe { 42 }
		#expect(result.value == 42)
	}

	@Test func domainErrorBecomesFailure() async throws {
		let result: Result<Int, any Error> = try await runCatchingCancellationSafe {
			throw TestError.network
		}
		#expect(result.error as? TestError == .network)
	}

	@Test func cancellationPropagates() async {
		// `Result<Int, any Error>` is not Sendable, so only a Sendable summary
		// crosses the Task boundary.
		let task = Task { () -> Bool in
			let result = try? await runCatchingCancellationSafe { () async throws -> Int in
				try await Task.sleep(nanoseconds: 1_000_000_000)
				return 1
			}
			return result == nil // CancellationError was thrown, swallowed only by `try?`
		}
		task.cancel()
		#expect(await task.value)
	}

	@Test func asyncFlatMapChains() async {
		let start: Result<Int, any Error> = .success(2)
		let result = await start.asyncFlatMap { $0 * 10 }
		#expect(result.value == 20)

		let failed = await start.asyncFlatMap { _ -> Int in
			throw TestError.invalid
		}
		#expect(failed.error as? TestError == .invalid)

		let short: Result<Int, any Error> = .failure(TestError.notFound)
		let untouched = await short.asyncFlatMap { $0 * 10 }
		#expect(untouched.error as? TestError == .notFound)
	}

	@Test func asyncFlatMapRespectsCancellation() async {
		let task = Task { () -> Bool in
			_ = withUnsafeCurrentTask { $0?.cancel() } // cancel from inside
			let start: Result<Int, any Error> = .success(2)
			let result = await start.asyncFlatMap { $0 * 10 }
			return result.error is CancellationError
		}
		#expect(await task.value)
	}
}
