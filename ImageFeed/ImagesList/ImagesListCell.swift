//
// Created by Ruslan S. Shvetsov on 08.04.2023.
//

import UIKit

protocol ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!

    var delegate: ImagesListCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        likeButton.addTarget(self, action: #selector(handleLikeButtonClick), for: .touchUpInside)
    }


    func setIsLiked(_ isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        likeButton.setImage(likeImage, for: .normal)
        selectionStyle = .none
    }

    func setDate(_ createdAt: Date?) {
        if let createdAt = createdAt {
            dateLabel.text = dateFormatter.string(from: createdAt)
        } else {
            dateLabel.text = dateFormatter.string(from: Date())
        }
    }

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    @objc private func handleLikeButtonClick() {
        delegate?.imageListCellDidTapLike(self)
    }
}