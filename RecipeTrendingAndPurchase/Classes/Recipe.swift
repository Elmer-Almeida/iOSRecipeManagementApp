//
//  Recipe.swift
//  RecipeTrendingAndPurchase
//
//  Created by Elmer Almeida on 2022-04-18.
//

import UIKit

class Recipe: NSObject {
    var id: Int?
    var user_id: Int?
    var name: String?
    var price: Double?
    var ingredients: String?
    var details: String?
    var img: String?
    var likes: Int?
    
    func initWithData(theRowID i: Int, theUserID u_id: Int, theName n: String, thePrice p: Double, theIngredients ing: String, theExcerpt e: String, theImage image: String, theLikes l: Int) {
        id = i
        user_id = u_id
        name = n
        price = p
        ingredients = ing
        details = e  // excerpt
        img = image
        likes = l
    }
}
