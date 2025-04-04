import SwiftUI

struct ProfileView: View {
    // Add a state to check if image is available
    @State private var profileImage: UIImage? = nil
    @State private var showLogoutAlert = false
    @State private var navigateToLogin = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Image and Name
                    VStack(spacing: 12) {
                        // Use a conditional to show default image or loaded image
                        Group {
                            if let image = profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                // Default image icon when no image is available
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(Color(.systemGray3))
                            }
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color(.systemGray5), lineWidth: 1)
                        )
                        
                        if let userName = UserManager.shared.getCurrentUserName() {
                            Text(userName)
                                .font(.title2)
                                .fontWeight(.semibold)
                        } else {
                            Text("User")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    // User Settings Section
                    VStack(spacing: 0) {
                        SectionHeaderView(title: "User Settings")
                        
                        NavigationLink(destination: ChangePasswordView()) {
                            HStack {
                                Image(systemName: "lock")
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.black)
                                Text("Change Password")
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                        }

                        Divider()
                            .padding(.leading)
                        
                        NavigationLink(destination: NotificationPreferencesView()) {
                            HStack {
                                Image(systemName: "bell")
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.black)
                                Text("Notification Preference")
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // General Section
                    VStack(spacing: 0) {
                        SectionHeaderView(title: "General")
                        
                        NavigationLink(destination: HbA1cEstimatorView()) {
                            HStack {
                                Image(systemName: "chart.bar")
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.black)
                                Text("HbA1c Estimator")
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                        }

                        Divider()
                            .padding(.leading)
                        
                        NavigationLink(destination: RemindersView()) {
                            HStack {
                                Image(systemName: "alarm")
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.black)
                                Text("Reminders")
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // Add Logout Button
                    Button(action: {
                        showLogoutAlert = true
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Logout")
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                .padding(.bottom, 20)
            }
            .background(Color(.systemGray6))
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadProfileImage()
            }
            .alert("Logout", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    // Clear any necessary state
                    UserDefaults.standard.removeObject(forKey: "currentUserId") // Remove UserId from UserDefaults
                    UserId = "" // Reset the global UserId
                    navigateToLogin = true
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
            .fullScreenCover(isPresented: $navigateToLogin) {
                LoginView()
            }
        }
    }
    
    // Function to load profile image from UserManager
    private func loadProfileImage() {
        if let user = UserManager.shared.getAllUsers().first(where: { $0.id == UserId }),
           let imageData = user.profileImageData,
           let image = UIImage(data: imageData) {
            self.profileImage = image
        }
    }
}

// Custom Section Header View
struct SectionHeaderView: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .padding(.vertical, 8)
            Spacer()
        }
        .background(Color(.systemGray6))
    }
}

// Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
