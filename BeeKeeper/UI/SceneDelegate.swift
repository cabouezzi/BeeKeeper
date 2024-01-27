//
//  SceneDelegate.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 10/8/23.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        let launchView = LaunchView()
        let launchViewController = UIHostingController(rootView: launchView)
        
        let navigationController = UINavigationController()
        navigationController.pushViewController(launchViewController, animated: false)
        navigationController.modalPresentationStyle = .none
        navigationController.isNavigationBarHidden = true
        
        self.window = window
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        Task.detached {
            // For performing some kind of animation
            let wait = Task {
                sleep(5)
            }
            if await !DatabaseService.shared.hasAccount() {
                do {
                    try await DatabaseService.shared.createAccount()
                } catch {
                    print(error.localizedDescription)
                }
            }
            do {
                let account = try await DatabaseService.shared.fetchAccount()
                try GameManager.shared.changeAccount(to: account)
                _ = await wait.result
                
                await MainActor.run {
                    let gameViewController = ApiaryViewController(frame: window.frame)
                    navigationController.setViewControllers([gameViewController], animated: false)
                }
            } catch {
                print(error)
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

