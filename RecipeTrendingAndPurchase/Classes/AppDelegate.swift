//
//  AppDelegate.swift
//  RecipeTrendingAndPurchase
//
//  Created by Elmer Almeida on 2022-04-16.
//

import UIKit
import SQLite3

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var databaseName: String? = "MyDatabase.db"
    var databasePath: String?
    
    var recipeListWithPriceAndLikes: [Recipe] = []
    var usersList: [User] = []
    var selectedUserForRecipesList: User? = nil
    var selectedRecipeForRecipeDetailView: Recipe? = nil
    var selectedRecipeForPurchaseView: Recipe? = nil
    
    // TODO: TEMP USER ID
    let USER_ID = 9 // Elmer Almeida

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // get an array of document paths
        let documentPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                
        let documentsDir = documentPaths[0]
        databasePath = documentsDir.appending("/" + databaseName!)
        
        // check/create database on user device
        checkAndCreateDatabase()
        
        // read data from the database
        getFromRecipesTable()
        getFromUsersTable()
        
        return true
    }
    
    func checkAndCreateDatabase() {
        var success = false
        let fileManager = FileManager.default
        
        success = fileManager.fileExists(atPath: databasePath!)
        
        if success {
            print("Database file exists!")
            return
        }
        
        print("Database file created!")
        
        let databasePathFromApp = Bundle.main.resourcePath?.appending("/" + databaseName!)
        try? fileManager.copyItem(atPath: databasePathFromApp!, toPath: databasePath!)
        
        return
    }
    
    // NOTICE: ONLY FOR ERROR CHECKING.
    // Delete the MyDatabase.db file.
    func deleteMyDatabaseFile() {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: databasePath!)
        } catch {
            NSLog("Error deleting file: \(databasePath!)")
        }
    }
    
    // get recipes from recipes table
    func getFromRecipesTable() {
        // prevent duplicate data -- empty out people array
        recipeListWithPriceAndLikes.removeAll()
        
        var db : OpaquePointer? = nil
        
        if sqlite3_open(self.databasePath, &db) == SQLITE_OK {
            // set up query
            // ********************************
            // ** Debugging purpose
            // ********************************
             print("successfully opened database connection to database at \(String(describing: self.databasePath))")
            // ********************************
            
            var queryStatement: OpaquePointer? = nil
            let queryStatementString: String = "select * from recipes"
            
            if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    let id: Int = Int(sqlite3_column_int(queryStatement, 0))
                    let user_id: Int = Int(sqlite3_column_int(queryStatement, 1))
                    let cName = sqlite3_column_text(queryStatement, 2)
                    let price: Double = sqlite3_column_double(queryStatement, 3)
                    let cIngredients = sqlite3_column_text(queryStatement, 4)
                    let cDetails = sqlite3_column_text(queryStatement, 5)
                    let cImg = sqlite3_column_text(queryStatement, 6)
                    let likes: Int = Int(sqlite3_column_int(queryStatement, 7))
                    
                    let name = String(cString: cName!)
                    let ingredients = String(cString: cIngredients!)
                    let details = String(cString: cDetails!)
                    let img = String(cString: cImg!)
                    
                    let recipeObj : Recipe = Recipe.init()
                    
                    recipeObj.initWithData(theRowID: id, theUserID: user_id, theName: name, thePrice: price, theIngredients: ingredients, theExcerpt: details, theImage: img, theLikes: likes)
                    
                    recipeListWithPriceAndLikes.append(recipeObj)
                    
                    // ********************************
                    // ** Debugging purpose
                    // ********************************
//                     print("Query result")
//                     print("ID: \(id) | User ID: \(user_id) | Name: \(name) | Price: \(price) | ingredients: \(ingredients) | Excerpt: \(details) | Image: \(img) | Likes: \(likes)")
                    // ********************************
                }
                
                sqlite3_finalize(queryStatement)
                
            } else {
                print("Select statement could not be prepared")
            }
            
            sqlite3_close(db)
            
        } else {
            print("Unable to open SQLite3 database")
        }
    }
    
    // insert Recipe object into the recipes table
    func insertIntoRecipesTable(recipe recipeItem: Recipe) -> Bool {
        var db: OpaquePointer? = nil
        var returnCode: Bool = true
        
        if sqlite3_open(self.databasePath, &db) == SQLITE_OK {
            var insertStatement: OpaquePointer? = nil
            let insertStatementString: String = "insert into recipes values (NULL, ?, ?, ?, ?, ?, ?, ?)"
            
            if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
                let userIdInt = recipeItem.user_id! as NSInteger
                let nameStr = recipeItem.name! as NSString
                let priceDbl = recipeItem.price! as Double
                let ingredientsStr = recipeItem.ingredients! as NSString
                let detailsStr = recipeItem.details! as NSString
                let imgStr = recipeItem.img! as NSString
                let likesInt = recipeItem.likes! as NSInteger

                sqlite3_bind_int(insertStatement, 1, Int32(truncating: userIdInt as NSNumber))
                sqlite3_bind_text(insertStatement, 2, nameStr.utf8String, -1, nil)
                sqlite3_bind_double(insertStatement, 3, priceDbl)
                sqlite3_bind_text(insertStatement, 4, ingredientsStr.utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 5, detailsStr.utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 6, imgStr.utf8String, -1, nil)
                sqlite3_bind_int(insertStatement, 7, Int32(truncating: likesInt as NSNumber))
                               
                if sqlite3_step(insertStatement) == SQLITE_DONE {
                    let rowID = sqlite3_last_insert_rowid(db)
                    print("Successfully inserted row at: \(rowID).")
                    
                    // create Recipe object type and insert into RecipeWithPriceAndLikes
                    let newObj: Recipe = Recipe.init()
                    newObj.initWithData(theRowID: Int(rowID), theUserID: recipeItem.user_id!, theName: recipeItem.name!, thePrice: recipeItem.price!, theIngredients: recipeItem.ingredients!, theExcerpt: recipeItem.details!, theImage: recipeItem.img!, theLikes: recipeItem.likes!)
                    // add the new recipe object to the recipeListWithPriceAndLikes array
                    recipeListWithPriceAndLikes.append(newObj)
                } else {
                    print("Could not insert row.")
                    returnCode = false
                }
                sqlite3_finalize(insertStatement)
            } else {
                print("Insert statement could not be prepared.")
                returnCode = false
            }
            sqlite3_close(db)
        } else {
            print("Unable to open database")
            returnCode = false
        }
        return returnCode
    }
    
    // remove a given recipe from the recipes table
    func deleteFromRecipesTable(recipeID id: Int) -> Bool {
        var db: OpaquePointer? = nil
        var returnCode: Bool = true
        
        if sqlite3_open(self.databasePath, &db) == SQLITE_OK {
            var deleteStatement: OpaquePointer? = nil
            let deleteStatementString = "delete from recipes where id = ?"
            
            if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
                
                sqlite3_bind_int(deleteStatement, 1, Int32(id))

                if sqlite3_step(deleteStatement) == SQLITE_DONE {
                    print("Successfully deleted row.")
                } else {
                    print("Could not delete row.")
                }
                sqlite3_finalize(deleteStatement)
                
            } else {
                print("Delete statement could not be prepared")
                returnCode = false
            }
            sqlite3_close(db)
        } else {
            print("Unable to open database")
            returnCode = false
        }
        return returnCode
    }
    
    // get a list of recipes from a given user
    func getRecipesForUser(userID id: Int) -> [Recipe] {
        
        var recipes: [Recipe] = [Recipe]()
        
        var db : OpaquePointer? = nil
        
        if sqlite3_open(self.databasePath, &db) == SQLITE_OK {
            // set up query
            // ********************************
            // ** Debugging purpose
            // ********************************
             print("successfully opened database connection to database at \(String(describing: self.databasePath))")
            // ********************************
            
            var queryStatement: OpaquePointer? = nil
            let queryStatementString: String = "select * from recipes where user_id = ?"
            
            if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                
                sqlite3_bind_int(queryStatement, 1, Int32(id))
                
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    let id: Int = Int(sqlite3_column_int(queryStatement, 0))
                    let user_id: Int = Int(sqlite3_column_int(queryStatement, 1))
                    let cName = sqlite3_column_text(queryStatement, 2)
                    let price: Double = sqlite3_column_double(queryStatement, 3)
                    let cIngredients = sqlite3_column_text(queryStatement, 4)
                    let cDetails = sqlite3_column_text(queryStatement, 5)
                    let cImg = sqlite3_column_text(queryStatement, 6)
                    let likes: Int = Int(sqlite3_column_int(queryStatement, 7))
                    
                    let name = String(cString: cName!)
                    let ingredients = String(cString: cIngredients!)
                    let details = String(cString: cDetails!)
                    let img = String(cString: cImg!)
                    
                    let recipeObj : Recipe = Recipe.init()
                    recipeObj.initWithData(theRowID: id, theUserID: user_id, theName: name, thePrice: price, theIngredients: ingredients, theExcerpt: details, theImage: img, theLikes: likes)
                    
                    recipes.append(recipeObj)
                    
                    // ********************************
                    // ** Debugging purpose
                    // ********************************
//                     print("Query result")
//                     print("ID: \(id) | User ID: \(user_id) | Name: \(name) | Price: \(price) | ingredients: \(ingredients) | Excerpt: \(details) | Image: \(img) | Likes: \(likes)")
                    // ********************************
                }
                
                sqlite3_finalize(queryStatement)
                
            } else {
                print("Select statement could not be prepared")
            }
            
            sqlite3_close(db)
            
        } else {
            print("Unable to open SQLite3 database")
        }
        
        return recipes
    }
    
    // get number of recipes for user id provided
    func getCountOfRecipes(forUserID id: Int) -> Int32 {
        
        var db : OpaquePointer? = nil
        var totalCount: Int32 = 0
        
        if sqlite3_open(self.databasePath, &db) == SQLITE_OK {
            // set up query
            // ********************************
            // ** Debugging purpose
            // ********************************
//             print("successfully opened database connection to database at \(String(describing: self.databasePath!))")
            // ********************************
            
            var queryStatement: OpaquePointer? = nil
            let queryStatementString: String = "select count(*) from recipes where user_id = ?"

            if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK{
                
                sqlite3_bind_int(queryStatement, 1, Int32(id))
                
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    totalCount = sqlite3_column_int(queryStatement, 0)
//                    print("\(totalCount) recipes exist for user: \(id)")
                }
            }
           
            if sqlite3_step(queryStatement) != SQLITE_DONE {
                let error = String(cString: sqlite3_errmsg(queryStatement)!)
                print("Error: \(error)")
            }
        }
        return totalCount
    }
    
    // clear recipes table (truncate recipes table)
    func clearRecipesTable() {
        // ensure up to date data in
        getFromRecipesTable()
        
        let recipes = recipeListWithPriceAndLikes
        
        for recipe in recipes {
            let success = deleteFromRecipesTable(recipeID: recipe.id!)
            if success {
                print("deleted record of ID: \(String(describing: recipe.id))")
            }
        }
        
//        print("At the end of clearRecipesTable() method, the count for RecipesListWithPriceAndLikes is \(recipeListWithPriceAndLikes.count)")
        getFromRecipesTable()
//        print("Called getFromRecipeDatabase() method, the count for RecipesListWithPriceAndLikes is \(recipeListWithPriceAndLikes.count)")
    }
    
    
    // get data from the users table
    func getFromUsersTable() {
 
        // prevent duplicate data -- empty out people array
        usersList.removeAll()
        
        var db : OpaquePointer? = nil
        
        if sqlite3_open(self.databasePath, &db) == SQLITE_OK {
            // set up query
            // ********************************
            // ** Debugging purpose
            // ********************************
             print("successfully opened database connection to database at \(String(describing: self.databasePath))")
            // ********************************
            
            var queryStatement: OpaquePointer? = nil
            let queryStatementString: String = "select * from users"
            
            if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    let id: Int = Int(sqlite3_column_int(queryStatement, 0))
                    let cFirstName = sqlite3_column_text(queryStatement, 1)
                    let cLastName = sqlite3_column_text(queryStatement, 2)
                    let cEmail = sqlite3_column_text(queryStatement, 3)
                    let cImg = sqlite3_column_text(queryStatement, 4)
                    
                    let firstName = String(cString: cFirstName!)
                    let lastName = String(cString: cLastName!)
                    let email = String(cString: cEmail!)
                    let img = String(cString: cImg!)
                    
                    let userObj : User = User.init()
                    userObj.initWithData(theID: id, theFirstName: firstName, theLastName: lastName, theEmail: email, theImage: img)
                    
                    usersList.append(userObj)
                    
                    // ********************************
                    // ** Debugging purpose
                    // ********************************
//                     print("Query result")
//                     print("ID: \(id) | First Name: \(firstName) | Last Name: \(lastName) | Email: \(email) | Image: \(img)")
                    // ********************************
                }
                
                sqlite3_finalize(queryStatement)
                
            } else {
                print("Select statement could not be prepared")
            }
            
            sqlite3_close(db)
            
        } else {
            print("Unable to open SQLite3 database")
        }
    }
    
    // insert into users table
    func insertIntoUsersTable(user userItem: User) -> Bool {
        
        var db: OpaquePointer? = nil
        var returnCode: Bool = true
        
        if sqlite3_open(self.databasePath, &db) == SQLITE_OK {
            var insertStatement: OpaquePointer? = nil
            let insertStatementString: String = "insert into users values (NULL, ?, ?, ?, ?)"
            
            if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
                let firstNameStr = userItem.firstName! as NSString
                let lastNameStr = userItem.lastName! as NSString
                let emailStr = userItem.email! as NSString
                let imgStr = userItem.img! as NSString

                sqlite3_bind_text(insertStatement, 1, firstNameStr.utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 2, lastNameStr.utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 3, emailStr.utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 4, imgStr.utf8String, -1, nil)
                               
                if sqlite3_step(insertStatement) == SQLITE_DONE {
                    let rowID = sqlite3_last_insert_rowid(db)
                    print("Successfully inserted row at: \(rowID).")
                    
                    // create Recipe object type and insert into RecipeWithPriceAndLikes
                    let newObj: User = User.init()
                    newObj.initWithData(theID: Int(rowID), theFirstName: userItem.firstName!, theLastName: userItem.lastName!, theEmail: userItem.email!, theImage: userItem.img!)
                    // add the new recipe object to the recipeListWithPriceAndLikes array
                    usersList.append(newObj)
                } else {
                    print("Could not insert row.")
                    returnCode = false
                }
                sqlite3_finalize(insertStatement)
            } else {
                print("Insert statement could not be prepared.")
                returnCode = false
            }
            sqlite3_close(db)
        } else {
            print("Unable to open database")
            returnCode = false
        }
        return returnCode
    }
    
    // get a list of 25 of the trending recipes by likes
    func getTrendingRecipes() -> [Recipe] {
        var db : OpaquePointer? = nil
        var trendingRecipes: [Recipe] = [Recipe]()
        
        if sqlite3_open(self.databasePath, &db) == SQLITE_OK {
            // set up query
            // ********************************
            // ** Debugging purpose
            // ********************************
             print("successfully opened database connection to database at \(String(describing: self.databasePath))")
            // ********************************
            
            var queryStatement: OpaquePointer? = nil
            let queryStatementString: String = "select * from recipes order by likes desc limit 25"
            
            if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    let id: Int = Int(sqlite3_column_int(queryStatement, 0))
                    let user_id: Int = Int(sqlite3_column_int(queryStatement, 1))
                    let cName = sqlite3_column_text(queryStatement, 2)
                    let price: Double = sqlite3_column_double(queryStatement, 3)
                    let cIngredients = sqlite3_column_text(queryStatement, 4)
                    let cDetails = sqlite3_column_text(queryStatement, 5)
                    let cImg = sqlite3_column_text(queryStatement, 6)
                    let likes: Int = Int(sqlite3_column_int(queryStatement, 7))
                    
                    let name = String(cString: cName!)
                    let ingredients = String(cString: cIngredients!)
                    let details = String(cString: cDetails!)
                    let img = String(cString: cImg!)
                    
                    let recipeObj : Recipe = Recipe.init()
                    recipeObj.initWithData(theRowID: id, theUserID: user_id, theName: name, thePrice: price, theIngredients: ingredients, theExcerpt: details, theImage: img, theLikes: likes)
                    
                    trendingRecipes.append(recipeObj)
                    
                    // ********************************
                    // ** Debugging purpose
                    // ********************************
//                     print("Query result")
//                     print("ID: \(id) | User ID: \(user_id) | Name: \(name) | Price: \(price) | ingredients: \(ingredients) | Excerpt: \(details) | Image: \(img) | Likes: \(likes)")
                    // ********************************
                }
                
                sqlite3_finalize(queryStatement)
                
            } else {
                print("Select statement could not be prepared")
            }
            
            sqlite3_close(db)
            
        } else {
            print("Unable to open SQLite3 database")
        }
        return trendingRecipes
    }
    
    // get the user based on the user id provided
    func getUserBasedOnUserID(userID id: Int) -> User? {
        
        var db : OpaquePointer? = nil
        var userFound: User? = nil
        
        if sqlite3_open(self.databasePath, &db) == SQLITE_OK {
            // set up query
            // ********************************
            // ** Debugging purpose
            // ********************************
             print("successfully opened database connection to database at \(String(describing: self.databasePath))")
            // ********************************
            
            var queryStatement: OpaquePointer? = nil
            let queryStatementString: String = "select * from users where id = ?"
            
            if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                
                sqlite3_bind_int(queryStatement, 1, Int32(id))
                
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    let id: Int = Int(sqlite3_column_int(queryStatement, 0))
                    let cFirstName = sqlite3_column_text(queryStatement, 1)
                    let cLastName = sqlite3_column_text(queryStatement, 2)
                    let cEmail = sqlite3_column_text(queryStatement, 3)
                    let cImg = sqlite3_column_text(queryStatement, 4)
                    
                    let firstName = String(cString: cFirstName!)
                    let lastName = String(cString: cLastName!)
                    let email = String(cString: cEmail!)
                    let img = String(cString: cImg!)
                    
                    let userObj : User = User.init()
                    userObj.initWithData(theID: id, theFirstName: firstName, theLastName: lastName, theEmail: email, theImage: img)
                    userFound = userObj
                    
                    // ********************************
                    // ** Debugging purpose
                    // ********************************
//                     print("Query result")
//                     print("ID: \(id) | First Name: \(firstName) | Last Name: \(lastName) | Email: \(email) | Image: \(img)")
                    // ********************************
                }
                
                sqlite3_finalize(queryStatement)
                
            } else {
                print("Select statement could not be prepared")
            }
            
            sqlite3_close(db)
            
        } else {
            print("Unable to open SQLite3 database")
        }
        
        return userFound
    }
    
    // USER_ID = 9 // Elmer Almeida
    // check if the user has purchased
    func checkIfRecipePurchased(forUser userID: Int, forRecipe recipeID: Int) -> Bool {
        var db : OpaquePointer? = nil
        var purchasedRows: Int32 = 0
        
        if sqlite3_open(self.databasePath, &db) == SQLITE_OK {
            // set up query
            // ********************************
            // ** Debugging purpose
            // ********************************
//             print("successfully opened database connection to database at \(String(describing: self.databasePath!))")
            // ********************************
            
            var queryStatement: OpaquePointer? = nil
            let queryStatementString: String = "select count(*) from purchases where user_id = ? and recipe_id = ?"

            if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK{
                
                sqlite3_bind_int(queryStatement, 1, Int32(userID))
                sqlite3_bind_int(queryStatement, 2, Int32(recipeID))
                
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    purchasedRows = sqlite3_column_int(queryStatement, 0)
                }
            }
        }
        if purchasedRows != 0 {
            return true
        }
        return false
        
        // TODO : LEAVING OFF HERE.
        // mark recipe as purchased
        // validate purchase PKAuthorization response
        
    }
    
    // USER_ID = 9 // Elmer Almeida
    // mark recipe as purchased by user and recipe ID
    func markRecipeAsPurchased(forUser userID: Int, forRecipe recipeID: Int) -> Bool {
        
        var db: OpaquePointer? = nil
        var returnCode: Bool = true
        
        if sqlite3_open(self.databasePath, &db) == SQLITE_OK {
            var insertStatement: OpaquePointer? = nil
            let insertStatementString: String = "insert into purchases values (NULL, ?, ?)"
            
            if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
                let userIDInt = userID as NSInteger
                let recipeIDInt = recipeID as NSInteger

                sqlite3_bind_int(insertStatement, 1, Int32(truncating: userIDInt as NSNumber))
                sqlite3_bind_int(insertStatement, 2, Int32(truncating: recipeIDInt as NSNumber))
                                              
                if sqlite3_step(insertStatement) == SQLITE_DONE {
                    let rowID = sqlite3_last_insert_rowid(db)
                    print("Successfully inserted row at: \(rowID).")
                } else {
                    print("Could not insert row.")
                    returnCode = false
                }
                sqlite3_finalize(insertStatement)
            } else {
                print("Insert statement could not be prepared.")
                returnCode = false
            }
            sqlite3_close(db)
        } else {
            print("Unable to open database")
            returnCode = false
        }
        return returnCode
    
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // convert hex color code to UIColor
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

