//
//  User.swift
//  RecipeTrendingAndPurchase
//
//  Created by Elmer Almeida on 2022-04-18.
//

import UIKit

class User: NSObject {
    var id: Int?
    var firstName: String?
    var lastName: String?
    var email: String?
    var img: String?
    
    func initWithData(theID i: Int, theFirstName fn: String, theLastName ln: String, theEmail e: String, theImage image: String) {
        id = i
        firstName = fn
        lastName = ln
        email = e
        img = image
    }
}
