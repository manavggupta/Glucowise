//
//  Supabasemanager.swift
//  glucoWise
//
//  Created by Manav Gupta on 10/04/25.
//



import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://cbcmbvlinobknzpyfnry.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNiY21idmxpbm9ia256cHlmbnJ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxNzcxOTcsImV4cCI6MjA1OTc1MzE5N30._SL5VSc17L6eSFM5t4SZ6UzoCZNRyqrRQWlGr22VXqI"
        )
    }
    func fetchUser(withId userId: String) async throws -> User {
        let response = try await supabase
            .from("users")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
        
        let user = try JSONDecoder().decode(User.self, from: response.data)
        return user
    }




    
}
