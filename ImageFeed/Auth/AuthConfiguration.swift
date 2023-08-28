//
// Created by Ruslan S. Shvetsov on 30.05.2023.
//

import Foundation

enum AuthConstants {
    static let accessKey = "0wta3LU2MyyfyI6tirHPt2MxIrHWa0QlotVIodvwL2s"
    static let secretKey = "oHHWRixyha3JIjXPsHwGWs9xGXH1ylgYWS_pGK6Ku-c"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String

    init(
            accessKey: String,
            secretKey: String,
            redirectURI: String,
            accessScope: String,
            authURLString: String,
            defaultBaseURL: URL
    ) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }

    static var standard: AuthConfiguration {
        AuthConfiguration(accessKey: AuthConstants.accessKey,
                secretKey: AuthConstants.secretKey,
                redirectURI: AuthConstants.redirectURI,
                accessScope: AuthConstants.accessScope,
                authURLString: AuthConstants.unsplashAuthorizeURLString,
                defaultBaseURL: AuthConstants.defaultBaseURL)
    }
}
