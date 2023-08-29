//
// Created by Ruslan S. Shvetsov on 22.08.2023.
//

import Foundation

public protocol WebViewPresenterProtocol {
    /// Called when the WebView has finished loading.
    func viewDidLoad()

    /// Called when the progress value of the WebView updates.
    ///
    /// - Parameter newValue: The new progress value.
    func didUpdateProgressValue(_ newValue: Double)

    /// Extracts the authentication code from a URL.
    ///
    /// - Parameter url: The URL containing the authentication code.
    /// - Returns: The authentication code if found in the URL.
    func code(from url: URL) -> String?

    /// The associated view for the presenter.
    var view: WebViewViewControllerProtocol? { get set }
}

final class WebViewPresenter: WebViewPresenterProtocol {
    weak var view: WebViewViewControllerProtocol?
    var authHelper: AuthHelperProtocol

    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }

    func viewDidLoad() {
        let request = authHelper.authRequest()
        view?.load(request: request)
        didUpdateProgressValue(0)
    }

    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)

        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }

    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }

    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
}
