import SwiftUI

struct ActivitySelectionView: View {
    // Initialize with a default selected activity
    @State private var selectedActivity: String? = "sedentary"
    @Environment(\.presentationMode) var presentationMode
    
    let activities = [
        Activity(id: "sedentary", title: "Sedentary", description: "Very little or no physical activity", icon: "chair.fill"),
        Activity(id: "lightly", title: "Lightly Active", description: "Occasional physical activity, such as light walking or household chores.", icon: "figure.stand"),
        Activity(id: "moderately", title: "Moderately Active", description: "Regular physical activity, such as walking, jogging, or exercise 2-3 times a week.", icon: "figure.walk"),
        Activity(id: "very", title: "Very Active", description: "Frequent, intense activity or regular workouts 4+ times a week.", icon: "figure.outdoor.cycle")
    ]
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("How active are you?")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 16)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(activities) { activity in
                            ActivityCardView(
                                activity: activity,
                                isSelected: selectedActivity == activity.id,
                                onSelect: {
                                    selectedActivity = activity.id
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    NavigationLink(destination: BloodSugarInputView()) {
                        Text("Next")
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                            .frame(width: 325)
                            .padding()
                            .background(selectedActivity == nil ? Color.gray : Color(red: 100/255, green: 175/255, blue: 160/255))
                            .cornerRadius(16)
                    }
                    .disabled(selectedActivity == nil)
                    .onTapGesture {
                        if let activity = selectedActivity {
                            // Update user's activity level in UserManager
                            if let userIndex = UserManager.shared.getAllUsers().firstIndex(where: { $0.id == UserId }) {
                                var updatedUser = UserManager.shared.getAllUsers()[userIndex]
                                updatedUser.activityLevel = ActivityLevel(rawValue: activity) ?? .sedentary
                                UserManager.shared.updateUser(updatedUser)
                            }
                        }
                    }
                    Spacer()
                }
                .padding(.bottom, 40)
            }
            .padding(.top)
            .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
            .navigationBarHidden(false)
        }
    }
}

struct Activity: Identifiable {
    var id: String
    var title: String
    var description: String
    var icon: String
}

struct ActivityCardView: View {
    let activity: Activity
    let isSelected: Bool
    let onSelect: () -> Void
    
    private let highlightColor = Color(red: 100/255, green: 175/255, blue: 160/255)
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .center, spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? highlightColor : Color(UIColor.systemGray5))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: activity.icon)
                        .font(.system(size: 30))
                        .foregroundColor(isSelected ? .white : .gray)
                }
                .padding(.top, 16)
                
                Text(activity.title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                
                Text(activity.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.85)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 16)
            }
            .frame(height: 170)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color(red: 240/255, green: 248/255, blue: 255/255) : Color(UIColor.systemGray6))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? highlightColor : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ContentViews_Previews: PreviewProvider {
    static var previews: some View {
        ActivitySelectionView()
    }
}
