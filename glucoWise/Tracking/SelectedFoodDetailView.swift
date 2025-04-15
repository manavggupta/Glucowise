import SwiftUI

struct SelectedFoodDetailView: View {
    let foodName: String
    var selectedMealType: MealType
    @AppStorage("currentUserId") var userId: String = ""
    @Environment(\.dismiss) private var dismiss
    let selecteddate: Date
    @State private var foodItem: FoodItem?
    @State private var quantity: Double = 1.0
    @State private var measure: String = "Piece"
    @State private var measures: [String] = ["Piece"]
    @State private var altMeasures: [AltMeasure] = []
    @State private var baseNutrients: FoodDetail?

    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let food = foodItem {
                    Image("aloo_paratha") // Replace with dynamic images later
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .frame(maxWidth : .infinity, maxHeight : 200)
                        
                    
                    // Servings
                    Text("Servings")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Quantity")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Stepper(value: $quantity, in: 0.5...10, step: 0.5) {
                                Text("\(quantity, specifier: "%.1f")")
                                    .font(.title3)
                                    .bold()
                            }
                            .onChange(of: quantity) { _ in
                                updateNutrients()
                            }
                        }
                        
                        Spacer(minLength: 130)
                        
                        VStack(alignment: .leading) {
                            Text("Measure")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Picker("Measure", selection: $measure) {
                                ForEach(measures, id: \.self) {
                                    Text($0)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .onChange(of: measure) { _ in
                                updateNutrients()
                            }
                        }
                    }

                    // Glycemic Index Section
                    Text("GI Index")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.green.opacity(0.8))
                                .frame(width: 40, height: 40)
                                .overlay(Text("GI").foregroundColor(.white))
                            
                            Text("\(Int(food.giIndex))")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text(giLevel(for: food.giIndex))
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(giLevelColor(for: food.giIndex).opacity(0.2))
                                .foregroundColor(giLevelColor(for: food.giIndex))
                                .clipShape(Capsule())
                        }
                        Text("Glycemic Index")
                            .font(.headline)
                        Text("It will take \(calculateBurningTime(calories: food.calories)) minutes of running to burn \(Int(food.calories)) calories.")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                    // Macronutrient Breakdown
                    Text("Macronutrient Breakdown")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    VStack(spacing: 8) {
                        NutrientsRow(name: "Carbs", amount: "\(String(format: "%.1f", food.carbs)) g")
                        NutrientsRow(name: "Protein", amount: "\(String(format: "%.1f", food.proteins)) g")
                        NutrientsRow(name: "Fats", amount: "\(String(format: "%.1f", food.fats)) g")
                        NutrientsRow(name: "Fiber", amount: "\(String(format: "%.1f", food.fiber)) g")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                } else {
                    Text("Loading food details...")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle(foodName)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
            Button(action: {
                // Save the selected food item to UserManager and Supabase
                if let currentFood = foodItem {
                    let finalFoodItem = FoodItem(
                        name: currentFood.name,
                        quantity: quantity,
                        calories: currentFood.calories,
                        carbs: currentFood.carbs,
                        fats: currentFood.fats,
                        proteins: currentFood.proteins,
                        fiber: currentFood.fiber,
                        giIndex: currentFood.giIndex,
                        measure: measure
                    )
                    
                    // Create a new meal with the selected food item
                    let newMeal = Meal(
                        type: selectedMealType,
                        foodItems: [finalFoodItem],
                        date: selecteddate,
                        recipeURL: nil
                    )
                    
                    // Add the meal to UserManager
                    UserManager.shared.addMeal(newMeal, for: userId)
                    
                    // Save to Supabase
                    Task {
                        do {
                            try await SupabaseManager.shared.saveMeal(
                                userId: userId,
                                type: selectedMealType.rawValue,
                                date: selecteddate,
                                foodItems: [finalFoodItem]
                            )
                            print("Successfully saved meal to Supabase")
                        } catch {
                            print("Error saving to Supabase: \(error)")
                        }
                    }
                    
                    // Post notification to refresh parent view
                    NotificationCenter.default.post(name: NSNotification.Name("MealAdded"), object: nil)
                }
                
                // Dismiss the view
                dismiss()
            }) {
                Text("Done")
                    .fontWeight(.semibold)
            }
        )
        .onAppear {
            fetchFoodDetails()
        }
    }
    
    // ... (rest of the implementation remains the same as in the previous artifact)

    
    private func fetchFoodDetails() {
        let url = URL(string: "https://trackapi.nutritionix.com/v2/natural/nutrients")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("49219ebc", forHTTPHeaderField: "x-app-id")
        request.addValue("e2d5d197d5b45aea88bea1b99c5317e6", forHTTPHeaderField: "x-app-key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = ["query": foodName]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching food details:", error?.localizedDescription ?? "Unknown error")
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(NutritionixDetailResponse.self, from: data)
                DispatchQueue.main.async {
                    if let food = decodedResponse.foods.first {
                        // Store base nutrients for later calculations
                        self.baseNutrients = food
                        
                        // Extract alternative measures
                        self.altMeasures = food.alt_measures ?? []
                        
                        // Populate measures
                        var availableMeasures = [food.serving_unit]
                        availableMeasures.append(contentsOf: altMeasures.map { $0.measure })
                        self.measures = Array(Set(availableMeasures))
                        
                        // Set initial measure
                        self.measure = food.serving_unit
                        
                        // Create initial food item
                        self.foodItem = FoodItem(
                            name: food.food_name,
                            quantity: food.serving_qty,
                            calories: food.nf_calories,
                            carbs: food.nf_total_carbohydrate,
                            fats: food.nf_total_fat,
                            proteins: food.nf_protein,
                            fiber: food.nf_dietary_fiber,
                            giIndex: calculateEstimatedGI(
                                carbs: food.nf_total_carbohydrate,
                                fiber: food.nf_dietary_fiber,
                                fats: food.nf_total_fat,
                                protein: food.nf_protein
                            ),
                            measure: food.serving_unit
                        )

                    }
                }
            } catch {
                print("Failed to decode response:", error.localizedDescription)
            }
        }.resume()
    }
    
    private func updateNutrients() {
        guard let baseNutrients = baseNutrients else { return }
        
        // Find the matching alternative measure
        let selectedAltMeasure = altMeasures.first { $0.measure == measure }
        
        // Calculate nutrient multiplier
        let nutrientMultiplier: Double
        if let altMeasure = selectedAltMeasure {
            // Use alternative measure serving weight
            nutrientMultiplier = (altMeasure.serving_weight * quantity) / (baseNutrients.serving_weight_grams * baseNutrients.serving_qty)
        } else {
            // Use default serving when no alternative measure is found
            nutrientMultiplier = quantity / baseNutrients.serving_qty
        }
        
        // Update food item with scaled nutrients
        self.foodItem = FoodItem(
            name: baseNutrients.food_name,
            quantity: quantity,
            calories: baseNutrients.nf_calories * nutrientMultiplier,
            carbs: baseNutrients.nf_total_carbohydrate * nutrientMultiplier,
            fats: baseNutrients.nf_total_fat * nutrientMultiplier,
            proteins: baseNutrients.nf_protein * nutrientMultiplier,
            fiber: baseNutrients.nf_dietary_fiber * nutrientMultiplier,
            giIndex: calculateEstimatedGI(
                carbs: baseNutrients.nf_total_carbohydrate * nutrientMultiplier,
                fiber: baseNutrients.nf_dietary_fiber * nutrientMultiplier,
                fats: baseNutrients.nf_total_fat * nutrientMultiplier,
                protein: baseNutrients.nf_protein * nutrientMultiplier
            ), measure: measure
 // Placeholder
        )
    }

    private func calculateBurningTime(calories: Double) -> Int {
        return Int(calories / 10) * 5
    }
    private func calculateEstimatedGI(carbs: Double, fiber: Double, fats: Double, protein: Double) -> Double {
        let baseCarbEffect = 70 + (0.5 * carbs)
        let fiberEffect = 1.0 * fiber
        let fatEffect = 0.6 * fats
        let proteinEffect = 0.5 * protein
        
        let rawGI = baseCarbEffect - fiberEffect - fatEffect - proteinEffect
        return max(0, min(100, rawGI))  // Clamp GI between 0 and 100
    }
    private func giLevel(for giValue: Double) -> String {
        switch giValue {
        case 0..<55:
            return "Low"
        case 55..<70:
            return "Medium"
        default:
            return "High"
        }
    }

    private func giLevelColor(for giValue: Double) -> Color {
        switch giValue {
        case 0..<55:
            return .green
        case 55..<70:
            return .orange
        default:
            return .red
        }
    }


}

// Existing structs remain the same as in the previous implementation

// Updated Structs for API Response
struct NutritionixDetailResponse: Codable {
    let foods: [FoodDetail]
}

struct FoodDetail: Codable {
    let food_name: String
    let serving_qty: Double
    let serving_unit: String
    let serving_weight_grams: Double
    let nf_calories: Double
    let nf_total_carbohydrate: Double
    let nf_total_fat: Double
    let nf_protein: Double
    let nf_dietary_fiber: Double
    let alt_measures: [AltMeasure]?
}

struct AltMeasure: Codable {
    let measure: String
    let serving_weight: Double
}



// Nutrient Row View remains the same
struct NutrientsRow: View {
    let name: String
    let amount: String

    var body: some View {
        HStack {
            Text(name)
                .font(.body)
                .foregroundColor(.primary)
            Spacer()
            Text(amount)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// Preview
struct SelectedFoodDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SelectedFoodDetailView(foodName: "Aloo Paratha", selectedMealType: .breakfast, selecteddate: Date())
    }
}
