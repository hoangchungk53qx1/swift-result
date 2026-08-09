import Testing
@testable import SwiftResult

enum TestError: Error, Equatable {
	case notFound
	case invalid
	case network
}

private let ok: Result<Int, TestError> = .success(2)
private let err: Result<Int, TestError> = .failure(.notFound)

@Suite("Getters & predicates")
struct GetTests {
	@Test func valueAndError() {
		#expect(ok.value == 2)
		#expect(ok.error == nil)
		#expect(err.value == nil)
		#expect(err.error == .notFound)
	}

	@Test func isOkIsErr() {
		#expect(ok.isOk && !ok.isErr)
		#expect(err.isErr && !err.isOk)
	}

	@Test func getOr() {
		#expect(ok.getOr(0) == 2)
		#expect(err.getOr(0) == 0)
	}

	@Test func getOrElse() {
		#expect(ok.getOrElse { _ in 0 } == 2)
		#expect(err.getOrElse { _ in 9 } == 9)
	}

	@Test func getErrorOr() {
		#expect(ok.getErrorOr(.invalid) == .invalid)
		#expect(err.getErrorOr(.invalid) == .notFound)
	}

	@Test func getErrorOrElse() {
		#expect(ok.getErrorOrElse { _ in .invalid } == .invalid)
		#expect(err.getErrorOrElse { _ in .invalid } == .notFound)
	}

	@Test func expectUnwrapsSuccess() {
		#expect(ok.expect("must not crash") == 2)
	}
}

@Suite("Fold & transform")
struct FoldTests {
	@Test func fold() {
		#expect(ok.fold(onSuccess: { "\($0)" }, onFailure: { _ in "err" }) == "2")
		#expect(err.fold(onSuccess: { "\($0)" }, onFailure: { _ in "err" }) == "err")
	}

	@Test func mapBoth() {
		#expect(ok.mapBoth(success: { $0 * 10 }, failure: { _ in -1 }) == 20)
		#expect(err.mapBoth(success: { $0 * 10 }, failure: { _ in -1 }) == -1)
	}

	@Test func mapEither() {
		let mapped: Result<String, TestError> = ok.mapEither(
			success: { "\($0)" },
			failure: { _ in TestError.invalid }
		)
		#expect(mapped == .success("2"))

		let mappedErr: Result<String, TestError> = err.mapEither(
			success: { "\($0)" },
			failure: { _ in TestError.invalid }
		)
		#expect(mappedErr == .failure(.invalid))
	}
}

@Suite("Chaining")
struct ChainTests {
	@Test func andThen() {
		#expect(ok.andThen { .success($0 + 1) } == .success(3))
		#expect(ok.andThen { _ in Result<Int, TestError>.failure(.invalid) } == .failure(.invalid))
		#expect(err.andThen { .success($0 + 1) } == .failure(.notFound))
	}

	@Test func orElse() {
		#expect(ok.orElse { _ in Result<Int, TestError>.success(0) } == .success(2))
		#expect(err.orElse { _ in Result<Int, TestError>.success(0) } == .success(0))
		#expect(err.orElse { _ in Result<Int, TestError>.failure(.network) } == .failure(.network))
	}

	@Test func andOr() {
		#expect(ok.and(Result<String, TestError>.success("x")) == .success("x"))
		#expect(err.and(Result<String, TestError>.success("x")) == .failure(.notFound))
		#expect(ok.or(.success(0)) == .success(2))
		#expect(err.or(.success(0)) == .success(0))
	}
}

@Suite("Recovery")
struct RecoverTests {
	@Test func recover() {
		#expect(err.recover { _ in 7 } == .success(7))
		#expect(ok.recover { _ in 7 } == .success(2))
	}

	@Test func recoverIf() {
		#expect(err.recoverIf({ $0 == .notFound }, { _ in 7 }) == .success(7))
		#expect(err.recoverIf({ $0 == .network }, { _ in 7 }) == .failure(.notFound))
	}

	@Test func recoverUnless() {
		#expect(err.recoverUnless({ $0 == .network }, { _ in 7 }) == .success(7))
		#expect(err.recoverUnless({ $0 == .notFound }, { _ in 7 }) == .failure(.notFound))
	}
}

