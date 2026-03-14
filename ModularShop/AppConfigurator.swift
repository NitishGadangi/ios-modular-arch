import UIKit
import LoggingLib
import AnalyticsLib
import ConfigLib

final class AppConfigurator {
    private let logger: LoggerProtocol
    private let config: ConfigProviderProtocol
    private let analytics: AnalyticsServiceProtocol

    init(logger: LoggerProtocol, config: ConfigProviderProtocol, analytics: AnalyticsServiceProtocol) {
        self.logger = logger
        self.config = config
        self.analytics = analytics
    }

    func performLaunchSetup() {
        let startTime = CFAbsoluteTimeGetCurrent()

        setupLogging()
        setupAnalytics()
        setupAppearance()
        logFeatureFlags()

        let durationMs = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
        logger.info("App launch setup completed in \(String(format: "%.2f", durationMs))ms")
    }

    // MARK: - Setup Steps

    private func setupLogging() {
        let levelString = config.string(for: .logLevel)
        var loggerCopy = logger
        loggerCopy.minimumLevel = logLevel(from: levelString)
        logger.info("Logging configured: level=\(levelString)")
    }

    private func setupAnalytics() {
        let enabled = config.bool(for: .analyticsEnabled)
        if enabled {
            analytics.track(AnalyticsEvent(name: "app_launched", parameters: [:]))
            logger.info("Analytics enabled")
        } else {
            logger.info("Analytics disabled by config")
        }
    }

    private func setupAppearance() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().tintColor = .systemBlue

        logger.info("Appearance configured")
    }

    private func logFeatureFlags() {
        logger.info("Feature flags — checkout=\(config.bool(for: .isCheckoutEnabled)), promoBanner=\(config.bool(for: .showPromoBanner)), maxCartItems=\(config.int(for: .maxCartItems))")
    }

    // MARK: - Helpers

    private func logLevel(from string: String) -> LogLevel {
        switch string.lowercased() {
        case "debug": return .debug
        case "info": return .info
        case "warning": return .warning
        case "error": return .error
        default: return .debug
        }
    }
}
