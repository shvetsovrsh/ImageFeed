//
// Created by Ruslan S. Shvetsov on 18.08.2023.
//

import Foundation


public enum ProfileError: Error {
    case emptyResponse
}

public struct LikeResult: Codable {
    let photo: PhotoResult
    let user: ProfileResult
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
    let publishedAt: String?
    let lastCollectedAt: String?
    let updatedAt: String?
    let coverPhoto: String?
    let user: String?
}

public struct PhotoResult: Codable {
    let id: String
    let createdAt: String?
    let updatedAt: String
    let width: Int
    let height: Int
    let color: String
    let blurHash: String
    let likes: Int
    let likedByUser: Bool
    let description: String?
    let user: ProfileResult
    let currentUserCollections: [CollectionResult]
    let urls: UrlsResult
    let links: PhotoLinksResult
}

public struct PhotoLinksResult: Codable {
    let `self`: String?
    let html: String?
    let download: String?
    let downloadLocation: String?
}

public struct ProfileResult: Codable {
    let id: String?
    let updatedAt: String?
    let username: String?
    let name: String?
    let firstName: String?
    let lastName: String?
    let twitterUsername: String?
    let portfolioUrl: URL?
    let bio: String?
    let location: String?
    let links: ProfileLinks?
    let profileImage: ProfileImage?
    let instagramUsername: String?
    let totalCollections: Int?
    let totalLikes: Int?
    let totalPhotos: Int?
    let acceptedTos: Bool?
    let forHire: Bool?
    let social: Social?
    let followedByUser: Bool?
    let photos: [Photo]?
    let badge: String?
    let tags: Tags?
    let followersCount: Int?
    let followingCount: Int?
    let allowMessages: Bool?
    let numericId: Int?
    let downloads: Int?
    let meta: Meta?
    let uid: String?
    let confirmed: Bool?
    let uploadsRemaining: Int?
    let unlimitedUploads: Bool?
    let email: String?
    let dmcaVerification: String?
    let unreadInAppNotifications: Bool?
    let unreadHighlightNotifications: Bool?

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
        let instagramUsername: String?
        let portfolioURL: URL?
        let twitterUsername: String?
        let paypalEmail: String?
    }

    struct Tags: Codable {
        let custom: [String]?
        let aggregated: [String]?
    }

    struct Meta: Codable {
        let index: Bool?
    }
}
