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
        guard let token = oauth2TokenStorage.token else {return}
        task?.cancel()
        lastUsername = username
        let request = profileImageRequest(token, username)
        logRequest(request)
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(ProfileError.emptyResponse))
                return
            }
            do {
                self?.logResponse(data, response: response, error: error)
                let profileImageResult = try JSONDecoder().decode(UserResult.self, from: data)
                let profileImage = AvatarImage(profileImage: profileImageResult.profile_image)
                self?.avatarURL = profileImage.small.absoluteString
                print(self?.avatarURL) //TODO
                completion(.success(self?.avatarURL ?? ""))
            } catch {
                completion(.failure(error))
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

    private func logResponse(_ data: Data?, response: URLResponse?, error: Error?) {
        if let httpResponse = response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            print("Response Status Code: \(statusCode)")
        }

        if let error = error {
            print("Error: \(error)")
        }

        if let data = data {
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response JSON: \(jsonString)")
            } else {
                print("Failed to convert data to UTF-8 string")
            }
        } else {
            print("Response data is nil")
        }
    }

}

struct UserResult: Codable {
    let id: String
    let updated_at: String
    let username: String
    let name: String
    let first_name: String
    let last_name: String
    let twitter_username: String?
    let portfolio_url: URL?
    let bio: String?
    let location: String?
    let links: ProfileLinks
    let profile_image: ProfileImage
    let instagram_username: String?
    let total_collections: Int
    let total_likes: Int
    let total_photos: Int
    let accepted_tos: Bool
    let for_hire: Bool
    let social: Social
    let followed_by_user: Bool
    let photos: [Photo]
    let badge: String?
    let tags: Tags
    let followers_count: Int
    let following_count: Int
    let allow_messages: Bool
    let numeric_id: Int
    let downloads: Int
    let meta: Meta
}

struct ProfileLinks: Codable {
    let selfURL: URL
    let html: URL
    let photos: URL
    let likes: URL
    let portfolio: URL
    let following: URL
    let followers: URL

    private enum CodingKeys: String, CodingKey {
        case selfURL = "self"
        case html
        case photos
        case likes
        case portfolio
        case following
        case followers
    }
}

struct ProfileImage: Codable {
    let small: URL
    let medium: URL
    let large: URL
}

struct Social: Codable {
    let instagramUsername: String?
    let portfolioURL: URL?
    let twitterUsername: String?
    let paypalEmail: String?
}

struct Photo: Codable {

}

struct Tags: Codable {
    let custom: [String]
    let aggregated: [String]
}

struct Meta: Codable {
    let index: Bool
}

struct AvatarImage {
    let small: URL
    let medium: URL
    let large: URL

    init(profileImage: ProfileImage) {
        small = profileImage.small
        medium = profileImage.medium
        large = profileImage.large
    }
}
