//
// Created by Ruslan S. Shvetsov on 19.07.2023.
//

import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")

    private let oauth2TokenStorage = OAuth2TokenStorage()
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private (set) var avatarURL: String?
    private var lastUsername: String?

    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastUsername == username {
            return
        }
        guard let token = oauth2TokenStorage.token else {
            return
        }
        task?.cancel()
        lastUsername = username
        let request = profileImageRequest(token, username)
        logRequest(request)

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let profileImageResult):
                if let profileImage = profileImageResult.profile_image {
                    let avatarImage = AvatarImage(profileImage: profileImage)
                    self?.avatarURL = avatarImage.medium?.absoluteString
                    DispatchQueue.main.async {
                        completion(.success(self?.avatarURL ?? ""))
                        NotificationCenter.default.post(
                                name: ProfileImageService.DidChangeNotification,
                                object: self,
                                userInfo: ["URL": self?.avatarURL])
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        self.task = task
        task.resume()
    }

    private func profileImageRequest(_ token: String, _ username: String) -> URLRequest {
        var request = URLRequest(url: URL(string: "https://api.unsplash.com/users/\(username)")!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
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
