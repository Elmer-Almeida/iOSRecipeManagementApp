//
//  UserAPI.swift
//  RecipeTrendingAndPurchase
//
//  Created by Elmer Almeida on 2022-04-18.
//

import Foundation
    
struct UserAPIObject: Codable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let img: String
}

final class UserAPI {
    
    // ensure shared instance
    static let shared = UserAPI()
    
    // user api endpoint string
    var UserAPIUrl: String? = nil
    
    func fetchUsersList(onCompletion: @escaping ([UserAPIObject]) -> ()) {
        UserAPIUrl = "http://localhost:5000/api/users/all"
        let userURL = URL(string: UserAPIUrl!)
        
        let task = URLSession.shared.dataTask(with: userURL!) { (data, response, error) in
            guard let data = data else {
                print("No data was recieved.")
                return
            }
            
            guard let userList: [UserAPIObject] = try? JSONDecoder().decode([UserAPIObject].self, from: data) else {
                print("Couldn't decode the JSON response")
                return
            }
            
            print("The number of recipes recieved is: \(userList.count)")
            onCompletion(userList)
        }
        task.resume()
    }
    
}
