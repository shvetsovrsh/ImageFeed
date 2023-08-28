//
// Created by Ruslan S. Shvetsov on 26.08.2023.
//

import ImageFeed
import Foundation

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var updateAvatarCalled: Bool = false
    var updateProfileImageCalled: Bool = false
    var view: ProfileViewControllerProtocol?

    func updateAvatar() {
        updateAvatarCalled = true
    }

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didUpdateProfileImage() {
        updateProfileImageCalled = true
    }

    func didTapLogout() {
    }
}