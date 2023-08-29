//
// Created by Ruslan S. Shvetsov on 09.04.2023.
//

import UIKit
import Kingfisher

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get }
    func updateProfileDetails(profile: Profile)
    func showAuthController()
    var avatarImageView: UIImageView { get }
    func updateProfileAvatar(avatar: UIImage)
    func startListeningForProfileImageChanges(completion: @escaping () -> Void)
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?

    private let profileService = ProfileService.shared
    private let tokenStorage = OAuth2TokenStorage()
    private let profileHelper = ProfileHelper()
    private let profileImageService = ProfileImageService.shared
    private var profile: Profile = .standard
    private var profileImageServiceObserver: NSObjectProtocol?
    private var nameLabel: UILabel!
    private var loginNameLabel: UILabel!
    private var descriptionLabel: UILabel!
    internal var avatarImageView = UIImageView()
    private var logoutButton: UIButton!

    @objc
    private func didTapLogoutButton() {
        showAlertViewController()
    }

    func updateProfileDetails(profile: Profile) {
        self.profile = profile
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()

        if presenter == nil {
            presenter = ProfilePresenter(
                    profileService: profileService,
                    profileHelper: profileHelper,
                    profileImageService: profileImageService
            )
        }

        presenter?.view = self
        presenter?.viewDidLoad()
    }

    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        self.presenter?.view = self
    }

    func startListeningForProfileImageChanges(completion: @escaping () -> Void) {
        NotificationCenter.default.addObserver(forName: ProfileImageService.DidChangeNotification, object: nil, queue: .main) { [weak self] _ in
            completion()
        }
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
        nameLabel.accessibilityIdentifier = "nameLabel"
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
        loginNameLabel.accessibilityIdentifier = "loginNameLabel"
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

    internal func updateProfileAvatar(avatar: UIImage) {
        avatarImageView.image = avatar
    }

    private func showAlertViewController() {
        let alertController = UIAlertController(title: "Пока, Пока!", message: "Уверены, что хотите выйти?",
                preferredStyle: .alert)

        let logoutAction = UIAlertAction(title: "Да", style: .default) { [self] _ in
            profileService.logout()
            showAuthController()
        }
        logoutAction.accessibilityIdentifier = "logoutAction"
        alertController.addAction(logoutAction)
        alertController.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: nil))

        present(alertController, animated: true, completion: nil)
    }

    internal func showAuthController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController")
        guard let authViewController = viewController as? AuthViewController else {
            return
        }

        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
}
