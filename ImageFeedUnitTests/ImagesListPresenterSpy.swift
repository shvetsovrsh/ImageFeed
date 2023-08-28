//
// Created by Ruslan S. Shvetsov on 27.08.2023.
//

import ImageFeed
import Foundation

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var photos: [ImageFeed.Photo] = []

    var view: ImageFeed.ImagesListViewControllerProtocol?

    func fetchPhotosNextPage() {
    }

    func updateTableView() {
    }

    func togglePhotoLikeStatus(at index: Int, completion: @escaping (Bool) -> Void) {
    }
}
