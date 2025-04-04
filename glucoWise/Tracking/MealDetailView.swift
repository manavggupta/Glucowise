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
                                NutrientBarView(nutrient: "Carbs", value: Int(nutrients.carbs), maxValue: 105, color: .green)
                                NutrientBarView(nutrient: "Protein", value: Int(nutrients.proteins), maxValue: 25, color: .yellow)
                                NutrientBarView(nutrient: "Fats", value: Int(nutrients.fats), maxValue: 21, color: .red)
                                NutrientBarView(nutrient: "Fiber", value: Int(nutrients.fiber), maxValue: 10, color: .green)
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

struct NutrientBarView: View {
    var nutrient: String
    var value: Int
    var maxValue: Int
    var color: Color
    
    var body: some View {
        VStack{
            HStack{
                Text(nutrient).font(.subheadline)
                Spacer()
                Text("\(value)/\(maxValue)").font(.caption).foregroundColor(.gray)
            }
            HStack{
                Spacer()
                ProgressView(value: Double(value), total: Double(maxValue))
                .accentColor(color).frame(width: 120, height: 10)}
        }
    }
}

struct MealDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MealDetailView(mealType: "Breakfast", selectedDate: Date())
    }
}
