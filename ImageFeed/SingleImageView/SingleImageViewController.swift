//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Ruslan S. Shvetsov on 28.05.2023.
//

import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage! {
        didSet {
            guard isViewLoaded else {
                return
            }
            imageView.image = image
            rescaleAndCenterImageInScrollView(image: image)
        }
    }

    var imageUrl: String?

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchImage()
    }

    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func didTapShareButton(_ sender: UIButton) {
        let share = UIActivityViewController(
                activityItems: [image as Any],
                applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }

    private func showAlertViewController() {
        let alertController = UIAlertController(title: "Что-то пошло не так(", message: "Повторим еще раз?",
                preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Не надо", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.fetchImage()
        }

        alertController.addAction(cancelAction)
        alertController.addAction(retryAction)

        present(alertController, animated: true, completion: nil)
    }

    private func fetchImage() {
        guard let imageUrlString = imageUrl, let imageUrl = URL(string: imageUrlString) else {
            return
        }
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: imageUrl) { [weak self] result in
            guard let self = self else {
                return
            }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let fullImage):
                self.scrollView.minimumZoomScale = 0.1
                self.scrollView.maximumZoomScale = 1.25
                self.imageView.image = fullImage.image
                self.rescaleAndCenterImageInScrollView(image: fullImage.image)
            case .failure:
                self.showAlertViewController()
            }
        }
    }

    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
