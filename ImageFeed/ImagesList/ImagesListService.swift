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
                DispatchQueue.main.async {
                    for photoResult in photoResults {
                        if let newPhoto = self?.createPhoto(photoResult) {
                            self?.photos.append(newPhoto)
                        }
                    }
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
        var urlComponents = URLComponents(string: "https://api.unsplash.com/photos")!
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
