//
//  DataModel.swift
//  glucoWise
//
//  Created by Manav Gupta on 13/03/25.
//







import Foundation
import SwiftUICore
import SwiftUI

struct User: Codable {
    var id: String? = UUID().uuidString
    var name: String
    var emailId: String
    var password: String
    var age: Int
    var gender: Gender
    var weight: Double
    var height: Double
    var targetBloodSugar: Double?
    var currentBloodSugar: Double?
    var activityLevel: ActivityLevel
    var profileImageData: Data?
}
struct Tip {
    let imageName: String
    let title: String
    let message: String
    let actionText: String
    let destination: AnyView
}

// Tip Card View
struct TipCard: View {
    let tip: Tip
    
    var body: some View {
        VStack {
            Image(systemName: tip.imageName)
                .resizable()
                .frame(width: .infinity, height: .infinity)
                .foregroundColor(Color(hex: "6CAB9C")).scaledToFit().padding(10)
            
            Text(tip.title)
                .font(.headline)
            
            Text(tip.message)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 50)
            
            Spacer()
            
            NavigationLink(destination: tip.destination) {
                Text(tip.actionText)
                    .font(.caption)
                    .foregroundColor(Color(hex: "6CAB9C"))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .frame(width: 180, height: 200)
    }
}

// Function to get daily tips

enum Gender: String, Codable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
}

enum ActivityLevel: String, Codable {
    case sedentary = "Sedentary"
    case active = "Active"
    case veryActive = "Very Active"
    case moderateActive = "Moderately Active"
}
struct ActivityProgress {
    var date: Date  // The specific day of the activity
    var caloriesBurned: Double? = 0    // Total calories burned
    var workoutMinutes: Int  // Total workout minutes
    var totalSteps: Int? = 0  // Total steps taken
}


struct Meal: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var userId : String?
    var type: MealType  // Breakfast, Lunch, Dinner, Snacks
    var foodItems: [FoodItem]  // List of food items
    var date: Date  // Date when the meal was logged
    let recipeURL: URL?
    // Function to calculate total nutrition for the meal
    var totalNutrition: (calories: Double, carbs: Double, fats: Double, proteins: Double, fiber: Double, giIndex: Double, glIndex: Double) {
            let totalCalories = foodItems.reduce(0) { $0 + $1.calories }
            let totalCarbs = foodItems.reduce(0) { $0 + $1.carbs }
            let totalFats = foodItems.reduce(0) { $0 + $1.fats }
            let totalProteins = foodItems.reduce(0) { $0 + $1.proteins }
            let totalFiber = foodItems.reduce(0) { $0 + $1.fiber }
            let avgGIIndex = foodItems.isEmpty ? 0 : foodItems.reduce(0) { $0 + $1.giIndex } / Double(foodItems.count)
            let avgGLIndex = (avgGIIndex * totalCarbs) / 100
            return (totalCalories, totalCarbs, totalFats, totalProteins, totalFiber, avgGIIndex, avgGLIndex)
        }
}

struct FoodItem: Identifiable, Hashable,Codable {
    var id: String = UUID().uuidString
    var name: String
    var quantity: Double // Example: 100g, 1 cup, etc.
    var calories: Double
    var carbs: Double
    var fats: Double
    var proteins: Double
    var fiber: Double
    var giIndex: Double
  
    func adjustedNutrients(for newQuantity: Double) -> FoodItem {
        let factor = newQuantity / quantity
        return FoodItem(
            name: name,
            quantity: newQuantity,
            calories: calories * factor,
            carbs: carbs * factor,
            fats: fats * factor,
            proteins: proteins * factor,
            fiber: fiber * factor,
            giIndex: giIndex
        )
    }
}

struct BloodReading: Codable, Identifiable {
    var id: String = UUID().uuidString
    var userId : String?
    var type: BloodReadingType
    var value: Double
    var date: Date

    // Image name stored to load the correct image
    var imageName: String? {
        if value <= 120 {
            return "GoodImage"
        } else if value > 120 && value <= 180 {
            return "NeutralImage"
        } else {
            return "BadImage"
        }
    }

