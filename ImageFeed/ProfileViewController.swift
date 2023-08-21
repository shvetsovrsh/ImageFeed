//
// Created by Ruslan S. Shvetsov on 09.04.2023.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private let profileService = ProfileService.shared
    private let tokenStorage = OAuth2TokenStorage()
    private var profile: Profile = Profile(
            username: "ekaterina_nov",
            name: "Екатерина Новикова",
            loginName: "@ekaterina_nov",
            bio: "Hello, World!"
    )
    private var profileImageServiceObserver: NSObjectProtocol?
    private var nameLabel: UILabel!
    private var loginNameLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var avatarImageView = UIImageView()
    private var logoutButton: UIButton!

    @objc
    private func didTapLogoutButton() {
        showAlertViewController()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()

        if let profile = profileService.profile {
            self.profile = profile
            updateProfileDetails(with: profile)
        }

        profileImageServiceObserver = NotificationCenter.default
                .addObserver(
                        forName: ProfileImageService.DidChangeNotification,
                        object: nil,
                        queue: .main
                ) { [weak self] _ in
                    guard let self = self else {
                        return
                    }
                    self.updateAvatar(imageView: self.avatarImageView)
                }
        updateAvatar(imageView: avatarImageView)
    }

    private func setupViews() {
        createAvatarImage(safeArea: view.safeAreaLayoutGuide)
        createNameLabel(safeArea: view.safeAreaLayoutGuide)
        createLoginNameLabel(safeArea: view.safeAreaLayoutGuide)
        createDescriptionLabel(safeArea: view.safeAreaLayoutGuide)
        createLogoutButton(safeArea: view.safeAreaLayoutGuide)
    }

    private func createAvatarImage(safeArea: UILayoutGuide) {
        avatarImageView = UIImageView()
        avatarImageView.image = UIImage(named: "placeholder.png")
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true

        avatarImageView.layer.cornerRadius = 35
        avatarImageView.layer.masksToBounds = true
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(avatarImageView)
        avatarImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        avatarImageView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 32).isActive = true
        avatarImageView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16).isActive = true

    }

    private func createNameLabel(safeArea: UILayoutGuide) {
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = profile.name
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.textColor = .white
        view.addSubview(nameLabel)

        nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8).isActive = true
    }

    private func createLoginNameLabel(safeArea: UILayoutGuide) {
        loginNameLabel = UILabel()
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        loginNameLabel.text = profile.loginName
        loginNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        loginNameLabel.textColor = .gray
        view.addSubview(loginNameLabel)

        loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
    }

    private func createDescriptionLabel(safeArea: UILayoutGuide) {
        descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = profile.bio
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = .white
        view.addSubview(descriptionLabel)

        descriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8).isActive = true
    }

    private func createLogoutButton(safeArea: UILayoutGuide) {
        let logoutButton = UIButton()
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.setTitle("", for: .normal)
        logoutButton.setImage(UIImage(named: "logout_button"), for: .normal)
        logoutButton.accessibilityIdentifier = "LogoutButton"
        logoutButton.imageView?.contentMode = .scaleAspectFill
        logoutButton.addTarget(nil, action: #selector(didTapLogoutButton), for: .touchUpInside)
        logoutButton.tintColor = .red
        view.addSubview(logoutButton)

        logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor).isActive = true
        logoutButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -26).isActive = true
        self.logoutButton = logoutButton
    }

    private func updateAvatar(imageView: UIImageView) {
        guard
                let profileImageURL = ProfileImageService.shared.avatarURL,
                let url = URL(string: profileImageURL)
        else {
            return
        }
        print("updateAvatar to profileImageURL \(url)")
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url,
                placeholder: UIImage(named: "placeholder.png"),
                options: [.processor(processor)]) { result in

            switch result {
            case .success(let value):
                print(value.image)
                print(value.cacheType)
                print(value.source)
            case .failure(let error):
                print(error)
            }
        }
    }

    private func updateProfileDetails(with profile: Profile) {
        self.profile = profile
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }

    private func showAlertViewController() {
        let alertController = UIAlertController(title: "Пока, Пока!", message: "Уверены, что хотите выйти?",
                preferredStyle: .alert)

        let logoutAction = UIAlertAction(title: "Да", style: .default) { [self] _ in
            profileService.logout()
            showAuthController()
        }
        alertController.addAction(logoutAction)
        alertController.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: nil))

        present(alertController, animated: true, completion: nil)
    }

    private func showAuthController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController")
        guard let authViewController = viewController as? AuthViewController else {
            return
        }

        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
}
