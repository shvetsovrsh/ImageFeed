//
// Created by Ruslan S. Shvetsov on 22.08.2023.
//

import UIKit

public protocol ProfilePresenterProtocol {
    /// Notifies the presenter to update the profile avatar.
    func updateAvatar()

    /// Notifies the presenter that the view has loaded.
    func viewDidLoad()

    /// Notifies the presenter that the profile image has been updated.
    func didUpdateProfileImage()

    /// Notifies the presenter that the user tapped the logout button.
    func didTapLogout()

    /// The view associated with the presenter.
    var view: ProfileViewControllerProtocol? { get set }
}

class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    let profileService: ProfileServiceProtocol
    let profileHelper: ProfileHelperProtocol
    let profileImageService: ProfileImageServiceProtocol

    init(profileService: ProfileServiceProtocol,
         profileHelper: ProfileHelperProtocol,
         profileImageService: ProfileImageServiceProtocol) {
        self.profileService = profileService
        self.profileHelper = profileHelper
        self.profileImageService = profileImageService
    }

    func viewDidLoad() {
        setupProfileDetails()
        setupProfileImageObserver()
    }

    private func setupProfileImageObserver() {
        updateAvatar()
        view?.startListeningForProfileImageChanges { [weak self] in
            self?.didUpdateProfileImage()
        }
    }

    func updateAvatar() {
        guard
                let profileImageURL = profileImageService.avatarURL,
                let url = URL(string: profileImageURL)
        else {
            return
        }
        profileHelper.fetchImage(url: url, options: nil) { [weak self] result in
            guard let self else {
                return
            }
            switch result {
            case .success(let avatarImage):
                print("updateAvatar to profileImageURL \(url)")
                self.view?.updateProfileAvatar(avatar: avatarImage)
            case .failure(_):
                print("error updating avatar to profileImageURL \(url)")
                if let placeholderImage = UIImage(named: "placeholder.png") {
                    self.view?.updateProfileAvatar(avatar: placeholderImage)
                }
            }
        }
    }

    func didUpdateProfileImage() {
        updateAvatar()
    }

    private func setupProfileDetails() {
        if let profile = profileService.profile {
            view?.updateProfileDetails(profile: profile)
        }
    }

    func didTapLogout() {
        profileService.logout()
        view?.showAuthController()
    }
}
