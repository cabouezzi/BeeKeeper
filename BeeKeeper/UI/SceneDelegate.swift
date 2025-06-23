//
//  SceneDelegate.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 10/8/23.
//

import UIKit
import SwiftUI
import SceneKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        // If they haven’t accepted, show the T&C view and bail out
        if !SettingsManager.shared.hasAcceptedTerms {
            let tosView = TermsAndConditionsView {
                SettingsManager.shared.hasAcceptedTerms = true
                self.launchFlow(window)
            }
            
            window.rootViewController = UIHostingController(rootView: tosView)
            window.makeKeyAndVisible()
            return
        }
        
        launchFlow(window)
    }
    
    func launchFlow(_ window: UIWindow) {
        let launchView = LaunchView(frame: window.frame)
        let launchViewController = UIViewController(nibName: nil, bundle: nil)
        launchViewController.view = launchView
        
        let navigationController = UINavigationController()
        navigationController.pushViewController(launchViewController, animated: false)
        navigationController.modalPresentationStyle = .none
        navigationController.isNavigationBarHidden = true
        
        self.window = window
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        Task.detached {
            let loadSingletons = Task {
                _ = SFXManager.shared
                _ = GameManager.shared
                _ = SettingsManager.shared
                _ = DatabaseService.shared
                _ = EvolutionResearchManager.shared
            }
            
            let loadAccount = Task {
                let account: Account
                let vctype: ApiaryViewController.Type
                if await !DatabaseService.shared.hasAccount() || SettingsManager.shared.isFirstLogin {
                    do {
                        try await DatabaseService.shared.createAccount()
                    } catch {
                        print(error.localizedDescription)
                    }
                    vctype = TutorialViewController.self
                } else {
                    do {
                        let account = try await DatabaseService.shared.fetchAccount()
                        try GameManager.shared.changeAccount(to: account)
                    } catch {
                        print(error.localizedDescription)
                    }
                    vctype = ApiaryViewController.self
                }
                return vctype
            }
            
            _ = await loadSingletons.result
            await launchView.progress.setProgress(0.2, animated: true)
            
            let ViewController = await loadAccount.result.get()
            await launchView.progress.setProgress(0.8, animated: true)
            let gameViewController = await ViewController.init(frame: window.frame)
            await launchView.progress.setProgress(1, animated: true)
            
            // Pause on load completion
            sleep(1)
            
            await MainActor.run {
                navigationController.setViewControllers([gameViewController], animated: false)
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

