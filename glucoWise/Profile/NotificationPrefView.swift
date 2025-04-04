import SwiftUI

struct NotificationPreferencesView: View {
    @State private var appNotificationsEnabled = true
    @State private var mailNotificationsEnabled = true
    @State private var reminderNotificationsEnabled = true
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
               
                VStack(spacing: 0) {
                    ToggleRow(
                        icon: "bell",
                        title: "App Notifications",
                        isOn: $appNotificationsEnabled
                    )
                    
                    Divider()
                        .padding(.leading, 56)
                    
                    ToggleRow(
                        icon: "envelope",
                        title: "Mail Notifications",
                        isOn: $mailNotificationsEnabled
                    )
                    
                    Divider()
                        .padding(.leading, 56)
                    
                    ToggleRow(
                        icon: "bell",
                        title: "Reminder Notifications",
                        isOn: $reminderNotificationsEnabled
                    )
                }
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
            }
            .background(Color(UIColor.systemGray6))
            .navigationTitle("Notification Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {}) {
                        
                    }
                }
            }
        }
    }
}

struct ToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 24, height: 24)
                .padding(.leading)
            
            Text(title)
                .font(.body)
                .padding(.leading, 8)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.green)
                .padding(.trailing)
        }
        .padding(.vertical, 14)
    }
}

struct NotificationPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationPreferencesView()
    }
}
