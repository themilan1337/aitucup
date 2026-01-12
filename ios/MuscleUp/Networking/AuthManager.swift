import Foundation
import SwiftUI
import Combine

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @AppStorage("access_token") var accessToken: String?
    @AppStorage("refresh_token") var refreshToken: String?
    @Published var currentUser: UserProfile?
    @Published var isAuthenticated: Bool = false
    
    private init() {
        self.isAuthenticated = accessToken != nil
    }
    
    func loginWithOAuth(provider: String, idToken: String) async throws {
        let request = OAuthLoginRequest(id_token: idToken, provider: provider)
        let tokenResponse: TokenResponse = try await APIClient.shared.request("auth/login/oauth", method: "POST", body: request)
        
        self.accessToken = tokenResponse.access_token
        self.refreshToken = tokenResponse.refresh_token
        self.isAuthenticated = true
        
        try await fetchCurrentUser()
    }
    
    func fetchCurrentUser() async throws {
        let user: UserProfile = try await APIClient.shared.request("auth/me")
        DispatchQueue.main.async {
            self.currentUser = user
        }
    }
    
    func logout() {
        self.accessToken = nil
        self.refreshToken = nil
        self.isAuthenticated = false
        self.currentUser = nil
    }
}

struct OAuthLoginRequest: Encodable {
    let id_token: String
    let provider: String
}

struct TokenResponse: Decodable {
    let access_token: String
    let refresh_token: String
    let token_type: String
}

struct UserProfile: Decodable {
    let id: String
    let email: String
    let full_name: String?
    let avatar_url: String?
    let oauth_provider: String
}
