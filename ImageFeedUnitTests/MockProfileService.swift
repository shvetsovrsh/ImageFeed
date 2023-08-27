//
// Created by Ruslan S. Shvetsov on 26.08.2023.
//

import Foundation
@testable import ImageFeed

class MockProfileService: ProfileServiceProtocol {
    var profile: ImageFeed.Profile?

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        if let profile = profile {
            completion(.success(profile))
        } else {
            completion(.failure(MockError.profileNotFound))
        }
    }
    func logout() {
        
    }
}

enum MockError: Error {
    case profileNotFound
}
