//
// Created by Ruslan S. Shvetsov on 09.04.2023.
//

import UIKit

final class ProfileViewController: UIViewController {
    private let profileService = ProfileService.shared
    private let tokenStorage = OAuth2TokenStorage()
    private var profile: Profile = Profile(
            username: "ekaterina_nov",
            name: "Екатерина Новикова",
            loginName: "@ekaterina_nov",
            bio: "Hello, World!"
    )

    private var nameLabel: UILabel!
    private var loginNameLabel: UILabel!
    private var descriptionLabel: UILabel!

    @objc
    private func didTapLogoutButton() {

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        if let profile = profileService.profile {
            self.profile = profile
            updateProfileDetails(with: profile)
        }
    }

    private func updateProfileDetails(with profile: Profile) {
        self.profile = profile
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }


    private func setupViews() {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.1019607843, green: 0.1058823529, blue: 0.1333333333, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view = view

        let avatarImageView = UIImageView()
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = 35
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.image = UIImage(named: "avatar")
        view.addSubview(avatarImageView)

        nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        nameLabel.textColor = UIColor(white: 1, alpha: 1)
        nameLabel.textAlignment = .natural
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.numberOfLines = 0
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = profile.name
        view.addSubview(nameLabel)

        loginNameLabel = UILabel()
        loginNameLabel.font = UIFont.systemFont(ofSize: 13)
        loginNameLabel.textColor = UIColor(red: 0.6823529412, green: 0.6862745098, blue: 0.7058823529, alpha: 1)
        loginNameLabel.textAlignment = .natural
        loginNameLabel.lineBreakMode = .byTruncatingTail
        loginNameLabel.adjustsFontSizeToFitWidth = false
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        loginNameLabel.text = profile.loginName
        view.addSubview(loginNameLabel)

        descriptionLabel = UILabel()
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.textColor = UIColor(white: 1, alpha: 1)
        descriptionLabel.textAlignment = .natural
        descriptionLabel.lineBreakMode = .byTruncatingTail
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = profile.bio
        view.addSubview(descriptionLabel)

        let logoutButton = UIButton()
        logoutButton.contentMode = .scaleToFill
        logoutButton.contentHorizontalAlignment = .center
        logoutButton.contentVerticalAlignment = .center
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.setImage(UIImage(named: "logout_button"), for: .normal)
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        view.addSubview(logoutButton)

        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),

            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 55),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.leadingAnchor.constraint(greaterThanOrEqualTo: avatarImageView.trailingAnchor, constant: 265),
            logoutButton.widthAnchor.constraint(equalToConstant: 24),
            logoutButton.heightAnchor.constraint(equalToConstant: 24),

            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),

            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),

            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
        ])
    }
}
