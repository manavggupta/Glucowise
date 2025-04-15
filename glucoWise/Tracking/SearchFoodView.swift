import SwiftUI
import Combine

struct SearchFoodView: View {
    let mealType: String
    let selecteddate: Date
    @StateObject private var viewModel = FoodSearchViewModel()
    @State private var selectedFood: String?  // State variable to track selection
    
    var body: some View {
        VStack(spacing: 0) {
            SearchBar(viewModel: viewModel)
                .padding(.top, 8)
            
            if viewModel.isLoading {
                ProgressView()
                    .padding(.top, 20)
            } else if viewModel.foodResults.isEmpty && !viewModel.searchText.isEmpty {
                ContentUnavailableView.search(text: viewModel.searchText)
            }
            
            List(viewModel.foodResults, id: \.self) { food in
                NavigationLink(destination: SelectedFoodDetailView(foodName: food,selectedMealType: MealType(rawValue: mealType) ?? .breakfast, selecteddate: selecteddate)) {
                    FoodRow(name: food)
                }
            }
            .listStyle(.plain)
            .animation(.default, value: viewModel.foodResults)
        }
        .navigationTitle("Search \(mealType.capitalized)")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .navigationDestination(for: String.self) { food in
            SelectedFoodDetailView(foodName: food, selectedMealType: MealType(rawValue: mealType) ?? .breakfast, selecteddate: selecteddate) // Navigate to detail view
        }
        .onChange(of: selectedFood) { newValue in
            if let food = newValue {
                selectedFood = nil  // Reset after navigation
            }
        }
    }
}

struct FoodRow: View {
    let name: String
    
    var body: some View {
        HStack {
            Text(name.capitalized)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

struct SearchBar: View {
    @ObservedObject var viewModel: FoodSearchViewModel
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search \(viewModel.mealType.lowercased())...", text: $viewModel.searchText)
                    .focused($isFocused)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .foregroundColor(.primary)
                
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            if isFocused {
                Button("Cancel") {
                    isFocused = false
                    viewModel.searchText = ""
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .foregroundColor(.blue)
                .transition(.move(edge: .trailing))
            }
        }
        .padding(.horizontal)
        .animation(.default, value: isFocused)
    }
}

class FoodSearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var foodResults: [String] = []
    @Published var isLoading = false
    @Published var mealType: String
    
    private var cancellables = Set<AnyCancellable>()
    private var appID = "49219ebc"
    private let apiKey = "e2d5d197d5b45aea88bea1b99c5317e6"
    
    init(mealType: String = "food") {
        self.mealType = mealType
        
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                if !text.isEmpty {
                    self?.fetchFoodResults(query: text)
                } else {
                    self?.foodResults = []
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchFoodResults(query: String) {
        isLoading = true
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        let urlString = "https://trackapi.nutritionix.com/v2/search/instant?query=\(encodedQuery)"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.addValue(appID, forHTTPHeaderField: "x-app-id")
        request.addValue(apiKey, forHTTPHeaderField: "x-app-key")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: NutritionixResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("API Error: \(error)")
                }
            }, receiveValue: { [weak self] response in
                self?.foodResults = response.common.map { $0.food_name }
            })
            .store(in: &cancellables)
    }
}

struct NutritionixResponse: Codable {
    let common: [FoodItems]
}

struct FoodItems: Codable {
    let food_name: String
}

struct SearchFoodView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SearchFoodView(mealType: "Breakfast", selecteddate: Date()  )
        }
    }
}
