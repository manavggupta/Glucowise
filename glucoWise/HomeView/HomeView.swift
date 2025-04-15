import SwiftUI
let dayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "d"  // Format for day (e.g., "12" for 12th)
    return formatter
}()

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "house.fill").scaledToFit()
                    Text("Home")
                }
                .tag(0)
            
            TrackingView()
                .tabItem {
                    Image(systemName: "heart.text.clipboard").scaledToFit()
                    Text("Tracking")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill").scaledToFit()
                    Text("Profile")
                }
                .tag(2)
        }
        .accentColor(Color(hex: "#6CAB9C"))
    }
}

struct DashboardView: View {
    @State private var selectedDate: Date = Date()
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    CalendarSection(selectedDate: $selectedDate)
                    BloodGlucoseSection(selectedDate: selectedDate, selectedTab: $selectedTab)
                    MealRecommendationSection(selectedDate: selectedDate, carbLevel: 0.4, giLevel: 0.7)
                    DailyTipsSection(selectedDate: selectedDate)
                    DailySummarySection(userId: UserId, date: selectedDate)
                    Spacer()
                }
                .padding(.top)
            }
            .background(Color(UIColor.systemGray6))
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct CalendarSection: View {
    @Binding var selectedDate: Date // Now it's a binding

    private var weekDates: [Date] {
        let calendar = Calendar.current
        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: -$0, to: Date())
        }.reversed()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ForEach(weekDates, id: \.self) { date in
                    let isFutureDate = date > Date()
                    let isSelected = Calendar.current.isDate(selectedDate, inSameDayAs: date)
                    
                    Button(action: {
                        if !isFutureDate {
                            selectedDate = date // Update the selected date
                        }
                    }) {
                        VStack {
                            Text(dateFormatter.string(from: date))
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text(dayFormatter.string(from: date))
                                .font(.headline)
                                .foregroundColor(isFutureDate ? .gray : (isSelected ? .white : .black))
                                .frame(width: 36, height: 36)
                                .background(isSelected ? Color(hex: "#6CAB9C") : Color(hex: "#F2F2F8"))
                                .clipShape(Circle())
                        }
                    }
                    .disabled(isFutureDate)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct BloodGlucoseSection: View {
    var selectedDate: Date // Now receives the date
    @AppStorage("currentUserId") var userId: String = ""
    @Binding var selectedTab: Int
    @State private var showingAddReading = false
    @State private var refreshTrigger = false
    @ObservedObject var userManager = UserManager.shared

    private var averageGlucose: Double {
        var readings = UserManager.shared.getReadings(for: selectedDate, userId: userId)
        
        let values = readings.map { $0.value }
        return values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let lastReading = userManager.getReadings(for: selectedDate, userId: userId).last {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Blood Glucose Level")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Text("\(averageGlucose, specifier: "%.1f") mg/dL")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                        HStack {
                            Text("\(UserManager.shared.differenceBetweenBloodSugar(for: selectedDate, userId: userId) ?? 0, specifier: "%.1f") mg/dL")
                                .foregroundColor(Color(hex: "#6CAB9C")).font(.footnote)
                            
                            Text("since yesterday")
                                .foregroundColor(.gray).font(.footnote)
                        }
                        Spacer()
                        Text("Updated at \(formattedTime(from: lastReading.date))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    lastReading.image.resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)

                    NavigationLink(destination: InsightsView(selectedDate: selectedDate)) {
                        Image(systemName: "chevron.right").font(.title2)
                    }
                    .padding(.top, -10)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(12)
            } else {
                VStack(spacing: 10) {
                    
                    Text("No Readings Available")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("Tap below to add a new reading")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        showingAddReading = true
                    }) {
                        Text("Add Reading")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(hex: "6CAB9C"))
                            .cornerRadius(8)
                    }
                }
                .padding()
                .frame(height: 150)
                .frame(maxWidth: 380, maxHeight: 200)
                .background(Color.white)
                .cornerRadius(12)
                .sheet(isPresented: $showingAddReading) {
                    AddReadingView(selectedDate: selectedDate, onSave: {
                        refreshTrigger.toggle()
                    })
                }
            }

        }
        .padding(.horizontal)
        .id(refreshTrigger)
        .onAppear {
            // Set up notification observer
            NotificationCenter.default.addObserver(forName: NSNotification.Name("BloodReadingAdded"), object: nil, queue: .main) { _ in
                refreshTrigger.toggle()
            }
        }
    }
}

