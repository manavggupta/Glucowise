//
//  MealsModel.swift
//  glucoWise
//
//  Created by Manav Gupta on 10/04/25.
//

import Foundation



struct Meal: Identifiable, Hashable, Encodable {
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
    var measure : String?
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
            giIndex: giIndex,
            measure: measure
        )
    }
}
