//
//  SleepTipsView.swift
//  glucoWise
//
//  Created by Harnoor Kaur on 3/25/25.
//


import SwiftUI

struct SleepTipsView: View {
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Better Sleep Habits")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Image("sleep_tips")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .padding(.top, 5)
                }
                .padding(.bottom, 10)
            }
            
            Section(header: Text("Key Sleep Tips").font(.headline)) {
                TipRow(emoji: "🌙", title: "Stick to a Routine", detail: "Go to bed and wake up at the same time daily to regulate your body's internal clock.")
                
                TipRow(emoji: "📴", title: "Limit Screen Time", detail: "Avoid screens 30 minutes before bed to reduce blue light exposure and improve sleep quality.")
                
                TipRow(emoji: "🥦", title: "Watch Your Diet", detail: "Avoid caffeine and heavy meals before bed as they can disrupt your sleep cycle.")
                
                TipRow(emoji: "🛏️", title: "Optimize Sleep Environment", detail: "Keep your bedroom dark, quiet, and cool for better sleep quality.")
                
                TipRow(emoji: "🧘", title: "Relax Before Bed", detail: "Try meditation or reading to help your body wind down before sleeping.")
            }
        }
        .navigationTitle("Sleep Tips")
    }
}

struct SleepTipsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SleepTipsView()
        }
    }
}
