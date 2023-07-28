//
// Created by Ruslan S. Shvetsov on 12.06.2023.
//

import Foundation
import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"

    private let oauth2Service = OAuth2Service()
    private let oauth2TokenStorage = OAuth2TokenStorage()

    private var userProfile: Profile?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let token = oauth2TokenStorage.token {
            fetchProfile(token: token)
        } else {
            // Show Auth Screen
            performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
            guard
                    let navigationController = segue.destination as? UINavigationController,
                    let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                fatalError("Failed to prepare for \(ShowAuthenticationScreenSegueIdentifier)")
            }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        dismiss(animated: true) { [weak self] in
            guard let self = self else {
                return
            }
            self.fetchOAuthToken(code)
            if let token = self.oauth2TokenStorage.token {
                self.fetchProfile(token: token)
            }
        }
    }

    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success:
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                print("Failed to fetch token: \(error)")
                let alertController = UIAlertController(title: "Что-то пошло не так", message: "Не удалось войти в систему", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                break
            }
        }
    }

    private func fetchProfile(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let profile):
                self.userProfile = profile
                self.profileImageService.fetchProfileImageURL(username: profile.username) { [weak self] result in

                }
                UIBlockingProgressHUD.dismiss()
                self.switchToTabBarController()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                print("Failed to fetch profile: \(error)")
                let alertController = UIAlertController(title: "Что-то пошло не так", message: "Не удалось загрузить профиль", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                break
            }
        }
    }
}
