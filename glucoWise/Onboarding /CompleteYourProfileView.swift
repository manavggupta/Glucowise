//  ProfileCompletionView.swift
//  GlucoWise SwiftUI
//
//  Created by Sehdev Saini on 05/03/25.
//

import SwiftUI
import PhotosUI

struct ProfileCompletionView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedImageData: Data? = nil
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var showCameraPicker = false
    
    @State private var gender = ""
    @State private var dateOfBirth = Date()
    @State private var height = ""
    @State private var weight = ""
    
    @State private var showValidationError = false
    @State private var validationErrorMessage = ""
    
    @State private var navigateToNextScreen = false
    
    private let themeColor = Color(hex: "6CAB9D")

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                // Title
                Text("Let's complete your profile")
                    .font(.system(size: 24, weight: .bold))
                    .padding(.top, 20)
                
                // Profile Picture
                VStack {
                    if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 150)
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {
                        showImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("Add Photo")
                        }
                        .foregroundColor(themeColor)
                    }
                }
                .actionSheet(isPresented: $showImagePicker) {
                    ActionSheet(
                        title: Text("Choose Profile Picture"),
                        buttons: [
                            .default(Text("Take Photo")) {
                                sourceType = .camera
                                showCameraPicker = true
                            },
                            .default(Text("Choose from Gallery")) {
                                sourceType = .photoLibrary
                                showCameraPicker = true
                            },
                            .cancel()
                        ]
                    )
                }
                .sheet(isPresented: $showCameraPicker) {
                    ImagePicker(imageData: $selectedImageData, sourceType: sourceType)
                }
                
                // Gender Picker - Updated with green color
                HStack {
                    Text("Gender")
                        .foregroundColor(Color.primary)
                    Spacer()
                    Picker("", selection: $gender) {
                        Text("Select").tag("")
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accentColor(themeColor)
                }
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal, 20)
                
                // Date of Birth Picker - Updated with green color
                DatePicker("Date of Birth", selection: $dateOfBirth,
                           in: ...Calendar.current.date(byAdding: .year, value: -18, to: Date())!,
                           displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
                .accentColor(themeColor)
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal, 20)
                
                // Height TextField
                TextField("Height (cm)", text: $height)
                    .keyboardType(.numberPad)
                    .textFieldStyle(CustomTextFieldStyle())
                  
                
                // Weight TextField
                TextField("Weight (kg)", text: $weight)
                    .keyboardType(.numberPad)
                    .textFieldStyle(CustomTextFieldStyle())
                
                // Validation Error Message
                if showValidationError {
                    Text(validationErrorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Next Button
                Button(action: {
                    validateAndProceed()
                }) {
                    HStack {
                        Text("Next")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(themeColor)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                }
                
                NavigationLink("", destination: ActivitySelectionView(), isActive: $navigateToNextScreen)
            }
            .background(Color.white)
            .padding(.bottom, 10)
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
        }
        .tint(themeColor) // Add tint for navigation elements
    }
    
    // MARK: - Validation Logic
    func validateAndProceed() {
        showValidationError = false
        validationErrorMessage = ""
        
        guard !gender.isEmpty else {
            validationErrorMessage = "Please select a gender"
            showValidationError = true
            return
        }
        
        let age = Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
        guard age >= 18 else {
            validationErrorMessage = "You must be at least 18 years old"
            showValidationError = true
            return
        }
        
        guard let heightValue = Double(height), heightValue >= 100 else {
            validationErrorMessage = "Please enter a valid height (min 100 cm)"
            showValidationError = true
            return
        }
        
        guard let weightValue = Double(weight), weightValue >= 30 else {
            validationErrorMessage = "Please enter a valid weight (min 30 kg)"
            showValidationError = true
            return
        }
        
        // Update user profile in UserManager
        if let userIndex = UserManager.shared.getAllUsers().firstIndex(where: { $0.id == UserId }) {
            var updatedUser = UserManager.shared.getAllUsers()[userIndex]
            updatedUser.age = age
            updatedUser.gender = Gender(rawValue: gender) ?? .male
            updatedUser.height = heightValue
            updatedUser.weight = weightValue
            updatedUser.profileImageData = selectedImageData // Save the profile image data
            UserManager.shared.updateUser(updatedUser)
        }
        
        // If all validations pass, navigate to the next screen
        navigateToNextScreen = true
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var imageData: Data?
    var sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage, let imageData = image.jpegData(compressionQuality: 0.8) {
                parent.imageData = imageData
            }
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Custom Text Field Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal, 20)
    }
}

// MARK: - Keyboard Dismiss Extension
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}





struct ProfileCompletionView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileCompletionView()
    }
}
