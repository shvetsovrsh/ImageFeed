//
// Created by Ruslan S. Shvetsov on 27.08.2023.
//

import Foundation
@testable import ImageFeed

class MockImagesListService: ImagesListServiceProtocol {
    var photos: [ImageFeed.Photo] = []
    var fetchPhotosNextPageCalled: Bool = false

    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
    }
}
