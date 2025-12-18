import SwiftUI

struct LoginView: View {
    @State private var login = UserDefaults.standard.string(forKey: "savedLogin") ?? ""
    @State private var password = UserDefaults.standard.string(forKey: "savedPassword") ?? ""
    @State private var rememberMe = UserDefaults.standard.bool(forKey: "rememberMe")
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    @EnvironmentObject var apiService: APIService
    
    var body: some View {
        VStack(spacing: 20) {
            Text("EduTracker")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Login")
                    .font(.headline)
                TextField("Username", text: $login)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocorrectionDisabled()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.headline)
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            Toggle("Remember Me", isOn: $rememberMe)
                .padding(.vertical, 8)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: performLogin) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                } else {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading || login.isEmpty || password.isEmpty)
            .keyboardShortcut(.defaultAction)
            
            Spacer()
        }
        .padding(40)
        .frame(width: 400, height: 500)
    }
    
    func performLogin() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                let body = ["login": login, "password": password]
                let response: AuthResponse = try await apiService.request("/public/login", method: "POST", body: body)
                DispatchQueue.main.async {
                    if rememberMe {
                        UserDefaults.standard.set(login, forKey: "savedLogin")
                        UserDefaults.standard.set(password, forKey: "savedPassword")
                        UserDefaults.standard.set(true, forKey: "rememberMe")
                    } else {
                        UserDefaults.standard.removeObject(forKey: "savedLogin")
                        UserDefaults.standard.removeObject(forKey: "savedPassword")
                        UserDefaults.standard.set(false, forKey: "rememberMe")
                    }
                    apiService.setToken(response.token)
                    isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

extension Dictionary: Codable where Key == String, Value == String {}
