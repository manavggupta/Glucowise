//
//  Supabasemanager.swift
//  glucoWise
//
//  Created by Manav Gupta on 10/04/25.
//



import Foundation
import Supabase

// Add MealData struct for encoding
struct MealData: Encodable {
    let user_id: String
    let type: String
    let date: Date
    let food_items: [FoodItem]
    let recipeurl: String?
}

class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://cbcmbvlinobknzpyfnry.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNiY21idmxpbm9ia256cHlmbnJ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxNzcxOTcsImV4cCI6MjA1OTc1MzE5N30._SL5VSc17L6eSFM5t4SZ6UzoCZNRyqrRQWlGr22VXqI"
        )
    }
    
    //fetch user
    func fetchUser(withId userId: String) async throws -> User {
        let response = try await client
            .from("users")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
        
        let user = try JSONDecoder().decode(User.self, from: response.data)
        return user
    }
    
    //save fooditem
    func saveMeal(userId: String, type: String, date: Date, foodItems: [FoodItem], recipeURL: String? = nil) async throws {
        let mealData = MealData(
            user_id: userId,
            type: type,
            date: date,
            food_items: foodItems,
            recipeurl: recipeURL
        )
        
        try await client
            .from("meals")
            .insert(mealData)
            .execute()
    }
    
    
    
    
    




    
}