@Suite("Validation")
struct ValidationTests {
	@Test func toErrorIf() {
		#expect(ok.toErrorIf({ $0 > 1 }, { _ in .invalid }) == .failure(.invalid))
		#expect(ok.toErrorIf({ $0 > 10 }, { _ in .invalid }) == .success(2))
		#expect(err.toErrorIf({ _ in true }, { _ in .invalid }) == .failure(.notFound))
	}

	@Test func toErrorUnless() {
		#expect(ok.toErrorUnless({ $0 > 10 }, { _ in .invalid }) == .failure(.invalid))
		#expect(ok.toErrorUnless({ $0 > 1 }, { _ in .invalid }) == .success(2))
	}
}

@Suite("Side effects")
struct SideEffectTests {
	@Test func onSuccessOnFailure() {
		var seen: Int?
		var seenError: TestError?

		ok.onSuccess { seen = $0 }.onFailure { seenError = $0 }
		#expect(seen == 2)
		#expect(seenError == nil)

		seen = nil
		err.onSuccess { seen = $0 }.onFailure { seenError = $0 }
		#expect(seen == nil)
		#expect(seenError == .notFound)
	}
}

@Suite("Zip & accumulate")
struct ZipTests {
	@Test func zip2to5() {
		#expect(zip(ok, .success(3)) { $0 + $1 } == .success(5))
		#expect(zip(ok, err) { $0 + $1 } == .failure(.notFound))
		#expect(zip(ok, .success(3), .success(4)) { $0 + $1 + $2 } == .success(9))
		#expect(zip(ok, .success(3), .success(4), .success(5)) { $0 + $1 + $2 + $3 } == .success(14))
		#expect(
			zip(ok, .success(3), .success(4), .success(5), .success(6)) { $0 + $1 + $2 + $3 + $4 }
				== .success(20)
		)
	}

	@Test func zipShortCircuitsOnFirstFailure() {
		let other: Result<Int, TestError> = .failure(.network)
		#expect(zip(err, other) { $0 + $1 } == .failure(.notFound))
	}

	@Test func zipOrAccumulateCollectsAllErrors() {
		let other: Result<Int, TestError> = .failure(.network)

		let accumulated = zipOrAccumulate(err, other) { $0 + $1 }
		#expect(accumulated == .failure(AccumulatedErrors([.notFound, .network])))

		let success = zipOrAccumulate(ok, Result<Int, TestError>.success(3)) { $0 + $1 }
		#expect(success == .success(5))

		let three = zipOrAccumulate(err, ok, other) { $0 + $1 + $2 }
		#expect(three == .failure(AccumulatedErrors([.notFound, .network])))
	}
}

@Suite("Sequences")
struct IterableTests {
	private let mixed: [Result<Int, TestError>] = [.success(1), .failure(.notFound), .success(3), .failure(.network)]
	private let allOk: [Result<Int, TestError>] = [.success(1), .success(2), .success(3)]

	@Test func combine() {
		#expect(allOk.combine() == .success([1, 2, 3]))
		#expect(mixed.combine() == .failure(.notFound))
	}

	@Test func getAllAndErrors() {
		#expect(mixed.getAll() == [1, 3])
		#expect(mixed.getAllErrors() == [.notFound, .network])
	}

	@Test func partition() {
		let (values, errors) = mixed.partition()
		#expect(values == [1, 3])
		#expect(errors == [.notFound, .network])
	}
}

@Suite("Optional interop")
struct OptionalTests {
	@Test func toResultOr() {
		let some: Int? = 5
		let none: Int? = nil
		#expect(some.toResultOr(TestError.notFound) == .success(5))
		#expect(none.toResultOr(TestError.notFound) == .failure(.notFound))
	}
}

@Suite("Binding")
struct BindingTests {
	@Test func bindingSuccess() {
		let result: Result<Int, TestError> = binding {
			let a = try ok.bind()
			let b = try Result<Int, TestError>.success(3).bind()
			return a + b
		}
		#expect(result == .success(5))
	}

	@Test func bindingShortCircuits() {
		var reached = false
		let result: Result<Int, TestError> = binding {
			let a = try err.bind()
			reached = true
			return a
		}
		#expect(result == .failure(.notFound))
		#expect(!reached)
	}
}
