//
//  TrendingViewController.swift
//  RecipeTrendingAndPurchase
//
//  Created by Elmer Almeida on 2022-04-16.
//

import UIKit

class TrendingViewController: UIViewController {
    
    // list of all trending recipes -- init to blank
    var trendingRecipes: [Recipe] = [Recipe]()
    
    // view safe area
    var safeAreaGuide: UILayoutGuide!
    
    // table view
    var tableView: UITableView = UITableView()
    
    // navigation bar
    @IBOutlet var navigationBar: UINavigationBar!
    
    // main delegate
    let mainDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        safeAreaGuide = view.layoutMarginsGuide
        
        view.backgroundColor = mainDelegate.hexStringToUIColor(hex: "#f7f4fb")
        tableView.backgroundColor = mainDelegate.hexStringToUIColor(hex: "#f7f4fb")
        
        // configure navigation bar
        configureNavigationBar()
        
        // configure table vie
        configureTableView()
        
        // get all trending recipes from database
        trendingRecipes = mainDelegate.getTrendingRecipes()
    }
    
    func printTrendingRecipes() {
        for recipe in trendingRecipes {
            print(recipe.likes!)
        }
    }

    // unwind to trending view controller
    @IBAction func unwindToTrendingViewController(sender: UIStoryboardSegue) { }
    
    // configure naviagation bar
    func configureNavigationBar() {
        self.navigationBar.topItem?.title = "Trending"
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
        tableView.bottomAnchor.constraint(equalTo: safeAreaGuide.bottomAnchor, constant: -5.0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}

extension TrendingViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trendingRecipes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipe_cell", for: indexPath)
        
        // conform UITableViewCell (cell) to RecipeTableViewCell
        guard let recipeCell = cell as? RecipeTableViewCell else {
            return cell
        }
        
        let recipeItem = trendingRecipes[indexPath.row]
        
        // check if recipe img is a URL
        if let recipeImageURL = URL(string: recipeItem.img!) {
            // add the recipe img from the url to the UIImageView
            recipeCell.imageViewItem.loadImage(from: recipeImageURL)
        }
         
        // set the rest of the properties for each tableView cell (RecipeTableViewCell)
        recipeCell.recipeNameLabel.text = recipeItem.name
        
        // check if the recipe price is FREE
        if recipeItem.price != 0 {
            recipeCell.recipePriceLabel.text = "$\(String(recipeItem.price!)) CAD"
        } else {
            recipeCell.recipePriceLabel.text = "FREE"
        }
        
        if recipeItem.likes == 0 {
            recipeCell.recipeLikesLabel.text = "No likes"
        } else if recipeItem.likes == 1 {
            recipeCell.recipeLikesLabel.text = "\(String(recipeItem.likes!)) like"
        } else {
            recipeCell.recipeLikesLabel.text = "\(String(recipeItem.likes!)) likes"
        }
        
        // add excerpt for the recipe (make sure to add elipses)
        recipeCell.recipeExcerptLabel.text = recipeItem.details
        
        // add disclosure indicator
        recipeCell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mainDelegate.selectedRecipeForRecipeDetailView = trendingRecipes[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "TrendingViewToRecipeDetailViewControllerSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        mainDelegate.selectedRecipeForRecipeDetailView = nil
    }
}
