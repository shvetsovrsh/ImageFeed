//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Ruslan S. Shvetsov on 18.03.2023.
//

import UIKit

public protocol ImagesListViewControllerProtocol {
    func updateTableViewAnimated(from oldCount: Int, to newCount: Int)
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    private var presenter: ImagesListPresenterProtocol!
    var photos: [Photo] = []
    private let imagesListService = ImagesListService()

    let ShowSingleImageSegueIdentifier = "ShowSingleImage"

    @IBOutlet private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        presenter = ImagesListPresenter(viewController: self)
        fetchPhotos()
    }

    private func fetchPhotos() {
        presenter.fetchPhotosNextPage()
        photos = presenter.photos
        updateTableView()
    }

    func updateTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    @objc private func handlePhotosChangeNotification() {
        fetchPhotos()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == ShowSingleImageSegueIdentifier,
           let viewController = segue.destination as? SingleImageViewController,
           let indexPath = sender as? IndexPath {
            let photo = photos[indexPath.row]
            let imageUrl = photo.largeImageURL

            viewController.imageUrl = imageUrl
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    func updateTableViewAnimated(from oldCount: Int, to newCount: Int) {
        self.photos = self.presenter.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }

    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]

        if let thumbImageURL = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.indicatorType = .activity
            cell.cellImage.kf.setImage(with: thumbImageURL, placeholder: UIImage(named: "placeholder_image")) { [weak self] result in
                guard let self = self else {
                    return
                }
                switch result {
                case .success:
                    cell.setIsLiked(self.photos[indexPath.row].isLiked)
                    cell.setDate(photo.createdAt)
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                case .failure:
                    cell.cellImage.image = UIImage(named: "placeholder_image")
                    cell.setIsLiked(indexPath.row % 2 == 0)
                }
            }
        }
    }
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
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
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
        guard indexPath.row + 1 == presenter.photos.count else {
            return
        }
        presenter.fetchPhotosNextPage()
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        UIBlockingProgressHUD.show()
        presenter.togglePhotoLikeStatus(at: indexPath.row) { [ weak self ] isLikeChanged in
            guard let self = self else { return }
            if isLikeChanged {
                self.photos = self.presenter.photos
                self.tableView.reloadRows(at: [indexPath], with: .none)
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            } else {
                UIBlockingProgressHUD.dismiss()
                self.showAlertViewController()
                return
            }
        }
    }

    private func showAlertViewController() {
        let alertController = UIAlertController(title: "Что-то пошло не так",
                message: "Не удалось поставить лайк", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
