// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ModularShop",
    platforms: [.iOS(.v17)],
    products: [
        // Libraries
        .library(name: "LoggingLib", targets: ["LoggingLib"]),
        .library(name: "NetworkLib", targets: ["NetworkLib"]),
        .library(name: "AnalyticsLib", targets: ["AnalyticsLib"]),
        .library(name: "UIComponents", targets: ["UIComponents"]),
        .library(name: "ConfigLib", targets: ["ConfigLib"]),

        // Interface modules
        .library(name: "SharedRouterInterface", targets: ["SharedRouterInterface"]),
        .library(name: "HomeInterface", targets: ["HomeInterface"]),
        .library(name: "DetailsInterface", targets: ["DetailsInterface"]),
        .library(name: "CartInterface", targets: ["CartInterface"]),
        .library(name: "CheckoutInterface", targets: ["CheckoutInterface"]),

        // Concrete modules
        .library(name: "SharedRouter", targets: ["SharedRouter"]),
        .library(name: "Home", targets: ["Home"]),
        .library(name: "Details", targets: ["Details"]),
        .library(name: "Cart", targets: ["Cart"]),
        .library(name: "Checkout", targets: ["Checkout"]),
    ],
    dependencies: [],
    targets: [
        // MARK: - Libraries

        .target(
            name: "LoggingLib",
            path: "Modules/Libraries/LoggingLib/Sources"
        ),
        .target(
            name: "NetworkLib",
            path: "Modules/Libraries/NetworkLib/Sources",
            resources: [.process("ResponseMocks")]
        ),
        .target(
            name: "AnalyticsLib",
            path: "Modules/Libraries/AnalyticsLib/Sources"
        ),
        .target(
            name: "UIComponents",
            path: "Modules/Libraries/UIComponents/Sources"
        ),
        .target(
            name: "ConfigLib",
            path: "Modules/Libraries/ConfigLib/Sources"
        ),

        // MARK: - Interface Modules

        .target(
            name: "SharedRouterInterface",
            path: "Modules/SharedRouter/SharedRouterInterface/Sources"
        ),
        .target(
            name: "HomeInterface",
            path: "Modules/Home/HomeInterface/Sources"
        ),
        .target(
            name: "DetailsInterface",
            path: "Modules/Details/DetailsInterface/Sources"
        ),
        .target(
            name: "CartInterface",
            path: "Modules/Cart/CartInterface/Sources"
        ),
        .target(
            name: "CheckoutInterface",
            path: "Modules/Checkout/CheckoutInterface/Sources"
        ),

        // MARK: - Concrete Feature Modules

        .target(
            name: "Home",
            dependencies: [
                "HomeInterface",
                "SharedRouterInterface",
                "NetworkLib",
                "AnalyticsLib",
                "LoggingLib",
                "UIComponents",
            ],
            path: "Modules/Home/Home/Sources"
        ),
        .target(
            name: "Details",
            dependencies: [
                "DetailsInterface",
                "SharedRouterInterface",
                "CartInterface",
                "NetworkLib",
                "AnalyticsLib",
                "LoggingLib",
                "UIComponents",
            ],
            path: "Modules/Details/Details/Sources"
        ),
        .target(
            name: "Cart",
            dependencies: [
                "CartInterface",
                "SharedRouterInterface",
                "NetworkLib",
                "AnalyticsLib",
                "LoggingLib",
                "UIComponents",
            ],
            path: "Modules/Cart/Cart/Sources"
        ),
        .target(
            name: "Checkout",
            dependencies: [
                "CheckoutInterface",
                "SharedRouterInterface",
                "CartInterface",
                "NetworkLib",
                "AnalyticsLib",
                "LoggingLib",
                "UIComponents",
            ],
            path: "Modules/Checkout/Checkout/Sources"
        ),
        .target(
            name: "SharedRouter",
            dependencies: [
                "SharedRouterInterface",
                "HomeInterface",
                "DetailsInterface",
                "CartInterface",
                "CheckoutInterface",
            ],
            path: "Modules/SharedRouter/SharedRouter/Sources"
        ),

        // MARK: - Test Targets

        .testTarget(
            name: "HomeTests",
            dependencies: [
                "Home",
                "HomeInterface",
                "NetworkLib",
                "AnalyticsLib",
            ],
            path: "Modules/Home/HomeTests"
        ),
        .testTarget(
            name: "DetailsTests",
            dependencies: [
                "Details",
                "DetailsInterface",
                "CartInterface",
                "NetworkLib",
                "AnalyticsLib",
            ],
            path: "Modules/Details/DetailsTests"
        ),
        .testTarget(
            name: "CartTests",
            dependencies: [
                "Cart",
                "CartInterface",
                "AnalyticsLib",
            ],
            path: "Modules/Cart/CartTests"
        ),
        .testTarget(
            name: "CheckoutTests",
            dependencies: [
                "Checkout",
                "CheckoutInterface",
                "CartInterface",
                "NetworkLib",
                "AnalyticsLib",
            ],
            path: "Modules/Checkout/CheckoutTests"
        ),
        .testTarget(
            name: "SharedRouterTests",
            dependencies: [
                "SharedRouter",
                "SharedRouterInterface",
                "HomeInterface",
                "DetailsInterface",
                "CartInterface",
                "CheckoutInterface",
            ],
            path: "Modules/SharedRouter/SharedRouterTests"
        ),
        .testTarget(
            name: "NetworkLibTests",
            dependencies: ["NetworkLib"],
            path: "Modules/Libraries/NetworkLib/Tests"
        ),
        .testTarget(
            name: "AnalyticsLibTests",
            dependencies: ["AnalyticsLib"],
            path: "Modules/Libraries/AnalyticsLib/Tests"
        ),
    ]
)
