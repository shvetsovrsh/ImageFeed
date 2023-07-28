//
// Created by Ruslan S. Shvetsov on 12.06.2023.
//

import Foundation
import SwiftKeychainWrapper

protocol TokenStorage {
    var token: String? { get set }
}

final class OAuth2TokenStorage: TokenStorage {
    private let keychainWrapper = KeychainWrapper.standard
    var token: String? {
        get {
            keychainWrapper.string(forKey: "AccessToken")
        }
        set {
            guard let newToken = newValue else {
                keychainWrapper.removeObject(forKey: "AccessToken")
                return
            }
            keychainWrapper.set(newToken, forKey: "AccessToken")
        }
    }
}
