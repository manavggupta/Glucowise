//
//  MealDetailView.swift
//  glucoWise
//
//  Created by Harnoor Kaur on 3/17/25.
//
import SwiftUI

struct MealDetailView: View {
    var mealType: String
    var selectedDate: Date
    @AppStorage("currentUserId") var userId: String = ""
    var mealsChosen: [Meal] {
        UserManager.shared.getMeals(for: selectedDate, userID: userId)
    }
    
    var filteredMeals: [Meal] {
        mealsChosen.filter { $0.type.rawValue.lowercased() == mealType.lowercased() }
    }
   
    var body: some View {
        NavigationView {
            VStack {
                if filteredMeals.isEmpty {
                    VStack {
                        Text("No meals added for \(mealType).")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Tap below to add a meal.")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    .padding()
                } else {
                    List {
                        Section(header: Text("Tracked Food")) {
                            ForEach(filteredMeals.flatMap { $0.foodItems }, id: \.self) { food in
                                FoodItemView(name: food.name, quantity: food.quantity, calories: food.calories)
                            }
                        }
                        
                        if let nutrients = filteredMeals.first?.totalNutrition {
                            Section(header: Text("Glycemic Indicators")) {
                                HStack {
                                    GlycemicIndicatorView(value: Int(nutrients.giIndex), label: "Glycemic Index")
                                    Spacer()
                                    GlycemicIndicatorView(value: Int(nutrients.glIndex), label: "Glycemic Load")
                                }
                            }
                            
                            Section(header: Text("Macronutrient Breakdown")) {
                                NutrientRows(name: "Carbs", current: Int(nutrients.carbs), mealType: mealType)
                                NutrientRows(name: "Protein", current: Int(nutrients.proteins), mealType: mealType)
                                NutrientRows(name: "Fats", current: Int(nutrients.fats), mealType: mealType)
                                NutrientRows(name: "Fiber", current: Int(nutrients.fiber), mealType: mealType)
                            }
                        }
                    }
                }
            }
            .navigationTitle(mealType)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct FoodItemView: View {
    var name: String
    var quantity: Double
    var calories: Double?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(name).font(.headline)
                Text("\(String(format: "%.1f", quantity)) g").font(.subheadline).foregroundColor(.gray)
            }
            Spacer()
            if let calories = calories {
                Text("\(String(format : "%.1f", calories)) Cal").font(.subheadline)
            }
        }
    }
}

struct GlycemicIndicatorView: View {
    var value: Int
    var label: String
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 6) // Full grey background
                
                Circle()
                    .trim(from: 0, to: CGFloat(value) / 100)
                    .stroke(Color.green, lineWidth: 6) // Highlighted progress
                    .rotationEffect(.degrees(-90)) // Rotates to start from the top
                
                Text("\(value)").font(.title2) // Overlay text
            }.frame(width: 80, height: 80)

               
            Spacer()
            Text(label).font(.footnote)
        }.padding()
    }
}

struct NutrientRows: View {
    let name: String
    let current: Int
    let mealType: String
    @AppStorage("currentUserId") var userId: String = ""
    
    var total: Int {
        if let goals = UserManager.shared.getMacronutrientGoals(for: userId) {
            let mealPercentage: Double
            switch mealType {
            case "Breakfast":
                mealPercentage = 0.25
            case "Lunch":
                mealPercentage = 0.35
            case "Snacks":
                mealPercentage = 0.15
            case "Dinner":
                mealPercentage = 0.25
            default:
                mealPercentage = 0.0
            }
            
            switch name {
            case "Carbs":
                return Int(goals.carbs * mealPercentage)
            case "Protein":
                return Int(goals.protein * mealPercentage)
            case "Fats":
                return Int(goals.fats * mealPercentage)
            case "Fiber":
                return Int(goals.fiber * mealPercentage)
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

struct MealDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MealDetailView(mealType: "Breakfast", selectedDate: Date())
    }
}
