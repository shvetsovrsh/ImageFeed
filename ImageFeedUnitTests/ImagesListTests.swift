//
// Created by Ruslan S. Shvetsov on 27.08.2023.
//

import XCTest
@testable import ImageFeed

class ImagesListTests: XCTestCase {
    func testInit() {
        var presenter: ImagesListPresenter
        var view = ImagesListViewController()
        var imagesListService = MockImagesListService()

        presenter = ImagesListPresenter(viewController: view, imagesListService: imagesListService)

        XCTAssertNotNil(presenter)
    }

    func testFetchPhotosNextPage() {
        var viewController = ImagesListViewController()
        var imagesListService = MockImagesListService()
        let presenter = ImagesListPresenter(viewController: viewController,
                imagesListService: imagesListService)

        presenter.fetchPhotosNextPage()

        XCTAssertTrue(imagesListService.fetchPhotosNextPageCalled)
    }
}