//
//  UserRecipesListViewController.swift
//  RecipeTrendingAndPurchase
//
//  Created by Elmer Almeida on 2022-04-18.
//

import UIKit

class UserRecipesListViewController: UIViewController {
    
    // main delegate access
    let mainDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // get the selected user and his/her recipes
    var selectedUser: User? = nil
    var userRecipeList: [Recipe] = [Recipe]()
    
    // navigation bar to display the user name and back button
    @IBOutlet var navigationBar: UINavigationBar!
    
    var userPictureImageView: UIImageView = UIImageView()
    var userNameLabel: UILabel = UILabel()
    var userEmailLabel: UILabel = UILabel()
    var userNumberOfRecipesLabel: UILabel = UILabel()
    var tableView: UITableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = mainDelegate.hexStringToUIColor(hex: "#f7f4fb")
        tableView.backgroundColor = mainDelegate.hexStringToUIColor(hex: "#f7f4fb")
        
        // change access variable for ease of use
        selectedUser = mainDelegate.selectedUserForRecipesList!
        
        // get all the recipes of the user
        userRecipeList = mainDelegate.getRecipesForUser(userID: selectedUser!.id!)
        
        // configure navigation bar
        configureNavigationBar()
        
        configureUserPictureImageView()
        configureuserNameLabel()
        configureUserEmailLabel()
        configureNumberOfRecipesLabel()
        
        // configure table view
        configureTableView()
    }
    
    func configureNavigationBar() {
        self.navigationBar.topItem?.title = "\(selectedUser!.firstName!) \(selectedUser!.lastName!)"
    }
    
    func configureUserPictureImageView() {
        view.addSubview(userPictureImageView)
        
        userPictureImageView.frame = CGRect(x: view.frame.size.width / 2 - 75, y: 75, width: 150, height: 150)
        
        let imageURL: URL = URL(string: selectedUser!.img!)!
        print(imageURL)
        if let data = try? Data(contentsOf: imageURL) {
            userPictureImageView.image = UIImage(data: data)!
            userPictureImageView.layer.cornerRadius = userPictureImageView.frame.size.width / 2
            userPictureImageView.clipsToBounds = true
            userPictureImageView.contentMode = .scaleAspectFill
            userPictureImageView.layer.borderWidth = 1.0
            userPictureImageView.layer.masksToBounds = true
            userPictureImageView.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    func configureuserNameLabel() {
        view.addSubview(userNameLabel)
        
        userNameLabel.text = "\(selectedUser!.firstName!) \(selectedUser!.lastName!)"
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.topAnchor.constraint(equalTo: userPictureImageView.bottomAnchor, constant: 10).isActive = true
        userNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func configureUserEmailLabel() {
        view.addSubview(userEmailLabel)
        
        userEmailLabel.text = selectedUser!.email
        userEmailLabel.font = UIFont.systemFont(ofSize: 16)
        userEmailLabel.textColor = mainDelegate.hexStringToUIColor(hex: "#333333")
        
        userEmailLabel.translatesAutoresizingMaskIntoConstraints = false
        userEmailLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 5).isActive = true
        userEmailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func configureNumberOfRecipesLabel() {
        view.addSubview(userNumberOfRecipesLabel)
        
        let numberOfRecipes = mainDelegate.getCountOfRecipes(forUserID: selectedUser!.id!)
        
        userNumberOfRecipesLabel.text = "\(numberOfRecipes) recipes contributed"
        userNumberOfRecipesLabel.font = UIFont.boldSystemFont(ofSize: 16)
        userNumberOfRecipesLabel.textColor = mainDelegate.hexStringToUIColor(hex: "#1560b8")
        
        userNumberOfRecipesLabel.translatesAutoresizingMaskIntoConstraints = false
        userNumberOfRecipesLabel.topAnchor.constraint(equalTo: userEmailLabel.bottomAnchor, constant: 5).isActive = true
        userNumberOfRecipesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    // config table view
    func configureTableView() {
        view.addSubview(tableView)
        tableView.register(RecipeTableViewCell.self, forCellReuseIdentifier: "user_recipe_cell")
        tableView.dataSource = self
        tableView.delegate = self

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: userNumberOfRecipesLabel.bottomAnchor, constant: 13).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

}

extension UserRecipesListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userRecipeList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "user_recipe_cell", for: indexPath)
        
        // conform UITableViewCell (cell) to RecipeTableViewCell
        guard let recipeCell = cell as? RecipeTableViewCell else {
            return cell
        }
        
        let recipeItem = userRecipeList[indexPath.row]
        
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mainDelegate.selectedRecipeForRecipeDetailView = userRecipeList[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "UserRecipesListViewToRecipeDetailViewControllerSegue", sender: nil)
    }
}
