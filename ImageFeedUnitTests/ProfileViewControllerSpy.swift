//
// Created by Ruslan S. Shvetsov on 26.08.2023.
//

@testable import ImageFeed
import UIKit

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ImageFeed.ProfilePresenterProtocol?
    var avatarImageView: UIImageView

    func showAuthController() {

    }


    func startListeningForProfileImageChanges(completion: @escaping () -> Void) {
        NotificationCenter.default.addObserver(forName: MockProfileServiceImage.DidChangeNotification, object: nil, queue: .main) { [weak self] _ in
            completion()
        }
    }

    var updateProfileDetailsCalled: Bool = false
    var updatedProfileDetails: Profile?

    init(presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        avatarImageView = UIImageView()
        self.presenter?.view = self
    }

    func updateProfileDetails(profile: ImageFeed.Profile) {
        updateProfileDetailsCalled = true
        updatedProfileDetails = profile
    }

    func updateProfileAvatar(avatar: UIImage) {
        avatarImageView.image = avatar
    }
}
