import SwiftUI

struct AddReminderView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var reminder: Reminder? // Optional reminder for editing
    var onSave: (Reminder) -> Void // Callback to save reminder
    
    @State private var title: String = ""
    @State private var selectedTime = Date()
    @State private var repeatOption = "Never"
    @State private var isRepeatPickerPresented = false

    let repeatOptions = ["Never", "Every Hour", "Daily", "Weekly", "Monthly"]
    
    init(reminder: Reminder?, onSave: @escaping (Reminder) -> Void) {
        self.reminder = reminder
        self.onSave = onSave
        _title = State(initialValue: reminder?.title ?? "")
        _repeatOption = State(initialValue: reminder?.schedule ?? "Never")
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Title", text: $title)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                // Time Picker
                VStack(spacing: 0) {
                    HStack {
                        Text("Time")
                            .padding(.leading)
                        Spacer()
                        DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .padding(.trailing)
                    }
                    .padding(.vertical, 10)
                    
                    Divider().padding(.leading)
                    
                    // Repeat Selection
                    HStack {
                        Text("Repeat")
                            .padding(.leading)
                        Spacer()
                        Button(action: {
                            isRepeatPickerPresented.toggle()
                        }) {
                            HStack {
                                Text(repeatOption)
                                    .foregroundColor(.blue)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.blue)
                                    .font(.footnote)
                            }
                            .padding()
                            .background(Color(UIColor.systemGray5))
                            .cornerRadius(10)
                            .padding(.trailing)
                        }
                    }
                    .padding(.vertical, 10)
                }
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 80)
            .navigationBarTitle(reminder == nil ? "Add Reminder" : "Edit Reminder", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    let newReminder = Reminder(id: reminder?.id ?? UUID(), title: title, schedule: repeatOption)
                    onSave(newReminder) // Save callback
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(title.isEmpty) // Disable button if title is empty
                .foregroundColor(title.isEmpty ? Color.gray : Color.blue) // Change color when disabled
            )
            .actionSheet(isPresented: $isRepeatPickerPresented) {
                ActionSheet(title: Text("Repeat"), buttons: repeatOptions.map { option in
                    .default(Text(option)) { repeatOption = option }
                } + [.cancel()])
            }
            .background(Color(UIColor.systemGray6)) // Set system gray background
            .edgesIgnoringSafeArea(.all) // Extend background to full screen
        }
    }
}

struct AddReminderView_Previews: PreviewProvider {
    static var previews: some View {
        AddReminderView(reminder: nil) { _ in }
    }
}
