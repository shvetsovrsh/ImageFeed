//
// Created by Ruslan S. Shvetsov on 16.08.2023.
//

import Foundation
import Kingfisher

final class ImagesListService {
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private (set) var photos: [Photo] = []
    private let oauth2TokenStorage = OAuth2TokenStorage()
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private var lastLoadedPage: Int?
    private let dateFormatter = ISO8601DateFormatter()

    func fetchPhotosNextPage() {
        guard task == nil else {return}
        assert(Thread.isMainThread)
        guard let token = oauth2TokenStorage.token else {
            return
        }
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        let request = photosRequest(token, nextPage)

        let dataTask = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            switch result {
            case .success(let photoResults):
                DispatchQueue.main.async {
                    for photoResult in photoResults {
                        if let newPhoto = self?.createPhoto(photoResult) {
                            self?.photos.append(newPhoto)
                        }
                    }
                    self?.lastLoadedPage = nextPage
                    self?.task = nil
                    NotificationCenter.default.post(
                            name: ImagesListService.DidChangeNotification,
                            object: nil)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print(error)
                    self?.task = nil
                }
            }
        }
        task = dataTask
        task?.resume()
    }

    private func photosRequest(_ token: String, _ nextPage: Int) -> URLRequest {
        let baseUrlString = "https://api.unsplash.com/photos"
        var urlComponents = URLComponents(string: baseUrlString)!
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(nextPage))
        ]
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        logRequest(request)
        return request
    }

    private func createPhoto(_ photoResult: PhotoResult) -> Photo {
        let createdAt = photoResult.created_at ?? ""
        return Photo(
                id: photoResult.id,
                size: CGSize(width: photoResult.width, height: photoResult.height),
                createdAt: dateFormatter.date(from: createdAt),
                welcomeDescription: photoResult.description,
                thumbImageURL: photoResult.urls.thumb,
                largeImageURL: photoResult.urls.full,
                isLiked: photoResult.liked_by_user
        )
    }

    private func logRequest(_ request: URLRequest) {
        if let httpMethod = request.httpMethod, let url = request.url {
            print("Request: \(httpMethod) \(url)")
            if let headers = request.allHTTPHeaderFields {
                print("Headers:")
                for (key, value) in headers {
                    print("\(key): \(value)")
                }
            }
            if let bodyData = request.httpBody, let bodyString = String(data: bodyData, encoding: .utf8) {
                print("Body: \(bodyString)")
            }
        }
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
    let `self`: String
    let html: String
    let photos: String?
    let likes: String
    let portfolio: String
    let following: String
    let followers: String
}

struct CollectionResult: Codable {
    let id: Int
    let title: String
    let published_at: String
    let lastCollected_at: String
    let updated_at: String
    let coverPhoto: String?
    let user: UserResult?
}

struct PhotoResult: Codable {
    let id: String
    let created_at: String
    let updated_at: String
    let width: Int
    let height: Int
    let color: String
    let blur_hash: String
    let likes: Int
    let liked_by_user: Bool
    let description: String?
    let user: UserResult
    let current_user_collections: [CollectionResult]
    let urls: UrlsResult
    let links: PhotoLinksResult
}

struct PhotoLinksResult: Codable {
    let `self`: String
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
