//
// Created by Ruslan S. Shvetsov on 26.08.2023.
//

import Foundation
import UIKit
import Kingfisher
@testable import ImageFeed

class MockProfileHelper: ProfileHelperProtocol {
    func fetchImage(url: URL, options: Kingfisher.KingfisherOptionsInfo?,
                    completion: @escaping (Result<UIImage, Error>) -> Void) {
        if url == MockImageURL.successMockImageURL {
            completion(.success(MockImage.successImage!))
        } else {
            completion(.failure(KingfisherError.requestError(reason: .emptyRequest)))
        }
    }
}
