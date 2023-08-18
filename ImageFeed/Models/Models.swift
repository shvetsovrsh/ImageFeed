//
// Created by Ruslan S. Shvetsov on 18.08.2023.
//

import Foundation


public enum ProfileError: Error {
    case emptyResponse
}

public struct Photo: Codable {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

public struct AvatarImage {
    let small: URL?
    let medium: URL?
    let large: URL?

    init(profileImage: ProfileImage) {
        small = profileImage.small
        medium = profileImage.medium
        large = profileImage.large
    }
}

public struct ProfileImage: Codable {
    let small: URL?
    let medium: URL?
    let large: URL?
}

public struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String

    init(profileResult: ProfileResult) {
        username = profileResult.username ?? ""
        name = "\(profileResult.first_name ?? "") \(profileResult.last_name ?? "")"
        loginName = "@\(profileResult.username ?? "")"
        bio = profileResult.bio ?? ""
    }

    init(username: String, name: String, loginName: String, bio: String) {
        self.username = username
        self.name = name
        self.loginName = loginName
        self.bio = bio
    }
}

public struct UrlsResult: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

public struct UserLinksResult: Codable {
    let `self`: String?
    let html: String?
    let photos: String?
    let likes: String?
    let portfolio: String?
}

public struct CollectionResult: Codable {
    let id: Int?
    let title: String?
    let published_at: String?
    let last_collected_at: String?
    let updated_at: String?
    let cover_photo: String?
    let user: String?
}

public struct PhotoResult: Codable {
    let id: String
    let created_at: String
    let updated_at: String
    let width: Int
    let height: Int
    let color: String
    let blur_hash: String
    let likes: Int
    let liked_by_user: Bool
    let description: String?
    let user: ProfileResult
    let current_user_collections: [CollectionResult]
    let urls: UrlsResult
    let links: PhotoLinksResult
}

public struct PhotoLinksResult: Codable {
    let `self`: String?
    let html: String?
    let download: String?
    let download_location: String?
}

public struct ProfileResult: Codable {
    let id: String?
    let updated_at: String?
    let username: String?
    let name: String?
    let first_name: String?
    let last_name: String?
    let twitter_username: String?
    let portfolio_url: URL?
    let bio: String?
    let location: String?
    let links: ProfileLinks?
    let profile_image: ProfileImage?
    let instagram_username: String?
    let total_collections: Int?
    let total_likes: Int?
    let total_photos: Int?
    let accepted_tos: Bool?
    let for_hire: Bool?
    let social: Social?
    let followed_by_user: Bool?
    let photos: [Photo]?
    let badge: String?
    let tags: Tags?
    let followers_count: Int?
    let following_count: Int?
    let allow_messages: Bool?
    let numeric_id: Int?
    let downloads: Int?
    let meta: Meta?
    let uid: String?
    let confirmed: Bool?
    let uploads_remaining: Int?
    let unlimited_uploads: Bool?
    let email: String?
    let dmca_verification: String?
    let unread_in_app_notifications: Bool?
    let unread_highlight_notifications: Bool?

    struct ProfileLinks: Codable {
        let `self`: URL?
        let html: URL?
        let photos: URL?
        let likes: URL?
        let portfolio: URL?
        let following: URL?
        let followers: URL?
    }

    struct Social: Codable {
        let instagram_username: String?
        let portfolio_uRL: URL?
        let twitter_username: String?
        let paypal_email: String?
    }

    struct Tags: Codable {
        let custom: [String]?
        let aggregated: [String]?
    }

    struct Meta: Codable {
        let index: Bool?
    }
}
