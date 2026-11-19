import SwiftUI
import UIKit

@MainActor
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        if !SettingsManager.shared.hasAcceptedTerms {
            let terms = TermsAndConditionsView { [weak self] in
                SettingsManager.shared.hasAcceptedTerms = true
                self?.launchFlow(window)
            }
            window.rootViewController = UIHostingController(rootView: terms)
            window.makeKeyAndVisible()
            return
        }

        launchFlow(window)
    }

    private func launchFlow(_ window: UIWindow) {
        let launchView = LaunchView(frame: window.frame)
        let launchController = UIViewController()
        launchController.view = launchView

        let navigationController = UINavigationController(rootViewController: launchController)
        navigationController.isNavigationBarHidden = true
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        Task { @MainActor in
            do {
                _ = SFXManager.shared
                _ = EvolutionResearchManager.shared

                let hasSave = await LocalGameSaveService.shared.hasSave()
                let account: Account
                if hasSave {
                    account = try await LocalGameSaveService.shared.loadAccount()
                } else {
                    account = Account()
                }
                let savedState = hasSave ? try await LocalGameSaveService.shared.loadSnapshot() : nil
                if let savedState, savedState.account.id == account.id {
                    SettingsManager.shared.isFirstLogin = !savedState.account.isTutorialComplete
                }
                try GameManager.shared.changeAccount(to: account)
                if let savedState,
                   savedState.account.id == account.id,
                   let selectedApiary = account.apiaries.first(where: { $0.id == savedState.activeApiaryID }) {
                    try GameManager.shared.changeApiary(selectedApiary)
                }
                launchView.progress.setProgress(0.5, animated: true)

                try GameStore.shared.start()
                try await GameStore.shared.flush()

                let controller: ApiaryViewController = SettingsManager.shared.isFirstLogin
                    ? TutorialViewController(frame: window.frame)
                    : ApiaryViewController(frame: window.frame)
                launchView.progress.setProgress(1, animated: true)
                navigationController.setViewControllers([controller], animated: false)
            } catch {
                launchView.showError("Unable to load game")
                let alert = UIAlertController(title: "Unable to load game", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
                    self?.launchFlow(window)
                })
                navigationController.present(alert, animated: true)
            }
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        GameManager.shared.apiary.lastOnline = .now
        let taskID = UIApplication.shared.beginBackgroundTask(withName: "Save Game")
        Task { @MainActor in
            defer {
                if taskID != .invalid {
                    UIApplication.shared.endBackgroundTask(taskID)
                }
            }
            do {
                try await GameStore.shared.flush()
            } catch {
                GameStore.shared.recordChange()
            }
        }
    }
}
