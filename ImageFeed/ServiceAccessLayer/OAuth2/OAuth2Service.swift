//
// Created by Ruslan S. Shvetsov on 12.06.2023.
//

import Foundation

final class OAuth2Service {
    private var task: URLSessionTask?
    private var lastCode: String?
    static let shared = OAuth2Service()
    private let urlSession = URLSession.shared
    private (set) var authToken: String? {
        get {
            OAuth2TokenStorage().token
        }
        set {
            OAuth2TokenStorage().token = newValue
        }
    }


    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastCode == code {
            return
        }
        task?.cancel()
        lastCode = code
        let request = authTokenRequest(code: code)
        let task = object(for: request) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                switch result {
                case .success(let body):
                    let authToken = body.accessToken
                    self.authToken = authToken
                    completion(.success(authToken))
                    self.task = nil
                case .failure(let error):
                    completion(.failure(error))
                    self.lastCode = nil
                }
            }
        }
        self.task = task
        task.resume()
    }
}

private extension OAuth2Service {

    private func object(
            for request: URLRequest,
            completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void
    ) -> URLSessionTask {
        urlSession.objectTask(for: request, completion: completion)
    }

    private func authTokenRequest(code: String) -> URLRequest {
        URLRequest.makeHTTPRequest(
                path: "/oauth/token"
                        + "?client_id=\(AccessKey)"
                        + "&&client_secret=\(SecretKey)"
                        + "&&redirect_uri=\(RedirectURI)"
                        + "&&code=\(code)"
                        + "&&grant_type=authorization_code",
                httpMethod: "POST",
                baseURL: URL(string: "https://unsplash.com")!
        )
    }

    private struct OAuthTokenResponseBody: Decodable {
        let accessToken: String
        let tokenType: String
        let scope: String
        let createdAt: Int

        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case tokenType = "token_type"
            case scope
            case createdAt = "created_at"
        }
    }
}

// MARK: - HTTP Request

extension URLRequest {
    static func makeHTTPRequest(
            path: String,
            httpMethod: String,
            baseURL: URL = DefaultBaseURL
    ) -> URLRequest {
        var request = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
        request.httpMethod = httpMethod
        return request
    }
}

// MARK: - Network Connection

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
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

    func objectTask<T: Decodable>(
            for request: URLRequest,
            completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletion: (Result<T, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        let task = dataTask(with: request, completionHandler: { [self] data, response, error in
            if let data = data,
               let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode {
                logResponse(data, response: response, error: error)
                if 200..<300 ~= statusCode {
                    do {
                        let decodedObject = try JSONDecoder().decode(T.self, from: data)
                        fulfillCompletion(.success(decodedObject))
                    } catch {
                        fulfillCompletion(.failure(error))
                    }
                } else {
                    fulfillCompletion(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletion(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletion(.failure(NetworkError.urlSessionError))
            }
        })
        task.resume()
        return task
    }
}