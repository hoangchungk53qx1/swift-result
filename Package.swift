// swift-tools-version:6.0

import PackageDescription

let package = Package(
	name: "swift-result",
	platforms: [
		.iOS(.v13),
		.macOS(.v10_15),
		.tvOS(.v13),
		.watchOS(.v6),
		.visionOS(.v1),
	],
	products: [
		.library(name: "SwiftResult", targets: ["SwiftResult"]),
	],
	targets: [
		.target(name: "SwiftResult"),
		.testTarget(name: "SwiftResultTests", dependencies: ["SwiftResult"]),
	]
)
