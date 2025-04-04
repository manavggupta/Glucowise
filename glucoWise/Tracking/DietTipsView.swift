//
//  DietTipsView.swift
//  glucoWise
//
//  Created by Harnoor Kaur on 3/25/25.
//


import SwiftUI

struct DietTipsView: View {
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Healthy Eating Tips")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Image("diet_tips")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .padding(.top, 5)
                }
                .padding(.bottom, 10)
            }
            
            Section(header: Text("Key Nutrition Tips").font(.headline)) {
                DietTipRow(emoji: "🥦", title: "Include More Fiber", detail: "Eating more fiber helps regulate blood sugar levels and improves digestion.")
                
                DietTipRow(emoji: "🍗", title: "Balance Carbs & Proteins", detail: "Pairing proteins with carbohydrates can prevent sugar spikes and provide steady energy.")
                
                DietTipRow(emoji: "🚫", title: "Limit Processed Foods", detail: "Avoid processed foods that contain added sugars, which can cause glucose spikes.")
            }
        }
        .navigationTitle("Diet Tips")
    }
}

struct DietTipRow: View {
    let emoji: String
    let title: String
    let detail: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(emoji)
                .font(.largeTitle)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

struct DietTipsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DietTipsView()
        }
    }
}
