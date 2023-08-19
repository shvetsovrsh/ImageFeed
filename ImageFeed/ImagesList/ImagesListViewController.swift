//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Ruslan S. Shvetsov on 18.03.2023.
//

import UIKit

class ImagesListViewController: UIViewController {
    var photos: [Photo] = []
    private let imagesListService = ImagesListService()

    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"

    @IBOutlet private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        fetchPhotos()

        NotificationCenter.default.addObserver(
                forName: ImagesListService.DidChangeNotification,
                object: nil,
                queue: .main) { [weak self] _ in
            guard let self else {
                return
            }
            self.updateTableViewAnimated()
        }
    }

    private func fetchPhotos() {
        imagesListService.fetchPhotosNextPage()
        photos = imagesListService.photos
        tableView.reloadData()
    }

    @objc private func handlePhotosChangeNotification() {
        fetchPhotos()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowSingleImageSegueIdentifier,
           let viewController = segue.destination as? SingleImageViewController,
           let indexPath = sender as? IndexPath {
            let photo = photos[indexPath.row]
            if let image = UIImage(named: "\(photo.id)_full_size") ?? UIImage(named: photo.id) {
                viewController.image = image
            }
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in
            }
        }
    }

    func configCell(for cell: ImagesListCell) {
    }

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)

        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }

        configCell(for: imageListCell, with: indexPath)

        return imageListCell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]

        if let thumbImageURL = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.indicatorType = .activity
            cell.cellImage.kf.setImage(with: thumbImageURL, placeholder: UIImage(named: "placeholder_image")) { [weak self] result in
                guard let self = self else {
                    return
                }
                switch result {
                case .success(let image):
                    let isLiked = self.photos[indexPath.row].isLiked
                    let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
                    cell.likeButton.setImage(likeImage, for: .normal)
                    cell.selectionStyle = .none
                    if let createdAt = photo.createdAt {
                        cell.dateLabel.text = self.dateFormatter.string(from: createdAt)
                    } else {
                        cell.dateLabel.text = self.dateFormatter.string(from: Date())
                    }
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                case .failure(_):
                    cell.cellImage.image = UIImage(named: "placeholder_image")
                    let isLiked = indexPath.row % 2 == 0
                    let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
                    cell.likeButton.setImage(likeImage, for: .normal)
                    cell.selectionStyle = .none
                }
            }
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row + 1 == imagesListService.photos.count else {
            return
        }
        imagesListService.fetchPhotosNextPage()
    }
}
