import UIKit
import SharedRouterInterface

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var compositionRoot: CompositionRoot!
    private var deeplinkHandler: DeeplinkHandler!

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true

        compositionRoot = CompositionRoot(navigationController: navigationController)
        compositionRoot.appConfigurator.performLaunchSetup()
        let rootVC = compositionRoot.assembleAndStart()
        navigationController.viewControllers = [rootVC]

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        deeplinkHandler = compositionRoot.makeDeeplinkHandler()

        // Handle deeplinks from cold start
        if let urlContext = connectionOptions.urlContexts.first {
            _ = deeplinkHandler.handle(url: urlContext.url)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        _ = deeplinkHandler?.handle(url: url)
    }
}
