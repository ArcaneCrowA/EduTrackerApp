import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var apiService: APIService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let user = apiService.currentUser {
                Text("Profile Information")
                    .font(.title)
                    .fontWeight(.bold)
                
                Divider()
                
                Group {
                    InfoRow(label: "Full Name", value: user.fullName)
                    InfoRow(label: "Login", value: user.login)
                    InfoRow(label: "Year", value: "\(user.year)")
                    InfoRow(label: "Role", value: user.isAdmin ? "Administrator" : "Student")
                }
                
                Spacer()
                
                Button("Logout", role: .destructive) {
                    apiService.logout()
                }
                .buttonStyle(.borderedProminent)
            } else {
                ProgressView("Loading profile...")
            }
        }
        .padding()
        .frame(maxWidth: 400)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label + ":")
                .fontWeight(.semibold)
                .frame(width: 100, alignment: .leading)
            Text(value)
        }
    }
}
