//
// Created by Ruslan S. Shvetsov on 22.08.2023.
//

import Foundation

let Username = "ekaterina_nov"
let Name = "Екатерина Новикова"
let LoginName = "@ekaterina_nov"
let Bio = "Hello, World!"

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
                username: Username,
                name: Name,
                loginName: LoginName,
                bio: Bio
        )
    }
}