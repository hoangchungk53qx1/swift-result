// MARK: Zip & accumulate

/// Kotlin `zip(a, b) { }`: combine two results, short-circuiting on the first failure.
@inlinable
public func zip<A, B, T, E: Error>(
	_ a: Result<A, E>,
	_ b: Result<B, E>,
	_ transform: (A, B) -> T
) -> Result<T, E> {
	a.andThen { va in b.map { vb in transform(va, vb) } }
}

/// Kotlin `zip(a, b, c) { }`.
@inlinable
public func zip<A, B, C, T, E: Error>(
	_ a: Result<A, E>,
	_ b: Result<B, E>,
	_ c: Result<C, E>,
	_ transform: (A, B, C) -> T
) -> Result<T, E> {
	zip(a, b) { ($0, $1) }.andThen { pair in c.map { vc in transform(pair.0, pair.1, vc) } }
}

/// Kotlin `zip(a, b, c, d) { }`.
@inlinable
public func zip<A, B, C, D, T, E: Error>(
	_ a: Result<A, E>,
	_ b: Result<B, E>,
	_ c: Result<C, E>,
	_ d: Result<D, E>,
	_ transform: (A, B, C, D) -> T
) -> Result<T, E> {
	zip(a, b, c) { ($0, $1, $2) }.andThen { t in d.map { vd in transform(t.0, t.1, t.2, vd) } }
}

/// Kotlin `zip(a, b, c, d, e) { }`.
@inlinable
public func zip<A, B, C, D, F, T, E: Error>(
	_ a: Result<A, E>,
	_ b: Result<B, E>,
	_ c: Result<C, E>,
	_ d: Result<D, E>,
	_ f: Result<F, E>,
	_ transform: (A, B, C, D, F) -> T
) -> Result<T, E> {
	zip(a, b, c, d) { ($0, $1, $2, $3) }.andThen { t in f.map { vf in transform(t.0, t.1, t.2, t.3, vf) } }
}

/// Failure type for `zipOrAccumulate`. Kotlin returns `NonEmptyList<E>` directly, but
/// Swift's `Result` requires `Failure: Error`, so the collected errors need a wrapper.
public struct AccumulatedErrors<E: Error>: Error {
	public let errors: [E]

	public init(_ errors: [E]) {
		self.errors = errors
	}
}

extension AccumulatedErrors: Equatable where E: Equatable {}
extension AccumulatedErrors: Sendable where E: Sendable {}

/// Kotlin `zipOrAccumulate(a, b) { }`: like `zip`, but collects *all* failures
/// instead of short-circuiting on the first — for validation-style flows.
public func zipOrAccumulate<A, B, T, E: Error>(
	_ a: Result<A, E>,
	_ b: Result<B, E>,
	_ transform: (A, B) -> T
) -> Result<T, AccumulatedErrors<E>> {
	let errors = [a.error, b.error].compactMap { $0 }
	guard errors.isEmpty, let va = a.value, let vb = b.value else {
		return .failure(AccumulatedErrors(errors))
	}
	return .success(transform(va, vb))
}

/// Kotlin `zipOrAccumulate(a, b, c) { }`.
public func zipOrAccumulate<A, B, C, T, E: Error>(
	_ a: Result<A, E>,
	_ b: Result<B, E>,
	_ c: Result<C, E>,
	_ transform: (A, B, C) -> T
) -> Result<T, AccumulatedErrors<E>> {
	let errors = [a.error, b.error, c.error].compactMap { $0 }
	guard errors.isEmpty, let va = a.value, let vb = b.value, let vc = c.value else {
		return .failure(AccumulatedErrors(errors))
	}
	return .success(transform(va, vb, vc))
}

/// Kotlin `zipOrAccumulate(a, b, c, d) { }`.
public func zipOrAccumulate<A, B, C, D, T, E: Error>(
	_ a: Result<A, E>,
	_ b: Result<B, E>,
	_ c: Result<C, E>,
	_ d: Result<D, E>,
	_ transform: (A, B, C, D) -> T
) -> Result<T, AccumulatedErrors<E>> {
	let errors = [a.error, b.error, c.error, d.error].compactMap { $0 }
	guard errors.isEmpty,
	      let va = a.value, let vb = b.value, let vc = c.value, let vd = d.value else {
		return .failure(AccumulatedErrors(errors))
	}
	return .success(transform(va, vb, vc, vd))
}

/// Kotlin `zipOrAccumulate(a, b, c, d, e) { }`.
public func zipOrAccumulate<A, B, C, D, F, T, E: Error>(
	_ a: Result<A, E>,
	_ b: Result<B, E>,
	_ c: Result<C, E>,
	_ d: Result<D, E>,
	_ f: Result<F, E>,
	_ transform: (A, B, C, D, F) -> T
) -> Result<T, AccumulatedErrors<E>> {
	let errors = [a.error, b.error, c.error, d.error, f.error].compactMap { $0 }
	guard errors.isEmpty,
	      let va = a.value, let vb = b.value, let vc = c.value, let vd = d.value,
	      let vf = f.value else {
		return .failure(AccumulatedErrors(errors))
	}
	return .success(transform(va, vb, vc, vd, vf))
}
