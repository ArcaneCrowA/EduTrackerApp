import Foundation
import SwiftUI
import Combine

class APIService: ObservableObject {
    static let shared = APIService()
    
    private let baseURL = "http://localhost:8080/api/v1"
    @Published var token: String? = UserDefaults.standard.string(forKey: "authToken")
    @Published var currentUser: User? = nil
    
    private init() {
        if let savedToken = token {
            initSession(token: savedToken)
        }
    }
    
    func setToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "authToken")
        self.initSession(token: token)
    }
    
    private func initSession(token: String) {
        self.token = token
        // Fetch current user info after setting token
        Task {
            do {
                let user: User = try await request("/users/me", method: "GET")
                DispatchQueue.main.async {
                    self.currentUser = user
                }
            } catch {
                print("Failed to fetch current user: \(error)")
            }
        }
    }
    
    func logout() {
        Task {
            do {
                let _: EmptyResponse? = try? await request("/logout", method: "POST")
            }
        }
        DispatchQueue.main.async {
            self.token = nil
            self.currentUser = nil
            UserDefaults.standard.removeObject(forKey: "authToken")
        }
    }
    
    func request<T: Codable>(_ endpoint: String, method: String, body: Codable? = nil) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "APIService", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
        
        if T.self == EmptyResponse.self {
            return EmptyResponse() as! T
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}

struct EmptyResponse: Codable {}
