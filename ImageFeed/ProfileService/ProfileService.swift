//
// Created by Ruslan S. Shvetsov on 18.06.2023.
//

import Foundation
import WebKit

final class ProfileService {
    static let shared = ProfileService()
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private var lastToken: String?
    private let oauth2TokenStorage = OAuth2TokenStorage()

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

    static func clean() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }

    func logout() {
        oauth2TokenStorage.token = nil
        ProfileService.clean()
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
