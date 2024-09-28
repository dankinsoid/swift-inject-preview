// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
	name: "SwiftInjectPreview",
	platforms: [
		.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6),
	],
	products: [
		.library(name: "SwiftInjectPreview", targets: ["SwiftInjectPreview"]),
	],
	dependencies: [
		.package(url: "https://github.com/swiftlang/swift-syntax", "509.0.0" ..< "601.0.0-prerelease"),
	],
	targets: [
		.target(
			name: "SwiftInjectPreview",
			dependencies: [
				.target(name: "SwiftInjectPreviewMacro"),
			]
		),
		.macro(
			name: "SwiftInjectPreviewMacro",
			dependencies: [
				.product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
				.product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
			]
		),
	]
)
