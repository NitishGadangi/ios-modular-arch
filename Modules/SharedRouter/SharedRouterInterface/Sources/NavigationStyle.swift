import Foundation

public enum NavigationStyle {
    case push
    case present(fullScreen: Bool = false)
    case replaceRoot
}