    // Computed property to return an Image based on imageName
    var image: Image {
        if let imageName = imageName {
            return Image(imageName)
        } else {
            return Image(systemName: "questionmark.circle") // Default fallback image
        }
    }

    // Explicit initializer
    init(id: String = UUID().uuidString, type: BloodReadingType, value: Double, date: Date) {
        self.id = id
        self.type = type
        self.value = value
        self.date = date
    }
}


enum BloodReadingType: String, Codable {
    case fasting = "Fasting"
    case preMeal = "Pre-Meal"
    case postMeal = "Post-Meal"
    case preWorkout = "Pre-Workout"
    case postWorkout = "Post-Workout"
}

enum MealType: String, Codable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snacks = "Snacks"
}

// Initialize UserId from UserDefaults if available
var UserId: String = UserDefaults.standard.string(forKey: "currentUserId") ?? ""

class UserManager : ObservableObject {
    static let shared = UserManager()

    var users: [User] = []
    private var recommendedMeals: [String: [Date: [Meal]]] = [:]
    @Published private var mealsByDate: [String: [String: [Meal]]] = [:]
    @Published private var readingsByDate: [String : [String: [BloodReading]]] = [:]
    private var activitiesByDate: [String: ActivityProgress] = [:]
    
    private init() {
        loadUsers() // Load users when initializing
    }
    
    private func loadUsers() {
        if let data = UserDefaults.standard.data(forKey: "savedUsers"),
           let decodedUsers = try? JSONDecoder().decode([User].self, from: data) {
            users = decodedUsers
        }
    }
    
