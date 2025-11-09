// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FamilyHub",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "FamilyHub",
            targets: ["FamilyHub"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.19.0")
    ],
    targets: [
        .target(
            name: "FamilyHub",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk")
            ]
        )
    ]
)
