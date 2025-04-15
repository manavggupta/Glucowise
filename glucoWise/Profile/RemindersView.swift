import SwiftUI

struct RemindersView: View {
    @State private var isAddReminderPresented = false
    @State private var selectedReminder: Reminder? = nil // Track selected reminder
    @State private var reminders = [
        Reminder(title: "Workout Reminder", schedule: "Every day at 7:00 am"),
        Reminder(title: "Drink water reminder", schedule: "Every hour")
    ]
    
    let reminderGreen = Color(red: 108/255, green: 171/255, blue: 157/255)
    
    var body: some View {
        NavigationView {
            VStack {
                
                
                List {
                    ForEach(reminders) { reminder in
                        ReminderRow(reminder: reminder)
                            .contentShape(Rectangle()) // Ensure tap area is large
                            .onTapGesture {
                                selectedReminder = reminder
                                isAddReminderPresented = true
                            }
                    }
                    .onDelete(perform: deleteReminder)
                }
                .listStyle(PlainListStyle())
                
                Button(action: {
                    selectedReminder = nil // New reminder
                    isAddReminderPresented = true
                }) {
                    Text("Add New Reminder")
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(reminderGreen)
                        .cornerRadius(20)
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                }
                .sheet(isPresented: $isAddReminderPresented) {
                    AddReminderView(reminder: selectedReminder) { updatedReminder in
                        saveReminder(updatedReminder)
                    }
                }
                
                Spacer()
            }
            .navigationBarTitle("Reminders", displayMode: .inline)
            .navigationBarItems(trailing: EditButton()) // Enables swipe-to-delete
            .background(Color(UIColor.systemGray6))
            .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    // Delete reminder function
    private func deleteReminder(at offsets: IndexSet) {
        reminders.remove(atOffsets: offsets)
    }
    
    // Save or update a reminder
    private func saveReminder(_ reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index] = reminder // Update existing
        } else {
            reminders.append(reminder) // Add new
        }
    }
}

// Reminder Row View
struct ReminderRow: View {
    let reminder: Reminder
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(.headline)
                Text(reminder.schedule)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 12)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color(UIColor.systemGray3))
        }
        .padding(.horizontal)
        .background(Color.white)
    }
}

// Reminder Model
struct Reminder: Identifiable {
    let id: UUID
    var title: String
    var schedule: String
    
    init(id: UUID = UUID(), title: String, schedule: String) {
        self.id = id
        self.title = title
        self.schedule = schedule
    }
}

struct RemindersView_Previews: PreviewProvider {
    static var previews: some View {
        RemindersView()
    }
}
