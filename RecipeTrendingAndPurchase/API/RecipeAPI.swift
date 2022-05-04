//
//  RecipeAPI.swift
//  RecipeTrendingAndPurchase
//
//  Created by Elmer Almeida on 2022-04-18.
//

import Foundation

struct RecipeAPIObject: Codable {
    let id: Int
    let user_id: Int
    let name: String
    let price: Double
    let ingredients: String
    let details: String
    let img: String
    let likes: Int
}

final class RecipeAPI {
    
    // ensure shared instance
    static let shared = RecipeAPI()
    
    var RecipeAPIUrl: String? = nil
    
    func fetchRecipeList(onCompletion: @escaping ([RecipeAPIObject]) -> ()) {
        RecipeAPIUrl = "http://localhost:5000/api/recipes/all"
        let recipeURL = URL(string: RecipeAPIUrl!)
        
        let task = URLSession.shared.dataTask(with: recipeURL!) { (data, response, error) in
            guard let data = data else {
                print("No data was recieved.")
                return
            }
            
            guard let recipeList: [RecipeAPIObject] = try? JSONDecoder().decode([RecipeAPIObject].self, from: data) else {
                print("Couldn't decode the JSON response")
                return
            }
            
            print("The number of recipes recieved is: \(recipeList.count)")
            onCompletion(recipeList)
        }
        
        task.resume()
    }
    
}
