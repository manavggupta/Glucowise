//
//  HbA1cInfoView.swift
//  glucoWise
//
//  Created by Harnoor Kaur on 3/25/25.
//


import SwiftUI

struct HbA1cInfoView: View {
    var body: some View {
        ZStack {
            Color(.systemGray6) // Background color
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 16) {
                
                // Title
                Text("HbA1c")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                
                // Information Section
                VStack(alignment: .leading, spacing: 12) {
                    HbA1cInfoSection(title: "What is HbA1c?", text: "HbA1c, also known as glycated hemoglobin, is a form of hemoglobin that is measured primarily to identify the average plasma glucose concentration over prolonged periods of time. It is formed in a non-enzymatic glycation pathway by hemoglobin’s exposure to plasma glucose.")
                    
                    HbA1cInfoSection(title: "Why it's important", text: "It’s an indicator of how well you’re managing your diabetes. The higher your blood sugar levels are, the more hemoglobin you’ll have with sugar attached. In general, an A1C level below 5.7 percent is considered normal.")
                    
                    HbA1cInfoSection(title: "Understanding your results", text: "The higher your HbA1c, the greater your risk of developing complications from diabetes. For most people who have diabetes, the American Diabetes Association recommends aiming for an A1c of 7% or lower.")
                }
                
                Spacer()
                
            }
            .padding()
            .background(Color("#6cab9c"))
            .cornerRadius(20)
            .padding()
        }
    }
}

// Reusable Info Section
struct HbA1cInfoSection: View {
    var title: String
    var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
    }
}

// Preview
struct HbA1cInfoView_Previews: PreviewProvider {
    static var previews: some View {
        HbA1cInfoView()
    }
}
