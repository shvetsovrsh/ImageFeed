//
// Created by Ruslan S. Shvetsov on 18.06.2023.
//

import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private var lastToken: String?

    private(set) var profile: Profile?

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastToken == token {
            return
        }
        task?.cancel()
        lastToken = token
        let request = profileRequest(token)
        logRequest(request)
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let profileResult):
                let profile = Profile(profileResult: profileResult)
                self?.profile = profile
                DispatchQueue.main.async {
                    completion(.success(profile))
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

    private func profileRequest(_ token: String) -> URLRequest {
        var request = URLRequest(url: URL(string: "https://api.unsplash.com/me")!)
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

enum ProfileError: Error {
    case emptyResponse
}

struct ProfileResult: Codable {
    let id: String?
    let updated_at: String?
    let username: String?
    let name: String?
    let first_name: String?
    let last_name: String?
    let twitter_username: String?
    let portfolio_url: URL?
    let bio: String?
    let location: String?
    let links: ProfileLinks?
    let profile_image: ProfileImage?
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
    let uid: String
    let confirmed: Bool
    let uploads_remaining: Int
    let unlimited_uploads: Bool
    let email: String
    let dmca_verification: String
    let unread_in_app_notifications: Bool
    let unread_highlight_notifications: Bool

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
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String

    init(profileResult: ProfileResult) {
        username = profileResult.username ?? ""
        name = "\(profileResult.first_name ?? "") \(profileResult.last_name ?? "")"
        loginName = "@\(profileResult.username ?? "")"
        bio = profileResult.bio ?? ""
    }

    init(username: String, name: String, loginName: String, bio: String) {
        self.username = username
        self.name = name
        self.loginName = loginName
        self.bio = bio
    }
}
