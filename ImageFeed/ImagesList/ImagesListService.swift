//
// Created by Ruslan S. Shvetsov on 16.08.2023.
//

import Foundation
import Kingfisher

final class ImagesListService {
    private let urlSession = URLSession.shared
    private (set) var photos: [Photo] = []
    private let oauth2TokenStorage = OAuth2TokenStorage()
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private var lastLoadedPage: Int?
    private let dateFormatter = ISO8601DateFormatter()

    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        guard let token = oauth2TokenStorage.token else {
            return
        }
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        let request = photosRequest(token, nextPage)

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            switch result {
            case .success(let photoResults):
                for photoResult in photoResults {
                    if let newPhoto = self?.createPhoto(photoResult) {
                        self?.photos.append(newPhoto)
                    }
                }
                DispatchQueue.main.async {
                    self?.lastLoadedPage = nextPage
                    NotificationCenter.default.post(
                            name: ImagesListService.DidChangeNotification,
                            object: nil)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print(error)
                }
            }
        }
        task.resume()
    }

    private func photosRequest(_ token: String, _ nextPage: Int) -> URLRequest {
        var request = URLRequest(url: URL(string: "https://api.unsplash.com/photos")!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue(String(nextPage), forHTTPHeaderField: "page")
        return request
    }

    private func createPhoto(_ photoResult: PhotoResult) -> Photo {
        let createdAt = photoResult.createdAt ?? ""
        return Photo(
                id: photoResult.id,
                size: CGSize(width: photoResult.width, height: photoResult.height),
                createdAt: dateFormatter.date(from: createdAt),
                welcomeDescription: photoResult.description,
                thumbImageURL: photoResult.urls.thumb,
                largeImageURL: photoResult.urls.full,
                isLiked: photoResult.likedByUser
        )
    }
}

struct UrlsResult: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct UserLinksResult: Codable {
    let selfLink: String
    let html: String
    let photos: String
    let likes: String
    let portfolio: String
}

struct CollectionResult: Codable {
    let id: Int
    let title: String
    let publishedAt: String
    let lastCollectedAt: String
    let updatedAt: String
    let coverPhoto: String?
    let user: String?
}

struct PhotoResult: Codable {
    let id: String
    let createdAt: String
    let updatedSt: String
    let width: Int
    let height: Int
    let color: String
    let blurHash: String
    let likes: Int
    let likedByUser: Bool
    let description: String?
    let user: UserResult
    let currentUserCollections: [CollectionResult]
    let urls: UrlsResult
    let links: PhotoLinksResult
}

struct PhotoLinksResult: Codable {
    let selfLink: String
    let html: String
    let download: String
    let download_location: String
}

struct Photo: Codable {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}
