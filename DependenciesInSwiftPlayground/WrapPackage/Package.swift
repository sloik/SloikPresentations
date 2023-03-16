// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WrapPackage",
    platforms: [
           .macOS(.v10_13),
           .iOS(.v11),
           .tvOS(.v11),
           .watchOS(.v3)
       ],
    products: [
        .library(
            name: "WrapPackage",
            type: .dynamic,
            targets: ["WrapPackage"]),
    ],
    dependencies: [

        // Dependencies go here
        .package(
            name: "OptionalAPI",
            url: "https://github.com/sloik/OptionalAPI",
            from: "5.0.2"
        ),

    ],
    targets: [
        .target(
            name: "WrapPackage",
            dependencies: [

                // And products of dependencies here
                .product(name: "OptionalAPI", package: "OptionalAPI"),

        ]),


        .testTarget(
            name: "WrapPackageTests",
            dependencies: ["WrapPackage"]),
    ]
)
