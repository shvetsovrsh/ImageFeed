//
// Created by Ruslan S. Shvetsov on 22.08.2023.
//

import UIKit
import Kingfisher

protocol ProfileHelperProtocol {
    func fetchImage(url: URL, options: KingfisherOptionsInfo?, completion: @escaping (Result<UIImage, Error>) -> Void)
}

class ProfileHelper: ProfileHelperProtocol {
    static let shared = ProfileHelper()
    func fetchImage(url: URL, options: KingfisherOptionsInfo?, completion: @escaping (Result<UIImage, Error>) -> Void) {
        KingfisherManager.shared.retrieveImage(with: url, options: options) { result in
            switch result {
            case .success(let avatarImage):
                completion(.success(avatarImage.image))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}