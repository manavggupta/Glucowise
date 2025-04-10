import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isLoggedIn: Bool = false  // Track login status
    @State private var navigateToRegister: Bool = false
    @State private var isValidEmail: Bool = false

    @Environment(\.presentationMode) var presentationMode
    
    private let accentColor = Color(red: 108/255, green: 171/255, blue: 157/255)
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 60)
            
            Text("Welcome Back")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 30)
            
            // Email Field
            TextField("Email", text: $email)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .onChange(of: email) { _ in validateEmail() }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(!isValidEmail && !email.isEmpty ? Color.red.opacity(0.5) : Color.clear, lineWidth: 1)
                )
                .padding(.horizontal)

            // Password Field
            HStack {
                if isPasswordVisible {
                    TextField("Password", text: $password)
                } else {
                    SecureField("Password", text: $password)
                }
                
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            
            // Forgot Password
            HStack {
                Spacer()
                NavigationLink(destination: ForgetPasswordView()) {
                    Text("Forgot Password?")
                        .foregroundColor(accentColor)
                }
                Spacer()
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            // Login Button
            Button(action: handleLogin) {
                HStack {
                    Spacer()
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(accentColor)
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .disabled(!isValidEmail || password.isEmpty)
            
            // Register Button
            HStack {
                Text("Don't have an account yet?")
                    .foregroundColor(.black)
                
                Button(action: {
                    navigateToRegister = true
                }) {
                    Text("Register")
                        .foregroundColor(accentColor)
                }
            }
            .padding(.top, 10)
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Login Failed"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .fullScreenCover(isPresented: $isLoggedIn) {  // ✅ Full-screen transition
            ContentView()
        }
        .fullScreenCover(isPresented: $navigateToRegister) {
            RegistrationView(uservm: UserViewModel())
        }
    }
    
    // Email validation function
    private func validateEmail() {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        isValidEmail = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    // ✅ Login Validation Function
    private func handleLogin() {
        Task {
            do {
                let session = try await SupabaseManager.shared.client.auth.signIn(
                    email: email,
                    password: password
                )

                print("✅ Login successful! Session: \(session)")

                guard let userId = session.user.id.uuidString as String? else {
                    alertMessage = "User ID not found."
                    showAlert = true
                    return
                }

                // Fetch user data from "users" table using auth ID
                let user: User = try await SupabaseManager.shared.client.database
                    .from("users")
                    .select()
                    .eq("id", value: userId)
                    .single()
                    .execute()
                    .value

                print("✅ Fetched user: \(user.name)")

                // ✅ Optionally: Load data into shared view model here if needed
                // For example:
                // userVM.load(from: user)

                isLoggedIn = true

            } catch {
                print("❌ Login failed: \(error)")
                alertMessage = "Invalid email or password. Please try again."
                showAlert = true
            }
        }
    }



}
