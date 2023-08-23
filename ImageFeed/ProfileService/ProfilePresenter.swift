//
// Created by Ruslan S. Shvetsov on 22.08.2023.
//

import UIKit

protocol ProfilePresenterProtocol {
    func viewDidLoad()
    func didUpdateProfileImage()
    func didTapLogout()
    var view: ProfileViewControllerProtocol? { get set }
}

class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    let profileService: ProfileService
    let profileHelper: ProfileHelperProtocol

    init(profileService: ProfileService, profileHelper: ProfileHelperProtocol) {
        self.profileService = profileService
        self.profileHelper = profileHelper
    }

    func viewDidLoad() {
        setupProfileDetails()
        setupProfileImageObserver()
    }

    private func setupProfileImageObserver() {
        profileHelper.updateAvatar(imageView: view?.avatarImageView ?? UIImageView())
        view?.startListeningForProfileImageChanges { [weak self] in
            self?.didUpdateProfileImage()
        }
    }

    func didUpdateProfileImage() {
        profileHelper.updateAvatar(imageView: view?.avatarImageView ?? UIImageView())
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
