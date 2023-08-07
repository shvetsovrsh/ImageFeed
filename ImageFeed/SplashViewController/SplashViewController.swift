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

    private let splashScreenLogo = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showSplashScreen()
        if let token = oauth2TokenStorage.token {
            fetchProfile(token: token)
        } else {
            showAuthController()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}

extension SplashViewController {
    private func showSplashScreen() {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.1019607843, green: 0.1058823529, blue: 0.1333333333, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view = view

        splashScreenLogo.image = UIImage(named: "splash_screen_logo")
        splashScreenLogo.contentMode = .scaleAspectFit
        splashScreenLogo.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(splashScreenLogo)

        NSLayoutConstraint.activate([
            splashScreenLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashScreenLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func showAuthController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController")
        guard let authViewController = viewController as? AuthViewController else {
            return
        }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            showAlertViewController()
            assertionFailure("Invalid Configuration")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else {
                return
            }
            self.fetchOAuthToken(code)
        }
        UIBlockingProgressHUD.show()
    }

    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                switch result {
                case .success(let token):
                    self.fetchProfile(token: token)
                case .failure(let error):
                    print("Failed to fetch token: \(error)")
                    self.showAlertViewController()
                    break
                }
                UIBlockingProgressHUD.dismiss()
            }
        }
    }

    private func fetchProfile(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                switch result {
                case .success(let profile):
                    self.userProfile = profile
                    self.profileImageService.fetchProfileImageURL(username: profile.username) { [weak self] result in
                    }
                    self.switchToTabBarController()
                case .failure(let error):
                    print("Failed to fetch profile: \(error)")
                    self.showAlertViewController()
                    break
                }
                UIBlockingProgressHUD.dismiss()
            }
        }
    }

    private func showAlertViewController() {
        let alertController = UIAlertController(title: "Что-то пошло не так",
                message: "Не удалось загрузить профиль", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
