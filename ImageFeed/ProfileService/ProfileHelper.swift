//
// Created by Ruslan S. Shvetsov on 22.08.2023.
//

import UIKit
import Kingfisher

protocol ProfileHelperProtocol {
    func updateAvatar(imageView: UIImageView)
}

class ProfileHelper : ProfileHelperProtocol {
    func updateAvatar(imageView: UIImageView) {
        guard
                let profileImageURL = ProfileImageService.shared.avatarURL,
                let url = URL(string: profileImageURL)
        else {
            return
        }
        print("updateAvatar to profileImageURL \(url)")
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url,
                placeholder: UIImage(named: "placeholder.png"),
                options: [.processor(processor)]) { result in

            switch result {
            case .success(let value):
                print(value.image)
                print(value.cacheType)
                print(value.source)
            case .failure(let error):
                print(error)
            }
        }
    }
}