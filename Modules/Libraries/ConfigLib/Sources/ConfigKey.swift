import Foundation

public enum ConfigKey: String, CaseIterable {
    case apiBaseURL = "api_base_url"
    case logLevel = "log_level"
    case analyticsEnabled = "analytics_enabled"
    case analyticsBatchSize = "analytics_batch_size"
    case analyticsFlushInterval = "analytics_flush_interval"
    case maxCartItems = "max_cart_items"
    case isCheckoutEnabled = "is_checkout_enabled"
    case showPromoBanner = "show_promo_banner"
    case networkTimeoutSeconds = "network_timeout_seconds"
}
