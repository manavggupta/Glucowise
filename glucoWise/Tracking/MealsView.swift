import SwiftUI

struct MealsView: View {
    @State private var selectedCategory = "Meals"
    @State private var selectedDate = Date()
    @State private var showMealsSection = false
    @State private var selectedMeal: String? = nil
    @State private var navigateToSearch = false
    @State private var selectedMealType: String? = nil
    @AppStorage("currentUserId") var userId: String = ""
    @ObservedObject var userManager = UserManager.shared
    
    
    var currentWeek: [Date] {
        let calendar = Calendar(identifier: .iso8601)
        let today = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: -$0, to: Date()) }.reversed()
    }
    

    var body: some View {
  
            VStack(alignment: .leading) {
                // MARK: - Week Date Picker
                VStack {
                    HStack {
                        ForEach(currentWeek, id: \.self) { date in
                            let isFutureDate = date > Date()
                            let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                            
                            Button(action: {
                                if !isFutureDate {
                                    selectedDate = date
                                }
                            }) {
                                VStack {
                                    Text(dateFormatter.string(from: date))
                                        .font(.footnote)
                                        .foregroundColor(.black)
                                    
                                    Text(dateNumberFormatter.string(from: date))
                                        .frame(width: 40, height: 40)
                                        .background(isSelected ? Color(hex: "#6cab9c") : Color(.systemGray5))
                                        .clipShape(Circle())
                                        .foregroundColor(isSelected ? .white : (isFutureDate ? .gray : .black))
                                    
                                }
                            }
                            .disabled(isFutureDate)
                        }
                    }
                    .frame(maxWidth: .infinity,maxHeight : 50)
                    
                    .padding(.horizontal)
                    .padding(.vertical, 25)
                    .background(Color.white)
                    .cornerRadius(30)
                }
                .background(Color.white)
               
                

                // MARK: - List with Tracked Food and Macros
                List {
                    Section(header: HStack {
                        Text("Tracked Food").foregroundColor(.gray)
                        Spacer()
                        Button(action: {
                            showMealsSection = true
                        }) {
                            Text("Add meal")
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                                .background(Color(hex: "#6cab9c"))
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }) {
                        ForEach(["Breakfast", "Lunch", "Snacks", "Dinner"], id: \.self) {meal in
                            NavigationLink(
                                destination: MealDetailView(mealType: meal,selectedDate : selectedDate),
                                tag: meal,
                                selection: $selectedMealType
                            ) {
                                Text(meal)
                                    .onTapGesture {
                                        selectedMealType = meal
                                    }
                            }
                        }
                    }
                    
                    
                    Section(header: Text("Macronutrient Breakdown").foregroundColor(.gray)) {
                        NutrientRow(name: "Carbs", current: Int(userManager.getCarbsForDay(userID: userId, date: selectedDate)))
                        NutrientRow(name: "Protein", current: Int(userManager.getProteinForDay(userID: userId, date: selectedDate)))
                        NutrientRow(name: "Fats", current: Int(userManager.getFatForDay(userID: userId, date: selectedDate)))
                        NutrientRow(name: "Fiber", current: Int(userManager.getFiberForDay(userID: userId, date: selectedDate)))

                    }
                }
                .listStyle(InsetGroupedListStyle())
                .actionSheet(isPresented: $showMealsSection) {
                    ActionSheet(
                        title: Text("Meal Type"),
                        buttons: [
                            .default(Text("Breakfast")) { selectMeal("Breakfast") },
                            .default(Text("Snacks")) { selectMeal("Snacks") },
                            .default(Text("Lunch")) { selectMeal("Lunch") },
                            .default(Text("Dinner")) { selectMeal("Dinner") },
                            .cancel()
                        ]
                    )
                }
                NavigationLink(destination: SearchFoodView(mealType: selectedMeal ?? "", selecteddate: selectedDate), isActive: $navigateToSearch) {
                                    EmptyView()
                                }
            }
            
        }
    
    
    private func selectMeal(_ meal: String) {
            selectedMeal = meal
            navigateToSearch = true
        }
}

// MARK: - Nutrient Row Component
struct NutrientRow: View {
    let name: String
    let current: Int
    @AppStorage("currentUserId") var userId: String = ""
    
    var total: Int {
        if let goals = UserManager.shared.getMacronutrientGoals(for: userId) {
            switch name {
            case "Carbs":
                return Int(goals.carbs)
            case "Protein":
                return Int(goals.protein)
            case "Fats":
                return Int(goals.fats)
            case "Fiber":
                return Int(goals.fiber)
            default:
                return 0
            }
        }
        return 0
    }
    
    var color: Color {
        let ratio = Double(current) / Double(total)
        if ratio > 1.0 { return .red }
        else if ratio >= 0.8 { return .green }
        else { return .orange }
    }
    
    var body: some View {
        HStack {
            Text(name)
            Spacer()
            Text("\(current)/\(total) g")
                .font(.subheadline)
                .foregroundColor(.gray)
            ProgressView(value: Double(current), total: Double(total))
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .frame(width: 100)
        }
    }
}

struct MacronutrientBreakdown: View {
    @AppStorage("currentUserId") var userId: String = ""
    let meals: [Meal]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Macronutrient Breakdown")
                .font(.headline)
            
            if let goals = UserManager.shared.getMacronutrientGoals(for: userId) {
                let totalNutrition = meals.reduce((carbs: 0.0, proteins: 0.0, fats: 0.0, fiber: 0.0)) { result, meal in
                    let nutrition = meal.totalNutrition
                    return (
                        carbs: result.carbs + nutrition.carbs,
                        proteins: result.proteins + nutrition.proteins,
                        fats: result.fats + nutrition.fats,
                        fiber: result.fiber + nutrition.fiber
                    )
                }
                
                NutrientRow(name: "Carbs", current: Int(totalNutrition.carbs))
                NutrientRow(name: "Protein", current: Int(totalNutrition.proteins))
                NutrientRow(name: "Fats", current: Int(totalNutrition.fats))
                NutrientRow(name: "Fiber", current: Int(totalNutrition.fiber))
            } else {
                Text("Unable to calculate macronutrient goals")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Date Formatters
let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "E"
    return formatter
}()

let dateNumberFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "d"
    return formatter
}()

// MARK: - SwiftUI Preview
struct MealsView_Previews: PreviewProvider {
    static var previews: some View {
        MealsView()
    }
}
