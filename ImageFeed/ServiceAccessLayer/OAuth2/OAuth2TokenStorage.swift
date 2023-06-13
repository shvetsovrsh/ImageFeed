//
// Created by Ruslan S. Shvetsov on 12.06.2023.
//

import Foundation

protocol TokenStorage {
    var token: String? { get set }
}

final class OAuth2TokenStorage: TokenStorage {
    private let userDefaults = UserDefaults.standard
    var token: String? {
        get {
            userDefaults.string(forKey: "AccessToken")
        }
        set {
            userDefaults.set(newValue, forKey: "AccessToken")
        }
    }
}