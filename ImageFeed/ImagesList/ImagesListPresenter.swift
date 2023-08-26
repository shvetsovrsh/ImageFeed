//
// Created by Ruslan S. Shvetsov on 26.08.2023.
//

import UIKit

protocol ImagesListPresenterProtocol: AnyObject {
    var photos: [Photo] {get}
    var view: ImagesListViewControllerProtocol? { get set }
    func fetchPhotosNextPage()
    func updateTableView()
    func togglePhotoLikeStatus(at index: Int, completion: @escaping (Bool) -> Void)
}

class ImagesListPresenter: ImagesListPresenterProtocol {
    private (set) var photos: [Photo] = []
    var view: ImagesListViewControllerProtocol?
    private let imagesListService = ImagesListService()

    init(viewController: ImagesListViewControllerProtocol) {
        view = viewController
        setupImagesListServiceObserver()
    }

    func fetchPhotosNextPage() {
        imagesListService.fetchPhotosNextPage()
    }

    private func setupImagesListServiceObserver() {
        NotificationCenter.default.addObserver(
                forName: ImagesListService.DidChangeNotification,
                object: nil,
                queue: .main) { [ weak self] _ in
            self?.updateTableView()
        }
    }

    func updateTableView() {
        DispatchQueue.main.async {
            let oldCount = self.photos.count
            let newCount = self.imagesListService.photos.count
            self.photos = self.imagesListService.photos
            self.view?.updateTableViewAnimated(from: oldCount, to: newCount)
        }
    }

    func togglePhotoLikeStatus(at index: Int, completion: @escaping (Bool) -> Void) {
        guard index < photos.count else {
            return
        }

        let photo = photos[index]
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.photos = self.imagesListService.photos
                    completion(true)
                }
            case .failure(_):
                completion(false)
            }
        }
    }
}
