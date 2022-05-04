//
//  ViewController.swift
//  RecipeTrendingAndPurchase
//
//  Created by Elmer Almeida on 2022-04-16.
//

import UIKit

class ViewController: UIViewController {
    
    // create table view
    let tableView: UITableView = UITableView()
    
    // view safe area
    var safeAreaGuide: UILayoutGuide!
    
    // connect navigation bar
    @IBOutlet var navigationBar: UINavigationBar!
    
    // app delegate instance
    let mainDelegate = UIApplication.shared.delegate as! AppDelegate
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        safeAreaGuide = view.layoutMarginsGuide
        
        view.backgroundColor = mainDelegate.hexStringToUIColor(hex: "#f7f4fb")
        tableView.backgroundColor = mainDelegate.hexStringToUIColor(hex: "#f7f4fb")
        
        // configure navigation bar
        configureNavigationBar()
        
        // configure table view to display recipes
        configureTableView()
        
        // only load API data for RECIPES if the API data is not loaded (ie. recipeListWithPriceAndLikes < 20)
        if self.mainDelegate.recipeListWithPriceAndLikes.count < 20 {
            let recipesFunction = { (fetchedRecipes: [RecipeAPIObject]) in
                // make sure to do this on the main thread (always want this data to be in the database)
                DispatchQueue.main.async {
                    // check if the data inside the application is less than 20
                    self.insertRecipeAPIDataIntoRecipeTable(recipeAPIList: fetchedRecipes)
                    
                    // reload the table view data
                    self.tableView.reloadData()
                }
            }
            RecipeAPI.shared.fetchRecipeList(onCompletion: recipesFunction)
        }
    }
    
    // insert API recipes into database
    func insertRecipeAPIDataIntoRecipeTable(recipeAPIList: [RecipeAPIObject]) {
        for item in recipeAPIList {
            // create new recipe object based on the recipe pulled from the API
            let newRecipeObj: Recipe = Recipe.init()
            newRecipeObj.initWithData(theRowID: item.id, theUserID: item.user_id, theName: item.name, thePrice: item.price, theIngredients: item.ingredients, theExcerpt: item.details, theImage: item.img, theLikes: item.likes)
            // insert the Recipe object created into the MyDatabase.db database file
            let returnCode = self.mainDelegate.insertIntoRecipesTable(recipe: newRecipeObj)
            // check to see if all went smoothly
            if returnCode {
                print("Recipe data item added to the database.")
            }
        }
    }

    // unwind to home view controller
    @IBAction func unwindToHomeViewController(sender: UIStoryboardSegue) {}
    
    // TODO: This is a temporary measure to delete all items from the SQLite3 recipes database
    // clear the sqlite3 recipes database (truncate recipes table)
    @IBAction func clearRecipes() {
        mainDelegate.clearRecipesTable()
        self.tableView.reloadData()
    }
    
    // setup navigation bar
    func configureNavigationBar() {
        navigationBar?.topItem?.title = "All Recipes"
    }
    
    // configure table view
    func configureTableView() {
        view.addSubview(tableView)
        tableView.register(RecipeTableViewCell.self, forCellReuseIdentifier: "recipe_cell")
        tableView.dataSource = self
        tableView.delegate = self

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: navigationBar!.bottomAnchor, constant: 1).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: safeAreaGuide.bottomAnchor, constant: -5.0).isActive = true
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // set height for each cell at 100
        return 100
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainDelegate.recipeListWithPriceAndLikes.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipe_cell", for: indexPath)
        
        // conform UITableViewCell (cell) to RecipeTableViewCell
        guard let recipeCell = cell as? RecipeTableViewCell else {
            return cell
        }
        
        let recipeItem = mainDelegate.recipeListWithPriceAndLikes[indexPath.row]
        
        // check if recipe img is a URL
        if let recipeImageURL = URL(string: recipeItem.img!) {
            // add the recipe img from the url to the UIImageView
            recipeCell.imageViewItem.loadImage(from: recipeImageURL)
        }
         
        // set the rest of the properties for each tableView cell (RecipeTableViewCell)
        recipeCell.recipeNameLabel.text = recipeItem.name
        
        // check if the user has purchased the recipe
        if mainDelegate.checkIfRecipePurchased(forUser: mainDelegate.USER_ID, forRecipe: recipeItem.id!) {
            // the user has purchased this recipe
            recipeCell.recipePurchasedLabel.text = "PURCHASED"
            recipeCell.recipePriceLabel.text = ""
        } else {
            // check if the recipe price is FREE
            if recipeItem.price != 0 {
                recipeCell.recipePriceLabel.text = "$\(String(recipeItem.price!)) CAD"
                recipeCell.recipePurchasedLabel.text = ""
            } else {
                recipeCell.recipePurchasedLabel.text = "FREE"
                recipeCell.recipePriceLabel.text = ""
            }
        }
        
        recipeCell.recipeLikesLabel.text = "\(String(recipeItem.likes!)) likes"
        // add excerpt for the recipe (make sure to add elipses)
        recipeCell.recipeExcerptLabel.text = recipeItem.details
        
        // add disclosure indicator
        recipeCell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mainDelegate.selectedRecipeForRecipeDetailView = mainDelegate.recipeListWithPriceAndLikes[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "HomeViewControllerToRecipeDetailViewControllerSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        mainDelegate.selectedRecipeForRecipeDetailView = nil
    }
    
}