    private func saveUsers() {
        if let encoded = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(encoded, forKey: "savedUsers")
        }
    }
    
    func addActivity(_ activity: ActivityProgress) {
            let dateKey = formatDate(activity.date)
            activitiesByDate[dateKey] = activity
        }

        func getActivity(for date: Date) -> ActivityProgress? {
            let dateKey = formatDate(date)
            return activitiesByDate[dateKey]
        }
    func differenceBetweenBloodSugar(for date: Date, userId: String) -> Double? {
        let calendar = Calendar.current
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: date) else { return nil }

        let yesterdayReadings = getReadings(for: yesterday, userId: userId)
        let todayReadings = getReadings(for: date, userId: userId)

        let yesterdayAverage = yesterdayReadings.isEmpty ? nil : yesterdayReadings.map { $0.value }.reduce(0, +) / Double(yesterdayReadings.count)
        let todayAverage = todayReadings.isEmpty ? nil : todayReadings.map { $0.value }.reduce(0, +) / Double(todayReadings.count)

        guard let yAvg = yesterdayAverage, let tAvg = todayAverage else {
            return nil  // Return nil if we don't have readings for both days
        }

        return tAvg - yAvg
    }

    func getAverage(for date: Date, userId: String) -> Double {
        let readings = getReadings(for: date, userId: userId)
        let values = readings.map { $0.value }
        return values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
    }


    
    func getRecommendedMeals(for date: Date, userID: String) -> [Meal] {
            let calendar = Calendar.current
            let normalizedDate = calendar.startOfDay(for: date)

            if recommendedMeals[userID] == nil {
                recommendedMeals[userID] = [:]  // ✅ Initialize per user
            }

            print("Fetching recommended meals for:", normalizedDate, "User:", userID)
            print("Stored meal dates for user:", recommendedMeals[userID]?.keys ?? [])

            if let meals = recommendedMeals[userID]?[normalizedDate] {
                print("Returning existing recommendations for:", normalizedDate)
                return meals
            }

            print("Generating new recommendations for:", normalizedDate)
            let newMeals = generateMealRecommendations(for: date, userID: userID)

            recommendedMeals[userID]?[normalizedDate] = newMeals

            return newMeals
        }
    
    
    
    func getDailyTips(for selectedDate: Date, userID: String) -> [Tip] {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: selectedDate) % 3  // Ensure rotation

        // Check if data exists for the selected date for the specific user
        let hasData = hasRelevantData(for: selectedDate, userID: userID)

        let allTips: [[Tip]] = [
            [
                Tip(imageName: "figure.walk",
                    title: "Take a Walk",
                    message: "Walking 10 minutes can boost your mood and lower blood sugar.",
                    actionText: "View Activity >",
                    destination: AnyView(HealthStatsView())),
                
                Tip(imageName: "drop.fill",
                    title: "HbA1c Alert",
                    message: "Great progress! Your HbA1c levels are improving. Keep it up!",
                    actionText: "Know More >",
                    destination: AnyView(HbA1cInfoView()))
            ],
            [
                Tip(imageName: "leaf.fill",
                    title: "Eat Greens",
                    message: "Adding greens to meals improves blood sugar stability.",
                    actionText: "Diet Tips >",
                    destination: AnyView(DietTipsView())),
                
                Tip(imageName: "moon.fill",
                    title: "Sleep Matters",
                    message: "A good night's sleep helps regulate insulin levels.",
                    actionText: "Improve Sleep >",
                    destination: AnyView(SleepTipsView()))
            ],
            [
                Tip(imageName: "bolt.heart",
                    title: "Stay Hydrated",
                    message: "Drinking water helps flush excess sugar from your system.",
                    actionText: "Hydration Guide >",
                    destination: AnyView(HydrationTipsView())),
                
                Tip(imageName: "list.clipboard",
                    title: "Track Meals",
                    message: "Logging meals helps spot patterns affecting glucose levels.",
                    actionText: "Log Meals >",
                    destination: AnyView(MealsView()))
            ]
        ]

        // If no data is available, show a "No tips available" message
        if !hasData {
            return [
                Tip(imageName: "exclamationmark.triangle.fill",
                    title: "No Tips Available",
                    message: "No data has been recorded for this day. Add meals or activities to get recommendations.",
                    actionText: "Log Data >",
                    destination: AnyView(MealsView()))
            ]
        }

        let index = day % allTips.count
        return allTips[index].shuffled()
    }

    func deleteReading(_ reading: BloodReading, for userId: String) {
        let dateKey = formatDate(reading.date)
        
        // Check if there are readings for the user and date
        if var userReadingsForDate = readingsByDate[userId]?[dateKey] {
            userReadingsForDate.removeAll { $0.id == reading.id }
            readingsByDate[userId]?[dateKey] = userReadingsForDate
            
            // Remove the date entry if no readings left for that user
            if userReadingsForDate.isEmpty {
                readingsByDate[userId]?.removeValue(forKey: dateKey)
                
                // If no more readings exist for this user, remove the user entry
                if readingsByDate[userId]?.isEmpty == true {
                    readingsByDate.removeValue(forKey: userId)
                }
            }
        }
    }

    private func generateMealRecommendations(for date: Date, userID: String) -> [Meal] {
        let lastMeal = getMeals(for: date, userID: userID).last  // Pass userID
        let activity = getActivity(for: date)  // Pass userID
        let bloodSugarReadings = getReadings(for: date, userId: userID)  // Pass userID
        let avgBloodSugar = bloodSugarReadings.map { $0.value }.reduce(0, +) / max(Double(bloodSugarReadings.count), 1.0)

        var meals: [Meal] = []

        if let lastMeal = lastMeal {
            let lastMealCarbs = lastMeal.totalNutrition.carbs

            if avgBloodSugar > 140 {
                meals.append(Meal(
                    userId: userID,  // Add userID
                    type: .dinner,
                    foodItems: [
                        FoodItem(name: "Grilled Salmon", quantity: 150, calories: 250, carbs: 5, fats: 10, proteins: 30, fiber: 2, giIndex: 30),
                        FoodItem(name: "Steamed Broccoli", quantity: 100, calories: 55, carbs: 10, fats: 0.5, proteins: 4, fiber: 5, giIndex: 15)
                    ],
                    date: date,
                    recipeURL: URL(string: "https://www.acouplecooks.com/grilled-salmon/")
                ))
            } else if lastMealCarbs > 50 {
                meals.append(Meal(
                    userId: userID,
                    type: .dinner,
                    foodItems: [
                        FoodItem(name: "Grilled Chicken Salad", quantity: 200, calories: 300, carbs: 15, fats: 12, proteins: 40, fiber: 5, giIndex: 25)
                    ],
                    date: date,
                    recipeURL: URL(string: "https://www.foodnetwork.com/recipes/food-network-kitchen/best-grilled-chicken-salad-19100929")
                ))
            } else if let activity = activity, activity.caloriesBurned ?? 0 > 300 {
                meals.append(Meal(
                    userId: userID,
                    type: .dinner,
                    foodItems: [
                        FoodItem(name: "Lean Beef Steak", quantity: 150, calories: 280, carbs: 0, fats: 15, proteins: 35, fiber: 0, giIndex: 0),
                        FoodItem(name: "Quinoa", quantity: 100, calories: 120, carbs: 21, fats: 2, proteins: 4, fiber: 3, giIndex: 53)
                    ],
                    date: date,
                    recipeURL: URL(string: "https://recipes.net/articles/how-to-cook-a-lean-steak/")
                ))
            } else {
                meals.append(Meal(
                    userId: userID,
                    type: .dinner,
                    foodItems: [
                        FoodItem(name: "Stir-Fried Tofu with Vegetables", quantity: 200, calories: 250, carbs: 20, fats: 8, proteins: 15, fiber: 6, giIndex: 30)
                    ],
                    date: date,
                    recipeURL: URL(string: "https://www.skinnytaste.com/tofu-stir-fry-with-vegetables-in-a-soy-sesame-sauce/")
                ))
            }
        }

        return meals
    }


    

    func addUser(_ user: User) {
        users.append(user)
        saveUsers() // Save after adding a user
    }

    func updateUser(_ updatedUser: User) {
        if let index = users.firstIndex(where: { $0.id == updatedUser.id }) {
            users[index] = updatedUser
            saveUsers() // Save after updating a user
        }
    }

    func getAllUsers() -> [User] {
        return users
    }

    func printAllUsers() {
        print("All users in UserManager:")
        for user in users {
            print("ID: \(user.id ?? "nil"), Name: \(user.name), Email: \(user.emailId)")
        }
    }

    // Function to add a meal
    func addMeal(_ meal: Meal, for userID: String) {
        let dateKey = formatDate(meal.date)

        if mealsByDate[userID] == nil {
            mealsByDate[userID] = [:]
        }

        if mealsByDate[userID]?[dateKey] == nil {
            mealsByDate[userID]?[dateKey] = []
        }

        mealsByDate[userID]?[dateKey]?.append(meal)
    }

    // Function to get meals for a specific date and user
    func getMeals(for date: Date, userID: String) -> [Meal] {
        let dateKey = formatDate(date)
        return mealsByDate[userID]?[dateKey] ?? []
    }

    
    
    func getCurrentUserName() -> String? {
        if let user = users.first(where: { $0.id == UserId }) {
            return user.name
        }
        return nil
    }

    // Function to add a reading
    func addBloodReading(_ reading: BloodReading, for userId: String) {
        let currentDate = Date()
        let dateKey = formatDate(reading.date)

        // Ensure the reading date is not in the future
        guard reading.date <= currentDate else {
            print("Error: Cannot add a future blood reading.")
            return
        }

        // Ensure there is a dictionary for the user
        if readingsByDate[userId] == nil {
            readingsByDate[userId] = [:]
        }

        // Ensure there is an array for the date key
        if readingsByDate[userId]?[dateKey] == nil {
            readingsByDate[userId]?[dateKey] = []
        }

        // Append the reading
        readingsByDate[userId]?[dateKey]?.append(reading)
        print("Added reading: \(reading.value) for \(userId) on \(dateKey)")
        
    }


    // Function to get readings for a specific date
    func getReadings(for date: Date, userId: String) -> [BloodReading] {
        let dateKey = formatDate(date)
        return (readingsByDate[userId]?[dateKey] ?? []).sorted { $0.date > $1.date }
    }


    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
   
    func getCaloriesConsumed(userId: String, date: Date) -> Double {
        let meals = UserManager.shared.getMeals(for: date, userID: userId)  // Pass userId correctly
        return meals.reduce(0) { $0 + $1.totalNutrition.calories }  // Use computed property instead of function call
    }

    func getStepsTaken(userId: String, date: Date) -> Int {
        // Fetch the steps count from stored data for the given date
        return activitiesByDate[formatDate(date)]?.totalSteps ?? 0

    }

    func getCarbsForDay(userID: String, date: Date) -> Double {
        let meals = getMeals(for: date, userID: userID)  // Pass userID
        return meals.reduce(0) { $0 + $1.totalNutrition.carbs }  // Use computed property
    }

    func getProteinForDay(userID: String, date: Date) -> Double {
        let meals = getMeals(for: date, userID: userID)
        return meals.reduce(0) { $0 + $1.totalNutrition.proteins }
    }

    func getFatForDay(userID: String, date: Date) -> Double {
        let meals = getMeals(for: date, userID: userID)
        return meals.reduce(0) { $0 + $1.totalNutrition.fats }
    }

    func getFiberForDay(userID: String, date: Date) -> Double {
        let meals = getMeals(for: date, userID: userID)
        return meals.reduce(0) { $0 + $1.totalNutrition.fiber }
    }

    private func hasRelevantData(for date: Date, userID: String) -> Bool {
        let meals = getMeals(for: date, userID: userID)  // Pass userID
        let activity = getActivity(for: date)  // Pass userID
        let bloodSugarReadings = getReadings(for: date, userId: userID)  // Pass userID

        return !meals.isEmpty || activity != nil || !bloodSugarReadings.isEmpty
    }


    func generateInformationalUserReport(userID: String, date: Date) -> String {
        var report = "Today's Report:\n"
        report += "Carbs: \(getCarbsForDay(userID: userID, date: date))\n"
        report += "Protein: \(getProteinForDay(userID: userID, date: date))\n"
        return report
    }
    private func loadDummyData() {
        // This function is kept for testing purposes but not called by default
        // You can call it manually when needed for testing
    }

    func calculateBMR(for user: User) -> Double {
        let weight = user.weight
        let height = user.height
        let age = Double(user.age)  // Convert age to Double
        
        // Calculate base components
        let weightComponent = 10 * weight
        let heightComponent = 6.25 * height
        let ageComponent = 5 * age
        
        // Calculate base BMR without gender adjustment
        let baseBMR = weightComponent + heightComponent - ageComponent
        
        // Apply gender-specific adjustments
        switch user.gender {
        case .male:
            return baseBMR + 5
        case .female:
            return baseBMR - 161
        case .other:
            // For other gender, use an average of male and female formulas
            let maleBMR = baseBMR + 5
            let femaleBMR = baseBMR - 161
            return (maleBMR + femaleBMR) / 2
        }
    }
    
    func calculateTDEE(for user: User) -> Double {
        let bmr = calculateBMR(for: user)
        let activityFactor: Double
        
        switch user.activityLevel {
        case .sedentary:
            activityFactor = 1.2
        case .active:
            activityFactor = 1.375
        case .moderateActive:
            activityFactor = 1.55
        case .veryActive:
            activityFactor = 1.725
        }
        
        return bmr * activityFactor
    }
    
    func calculateMacronutrientGoals(for user: User) -> (carbs: Double, protein: Double, fats: Double, fiber: Double) {
        let tdee = calculateTDEE(for: user)
        
        // Calculate macronutrient calories
        let carbCalories = tdee * 0.5  // 50% carbs
        let proteinCalories = tdee * 0.2  // 20% protein
        let fatCalories = tdee * 0.3  // 30% fats
        
        // Convert calories to grams
        // Carbs: 4 calories per gram
        // Protein: 4 calories per gram
        // Fats: 9 calories per gram
        let carbs = carbCalories / 4
        let protein = proteinCalories / 4
        let fats = fatCalories / 9
        
        // Calculate fiber (g) = (TDEE / 1000) × 14
        let fiber = (tdee / 1000) * 14
        
        return (carbs, protein, fats, fiber)
    }
    
    func getMacronutrientGoals(for userId: String) -> (carbs: Double, protein: Double, fats: Double, fiber: Double)? {
        guard let user = users.first(where: { $0.id == userId }) else {
            return nil
        }
        return calculateMacronutrientGoals(for: user)
    }
}
