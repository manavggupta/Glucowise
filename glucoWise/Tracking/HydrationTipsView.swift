//
//  HydrationTipsView.swift
//  glucoWise
//
//  Created by Harnoor Kaur on 3/25/25.
//


import SwiftUI

struct HydrationTipsView: View {
    var body: some View {
        List {
            Section {
                HStack(alignment: .center, spacing: 10) {
                    Text("Stay Hydrated🌊")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    Image("hydration_tips")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .padding(.top, 5).frame(height:70)
                }
                .padding(.bottom, 10)
            }
            
            Section(header: Text("Essential Hydration Tips").font(.headline)) {
                TipRow(emoji: "🥤", title: "Drink Regularly", detail: "Aim for at least 8 glasses of water daily to keep your body hydrated.")
                
                TipRow(emoji: "⏰", title: "Set Reminders", detail: "Use alarms or apps to remind you to drink water throughout the day.")
                
                TipRow(emoji: "🍉", title: "Eat Hydrating Foods", detail: "Include fruits and veggies like watermelon and cucumber in your diet for extra hydration.")
                
                TipRow(emoji: "🚴", title: "Hydrate During Exercise", detail: "Drink water before, during, and after workouts to replenish lost fluids.")
                
                TipRow(emoji: "🍵", title: "Balance Fluids", detail: "Not just water—herbal teas and natural juices also contribute to hydration.")
            }
        }
        .navigationTitle("Hydration Tips")
    }
}

// Reusable TipRow Component
struct TipRow: View {
    let emoji: String
    let title: String
    let detail: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(emoji)
                .font(.title)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 5)
    }
}

// Preview
struct HydrationTipsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HydrationTipsView()
        }
    }
}
