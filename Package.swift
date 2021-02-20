// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OurPulse",
    platforms: [
        .macOS(.v11),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "3.0.0"),
        .package(url: "https://github.com/swiftpackages/DotEnv.git", from: "2.0.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "4.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "OurPulse",
            dependencies: [
                .product(name: "DotEnv", package: "DotEnv"),
                .product(name: "Rainbow", package: "Rainbow"),
                .product(name: "SwiftyJSON", package: "SwiftyJSON"),
            ]),
        .testTarget(
            name: "OurPulseTests",
            dependencies: ["OurPulse"]),
    ]
)
