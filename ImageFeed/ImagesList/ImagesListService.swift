//
// Created by Ruslan S. Shvetsov on 16.08.2023.
//

import Foundation

final class ImagesListService {
    private let urlSession = URLSession.shared
    private (set) var photos: [Photo] = []
    private let oauth2TokenStorage = OAuth2TokenStorage()
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private var lastLoadedPage: Int?
    private let dateFormatter = ISO8601DateFormatter()
    private var isFetching = false
    private var task: URLSessionTask?


    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        guard task == nil else {
            print("Fetching in progress. Cannot start a new request.")
            return
        }

        if isFetching {
            print("Fetching in progress. Cannot start a new request.")
            return
        }

        isFetching = true

        guard let token = oauth2TokenStorage.token else {
            return
        }
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        let request = photosRequest(token, nextPage)

        let dataTask = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            defer {
                self?.isFetching = false
                self?.task = nil
            }
            DispatchQueue.main.async {
                switch result {
                case .success(let photoResults):
                    for photoResult in photoResults {
                        if let newPhoto = self?.createPhoto(photoResult) {
                            self?.photos.append(newPhoto)
                        }
                    }
                    self?.lastLoadedPage = nextPage
                    NotificationCenter.default.post(
                            name: ImagesListService.DidChangeNotification,
                            object: nil)

                case .failure(let error):
                    print(error)
                }
            }
        }
        task = dataTask
        task?.resume()
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

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard let token = oauth2TokenStorage.token else {
            return
        }
        let request = likeRequest(token, photoId, isLike)
        logRequest(request)
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<LikeResult, Error>) in
            guard let self = self else {
                return
            }
            switch result {
            case .success:
                DispatchQueue.main.async {
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let photo = self.photos[index]
                        let newPhoto = Photo(
                                id: photo.id,
                                size: photo.size,
                                createdAt: photo.createdAt,
                                welcomeDescription: photo.welcomeDescription,
                                thumbImageURL: photo.thumbImageURL,
                                largeImageURL: photo.largeImageURL,
                                isLiked: !photo.isLiked
                        )
                        self.photos[index] = newPhoto
                        completion(.success(()))
                    }
                }
            case .failure(let error):
                print("changeLike error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }

    private func likeRequest(_ token: String, _ photoId: String, _ isLike: Bool) -> URLRequest {
        let urlComponents = URLComponents(string: "https://api.unsplash.com/photos/\(photoId)/like")!
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        logRequest(request)
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