struct ProgressCircle: View {
    var title: String
    var value: CGFloat
    var total: CGFloat
    var unit: String
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                    .frame(width: 100, height: 100)
                Circle()
                    .trim(from: 0.0, to: value / total)
                    .stroke(Color(hex: "6CAB9C"), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 100, height: 100)
                
                VStack {
                    Text("\(Int(value))")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
        }
    }
}

struct MealRecommendationSection: View {
    var selectedDate: Date
    var carbLevel: Double // Value between 0 to 1
    var giLevel: Double // Value between 0 to 1
    @ObservedObject var userManager = UserManager.shared
    @AppStorage("currentUserId") var userId: String = ""
    var body: some View {
        VStack(alignment: .leading) {
            Text("Meal Recommendations")
                .font(.headline)
                .padding(.bottom, 4)
            
            HStack {
                // Fetch the last meal for the selected date
                if let lastMeal = userManager.getMeals(for: selectedDate, userID: userId).last {
                    VStack(alignment: .leading) {
                        HStack(alignment: .top) {
                            Text("🥗")
                                .font(.system(size: 30, weight: .bold))
                            
                            Text("Last Meal: \(String(describing: lastMeal.foodItems.first!.name))")
                                .font(.system(size: 18, weight: .bold))
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(2)
                                .minimumScaleFactor(0.5)
                                .allowsTightening(true)
                                .frame(maxHeight: 30, alignment: .leading)
                            
                            Spacer()
                        }
                        
                        // Display meal details
                      
                        
                        // Carbohydrates Progress Bar
                        Text("Carbohydrates")
                            .font(.caption)
                            .foregroundColor(.gray)
                        ProgressView(value: carbLevel)
                            .progressViewStyle(LinearProgressViewStyle())
                            .clipShape(Capsule())
                            .frame(width: 100, height: 10)
                        
                        // Glycemic Index Progress Bar
                        Text("Glycemic Index")
                            .font(.caption)
                            .foregroundColor(.gray)
                        ProgressView(value: giLevel)
                            .progressViewStyle(LinearProgressViewStyle())
                            .clipShape(Capsule())
                            .frame(width: 100, height: 10)
                    }
                } else {
                    Text("No meals logged for this date.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                Spacer()
                
                if let recommendedMeal = UserManager.shared.getRecommendedMeals(for: selectedDate, userID: userId).last {
                                    VStack(alignment: .leading) {
                                        HStack(alignment: .top) {
                                            Text("🍣")
                                                .font(.system(size: 30, weight: .bold))
                                            
                                            Text("Recommended Next Meal")
                                                .font(.system(size: 18, weight: .bold))
                                                .fixedSize(horizontal: false, vertical: true)
                                                .lineLimit(2)
                                                .minimumScaleFactor(0.5)
                                                .allowsTightening(true)
                                                .frame(maxHeight: 30, alignment: .leading)
                                            
                                            
                                        }
                                        
                                        Spacer()
                                        
                                        Text(recommendedMeal.foodItems.last!.name)
                                            .frame(maxWidth: 200, alignment: .center)
                                            .font(.caption).padding(.leading, 5)
                                            .foregroundColor(.gray)
                                        
                                        Spacer()
                                        
                                    if let url = recommendedMeal.recipeURL {
                                        Link("View Recipe >", destination: url).font(.subheadline).foregroundColor(Color(hex: "#6CAB9C")).frame(maxWidth: 200, alignment: .center).padding(.leading, 10)
                                            }
                                    }
                                } else {
                                    VStack {
                                        NavigationLink(destination: MealsView()) {
                                        Text("Add Meal")
                                                            .font(.subheadline)
                                                            .foregroundColor(.white)
                                                            .padding()
                                                            .frame(maxWidth: 200 , maxHeight: 100)
                                                .background(Color(hex: "#6CAB9C"))
                                                .cornerRadius(8)
                                                    }
                                                    .padding(.top, 8)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                }

struct DailyTipsSection: View {
    @State private var todaysTips: [Tip] = []
    var selectedDate: Date {
        didSet {
            loadTips() // Automatically load tips when selectedDate changes
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Tips")
                .font(.headline)
                .padding(.bottom, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(todaysTips, id: \.title) { tip in
                        TipCard(tip: tip)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.horizontal)
        .onAppear {
            loadTips()
        }
        .onChange(of: selectedDate) { _ in
            loadTips()
        }
    }

    private func loadTips() {
        // Get the day of the week (0 = Sunday, 1 = Monday, etc.)
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: selectedDate) - 1
        
        // Different tips for different days of the week
        switch dayOfWeek {
        case 0: // Sunday
            todaysTips = [
                Tip(imageName: "sun.max.fill", title: "Sunday Wellness", message: "Start your week with a morning walk and healthy breakfast.", actionText: "Learn More", destination: AnyView(Text("Morning Routine"))),
                Tip(imageName: "heart.fill", title: "Stress Management", message: "Practice mindfulness and meditation to reduce stress levels.", actionText: "Learn More", destination: AnyView(Text("Stress Tips"))),
                Tip(imageName: "leaf.fill", title: "Meal Planning", message: "Plan your meals for the week ahead to maintain healthy eating habits.", actionText: "Learn More", destination: AnyView(Text("Meal Planning")))
            ]
        case 1: // Monday
            todaysTips = [
                Tip(imageName: "figure.run", title: "Monday Motivation", message: "Start your week with 30 minutes of exercise to boost energy levels.", actionText: "Learn More", destination: AnyView(Text("Exercise Tips"))),
                Tip(imageName: "drop.fill", title: "Hydration Focus", message: "Keep a water bottle with you and aim to drink 8 glasses today.", actionText: "Learn More", destination: AnyView(Text("Hydration Tips"))),
                Tip(imageName: "chart.line.uptrend.xyaxis", title: "Track Progress", message: "Record your blood sugar levels and note any patterns.", actionText: "Learn More", destination: AnyView(Text("Tracking Tips")))
            ]
        case 2: // Tuesday
            todaysTips = [
                Tip(imageName: "fork.knife", title: "Healthy Eating", message: "Focus on portion control and balanced meals today.", actionText: "Learn More", destination: AnyView(Text("Diet Tips"))),
                Tip(imageName: "pills.fill", title: "Medication Check", message: "Review your medication schedule and ensure you're on track.", actionText: "Learn More", destination: AnyView(Text("Medication Tips"))),
                Tip(imageName: "figure.walk", title: "Active Lifestyle", message: "Take short walks during breaks to maintain activity levels.", actionText: "Learn More", destination: AnyView(Text("Activity Tips")))
            ]
        case 3: // Wednesday
            todaysTips = [
                Tip(imageName: "moon.fill", title: "Sleep Quality", message: "Ensure 7-8 hours of quality sleep for better blood sugar control.", actionText: "Learn More", destination: AnyView(Text("Sleep Tips"))),
                Tip(imageName: "heart.text.square.fill", title: "Heart Health", message: "Monitor blood pressure and maintain heart-healthy habits.", actionText: "Learn More", destination: AnyView(Text("Heart Health"))),
                Tip(imageName: "brain.head.profile", title: "Mental Wellness", message: "Practice positive thinking and stress management techniques.", actionText: "Learn More", destination: AnyView(Text("Mental Health")))
            ]
        case 4: // Thursday
            todaysTips = [
                Tip(imageName: "leaf.circle.fill", title: "Nutrition Focus", message: "Include more fiber-rich foods in your meals today.", actionText: "Learn More", destination: AnyView(Text("Nutrition Tips"))),
                Tip(imageName: "figure.run.circle.fill", title: "Exercise Variety", message: "Try a new form of exercise to keep your routine interesting.", actionText: "Learn More", destination: AnyView(Text("Exercise Variety"))),
                Tip(imageName: "hand.raised.fill", title: "Support System", message: "Connect with family or friends for emotional support.", actionText: "Learn More", destination: AnyView(Text("Support Tips")))
            ]
        case 5: // Friday
            todaysTips = [
                Tip(imageName: "star.fill", title: "Weekend Prep", message: "Plan healthy activities for the weekend to stay on track.", actionText: "Learn More", destination: AnyView(Text("Weekend Planning"))),
                Tip(imageName: "checkmark.circle.fill", title: "Goal Review", message: "Review your weekly health goals and celebrate progress.", actionText: "Learn More", destination: AnyView(Text("Goal Setting"))),
                Tip(imageName: "sunrise.fill", title: "Morning Routine", message: "Establish a consistent morning routine for better control.", actionText: "Learn More", destination: AnyView(Text("Morning Tips")))
            ]
        case 6: // Saturday
            todaysTips = [
                Tip(imageName: "house.fill", title: "Home Health", message: "Prepare healthy meals at home to control ingredients.", actionText: "Learn More", destination: AnyView(Text("Home Cooking"))),
                Tip(imageName: "figure.walk.motion", title: "Weekend Activity", message: "Engage in outdoor activities for physical and mental health.", actionText: "Learn More", destination: AnyView(Text("Outdoor Tips"))),
                Tip(imageName: "book.fill", title: "Health Education", message: "Learn about new diabetes management techniques.", actionText: "Learn More", destination: AnyView(Text("Education Tips")))
            ]
        default:
            // Fallback tips if something goes wrong
            todaysTips = [
                Tip(imageName: "drop.fill", title: "Stay Hydrated", message: "Drink plenty of water throughout the day.", actionText: "Learn More", destination: AnyView(Text("Hydration Tips"))),
                Tip(imageName: "figure.run", title: "Regular Exercise", message: "Aim for at least 30 minutes of moderate exercise.", actionText: "Learn More", destination: AnyView(Text("Exercise Tips"))),
                Tip(imageName: "leaf.fill", title: "Balanced Diet", message: "Include a mix of proteins, healthy fats, and complex carbohydrates.", actionText: "Learn More", destination: AnyView(Text("Diet Tips")))
            ]
        }
    }
}

struct DailySummarySection: View {
    @State private var stepsTaken: Double = 0
    let totalSteps: Double = 10000
    @State private var caloriesConsumed: Double = 0
    let totalCalories: Double = 2000
    
    @State private var expandedSection: String? = nil
    let userId: String
    var date: Date {
            didSet {
                loadData()
            }
        }


    // Observe changes to the date
    var body: some View {
        VStack(alignment: .leading) {
            Text("Daily Summary")
                .font(.headline)
                .padding(.bottom, 8)

            HStack(spacing: 50) {
                if expandedSection != "Calories" {
                    VStack {
                        ProgressCircle(title: "Steps", value: stepsTaken, total: totalSteps, unit: "steps")
                        
                        Button(action: {
                            withAnimation {
                                expandedSection = (expandedSection == "Steps") ? nil : "Steps"
                            }
                        }) {
                            HStack {
                                Text(expandedSection == "Steps" ? "View Less" : "View More")
                                    .font(.caption)
                                    .foregroundColor(Color(hex: "6CAB9C"))
                                Image(systemName: expandedSection == "Steps" ? "chevron.up" : "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(Color(hex: "6CAB9C"))
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .scale))
                }
                
                if expandedSection == "Steps" {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Goal: \(Int(totalSteps)) steps")
                        Text("Steps Remaining: \(Int(totalSteps - stepsTaken))")
                        Text("Active Time: 45 min")

                        Button(action: {
                            withAnimation {
                                expandedSection = nil
                            }
                        }) {
                            HStack {
                                Text("View Less")
                                    .font(.caption)
                                    .foregroundColor(Color(hex: "6CAB9C"))
                                Image(systemName: "chevron.up")
                                    .font(.caption)
                                    .foregroundColor(Color(hex: "6CAB9C"))
                            }
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                if expandedSection != "Steps" {
                    VStack {
                        ProgressCircle(title: "Calories", value: caloriesConsumed, total: totalCalories, unit: "kcal")
                        
                        Button(action: {
                            withAnimation {
                                expandedSection = (expandedSection == "Calories") ? nil : "Calories"
                            }
                        }) {
                            HStack {
                                Text(expandedSection == "Calories" ? "View Less" : "View More")
                                    .font(.caption)
                                    .foregroundColor(Color(hex: "6CAB9C"))
                                Image(systemName: expandedSection == "Calories" ? "chevron.up" : "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(Color(hex: "6CAB9C"))
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .scale))
                }

                if expandedSection == "Calories" {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Goal: \(Int(totalCalories)) kcal")
                        Text("Remaining: \(Int(totalCalories - caloriesConsumed)) kcal")
                        Text("Macronutrient Breakdown: 50% Carbs, 30% Protein, 20% Fats")

                        Button(action: {
                            withAnimation {
                                expandedSection = nil
                            }
                        }) {
                            HStack {
                                Text("View Less")
                                    .font(.caption)
                                    .foregroundColor(Color(hex: "6CAB9C"))
                                Image(systemName: "chevron.up")
                                    .font(.caption)
                                    .foregroundColor(Color(hex: "6CAB9C"))
                            }
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(12)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .cornerRadius(12)
        .padding(.horizontal)
        // Use onChange to trigger data loading when date changes
        .onChange(of: date) {
            loadData()
        }
        .onAppear {
            loadData()
        }
    }
    
    private func loadData() {
        DispatchQueue.main.async {
            stepsTaken = Double(UserManager.shared.getStepsTaken(userId: userId, date: date))
            caloriesConsumed = UserManager.shared.getCaloriesConsumed(userId: userId, date: date)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

func formattedTime(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter.string(from: date)
}
