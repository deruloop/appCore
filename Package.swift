// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppCore",
	platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AppCore",
            targets: ["AppCore"]),
    ],
	dependencies: [
		.package(url: "https://github.com/RevenueCat/purchases-ios-spm.git", .upToNextMajor(from: "5.13.0"))
	],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
		// Targets can depend on other targets in this package and products from dependencies.
		.target(
			name: "AppCore",
			dependencies: [
				// Specify the target dependencies
				.product(name: "RevenueCat", package: "purchases-ios-spm"),
				.product(name: "RevenueCatUI", package: "purchases-ios-spm")
			],
			path: "Sources"),
        .testTarget(
            name: "AppCoreTests",
            dependencies: ["AppCore"]
        ),
    ]
)
