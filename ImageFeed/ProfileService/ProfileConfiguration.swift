//
// Created by Ruslan S. Shvetsov on 22.08.2023.
//

import Foundation

enum UserProfileConstants {
    static let username = "ekaterina_nov"
    static let name = "Екатерина Новикова"
    static let loginName = "@ekaterina_nov"
    static let bio = "Hello, World!"
}

public struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String

    init(profileResult: ProfileResult) {
        username = profileResult.username ?? ""
        name = "\(profileResult.firstName ?? "") \(profileResult.lastName ?? "")"
        loginName = "@\(profileResult.username ?? "")"
        bio = profileResult.bio ?? ""
    }

    init(username: String, name: String, loginName: String, bio: String) {
        self.username = username
        self.name = name
        self.loginName = loginName
        self.bio = bio
    }

    static var standard: Profile {
        Profile(
                username: UserProfileConstants.username,
                name: UserProfileConstants.name,
                loginName: UserProfileConstants.loginName,
                bio: UserProfileConstants.bio
        )
    }
}