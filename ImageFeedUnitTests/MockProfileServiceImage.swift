//
// Created by Ruslan S. Shvetsov on 26.08.2023.
//

import Foundation
import UIKit
@testable import ImageFeed

struct MockImageURLString {
    static let successMockImageURL: String =
            "https://images.unsplash.com/profile-1690571281505-2f517a4d68a6image?ixlib=rb-4.0.3&crop=faces&fit=crop&w=64&h=64"
}

struct MockImageURL {
    static let successMockImageURL = URL(string: MockImageURLString.successMockImageURL)
}

struct MockImage {
    static let successImage = UIImage(named: "me.png")
    static let failedImage = UIImage(named: "placeholder.png")
}

enum MockImageURLError: Error {
    case urlNotFound
}

class MockProfileServiceImage: ProfileImageServiceProtocol {
    var avatarURL: String?
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")


    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        if username == "successUsername" {
            let avatarURL = MockImageURLString.successMockImageURL
            self.avatarURL = avatarURL
            NotificationCenter.default.post(
                    name: MockProfileServiceImage.DidChangeNotification,
                    object: self,
                    userInfo: ["URL": self.avatarURL])
            completion(.success(avatarURL))
        } else {
            completion(.failure(MockImageURLError.urlNotFound))
        }
    }
}
