//import SwiftUI
//
//struct FoodDetailView: View {
//    @State private var quantity: Double = 1.0
//    @State private var measure: String = "Piece"
//    let measures = ["Piece", "Gram", "Cup"]
//    let foodItem: FoodItem
//    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 16) {
//                Image("aloo_paratha") // Replace with dynamic images later
//                    .resizable()
//                    .scaledToFit()
//                    .cornerRadius(10)
//                    .padding(.horizontal)
//                
//                // Servings
//                Text("Servings")
//                    .font(.headline)
//                    .foregroundColor(.gray)
//                
//                HStack {
//                    // Quantity Selector
//                    VStack(alignment: .leading) {
//                        Text("Quantity")
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                        
//                        Stepper(value: $quantity, in: 0.5...10, step: 0.5) {
//                            Text("\(quantity, specifier: "%.1f")")
//                                .font(.title3)
//                                .bold()
//                        }
//                        
//                    }
//                    
//                    Spacer(minLength: 130)
//                    
//                    // Measure Selector
//                    VStack(alignment: .leading) {
//                        Text("Measure")
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                        Picker("Measure", selection: $measure) {
//                            ForEach(measures, id: \.self) {
//                                Text($0)
//                            }
//                        }
//                        .pickerStyle(MenuPickerStyle()) // Dropdown style
//                        .accentColor(.gray)
//                        .font(.title3).foregroundColor(.gray)
//                        .bold()
//                    }
//                }
//                
//                // Glycemic Index Section
//                Text("GI Index")
//                    .font(.headline)
//                    .foregroundColor(.gray)
//                
//                VStack(alignment: .leading, spacing: 8) {
//                    HStack {
//                        RoundedRectangle(cornerRadius: 8)
//                            .fill(Color.green.opacity(0.8))
//                            .frame(width: 40, height: 40)
//                            .overlay(Text("GI").foregroundColor(.white))
//                        
//                        Text("\(Int(foodItem.giIndex))")
//                            .font(.largeTitle)
//                            .fontWeight(.bold)
//                    }
//                    Text("Glycemic Index")
//                        .font(.headline)
//                    Text("It will take \(calculateBurningTime(calories: foodItem.calories)) minutes of running to burn \(Int(foodItem.calories)) calories.")
//                        .font(.body)
//                        .foregroundColor(.gray)
//                }
//                .padding()
//                .background(Color(.systemGray6))
//                .cornerRadius(10)
//                
//                // Macronutrient Breakdown
//                Text("Macronutrient Breakdown")
//                    .font(.headline)
//                    .foregroundColor(.gray)
//                
//                VStack(spacing: 8) {
//                    NutrientsRow(name: "Carbs", amount: "\(foodItem.carbs) g")
//                    NutrientsRow(name: "Protein", amount: "\(foodItem.proteins) g")
//                    NutrientsRow(name: "Fats", amount: "\(foodItem.fats) g")
//                    NutrientsRow(name: "Fiber", amount: "\(foodItem.fiber) g")
//                }
//                .padding()
//                .background(Color(.systemGray6))
//                .cornerRadius(10)
//                
//            }
//            .padding()
//        }
//        .navigationTitle(foodItem.name)
//        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button(action: {
//                    saveFoodDetails()
//                }) {
//                    Text("Save")
//                        .font(.headline)
//                        .foregroundColor(.blue)
//                }
//            }
//        }
//    }
//    
//    private func saveFoodDetails() {
//        print("Food details saved: \(foodItem.name), Quantity: \(quantity), Measure: \(measure)")
//    }
//    
//    private func calculateBurningTime(calories: Double) -> Int {
//        return Int(calories / 10) * 5 // Example: 5 minutes per 10 calories burned
//    }
//}
//
//struct FoodDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        FoodDetailView(foodItem: FoodItem(name: "Aloo Paratha", quantity: 1.0, calories: 400, carbs: 73, fats: 21, proteins: 19, fiber: 9, giIndex: 80))
//    }
//    
//}
//
//struct NutrientsRow: View {
//    let name: String
//    let amount: String
//    
//    var body: some View {
//        HStack {
//            Text(name)
//                .font(.body)
//                .foregroundColor(.primary)
//            Spacer()
//            Text(amount)
//                .font(.body)
//                .foregroundColor(.secondary)
//        }
//        .padding(.vertical, 4)
//    }
//}
