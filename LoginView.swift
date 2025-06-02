import SwiftUI

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showError: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("RugbyTracker.net")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            VStack(spacing: 15) {
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    // For demo purposes, just log in with any credentials
                    isLoggedIn = true
                }) {
                    Text("Login")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 40)
            
            if showError {
                Text("Invalid credentials")
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}

#Preview {
    LoginView(isLoggedIn: .constant(false))
} 