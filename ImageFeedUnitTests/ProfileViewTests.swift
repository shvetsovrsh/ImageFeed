//
// Created by Ruslan S. Shvetsov on 26.08.2023.
//

@testable import ImageFeed
import XCTest

final class ProfileViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewController()
        viewController.configure(presenter)

        //when
        _ = viewController.view

        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testUpdateAvatar() {
        let profileService = MockProfileService()
        let profileImageService = MockProfileServiceImage()
        let profileHelper = MockProfileHelper()

        let profilePresenter = ProfilePresenter(
                profileService: profileService,
                profileHelper: profileHelper,
                profileImageService: profileImageService
        )

        let profileViewControllerSpy = ProfileViewControllerSpy(presenter: profilePresenter)
        profilePresenter.view = profileViewControllerSpy

        let expectation = XCTestExpectation(description: "Update avatar")

        profilePresenter.viewDidLoad()

        profileImageService.fetchProfileImageURL(username: "successUsername") { result in

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {

                XCTAssertTrue(profileViewControllerSpy.avatarImageView.image != nil)
                XCTAssertTrue(profileViewControllerSpy.avatarImageView.image == UIImage(named: "me.png"))
                print(profileViewControllerSpy.avatarImageView.image)

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }
}
