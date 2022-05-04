//
//  RecipeDetailViewController.swift
//  RecipeTrendingAndPurchase
//
//  Created by Elmer Almeida on 2022-04-18.
//

import UIKit

class RecipeDetailViewController: UIViewController {
    
    @IBOutlet var navigationBar: UINavigationBar!
    
    @IBOutlet var recipeImageView: UIImageView!
    
    var selectedRecipe: Recipe?
    
    // query to see if the user has purchased the given recipe.
    // don't query too many times.
    var hasUserPurchasedRecipe: Bool = false
    
    var recipeNameLabel: UILabel = UILabel()
    var recipeOwnerNameLabel: UILabel = UILabel()
    var recipePriceLabel: UILabel = UILabel()
    var recipeLikesLabel: UILabel = UILabel()
    var recipeExcerptLabel: UILabel = UILabel()
    var recipeIngredientsLabel: UILabel = UILabel()
    var recipeIngredientsNotificationLabel: UILabel = UILabel()
    var recipeLockedImageView: UIImageView = UIImageView()
    var recipePurchaseButton: UIButton?
    
    // main delegate
    let mainDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = mainDelegate.hexStringToUIColor(hex: "#f7f4fb")
        
        // add the selected recipe to a local variable
        selectedRecipe = mainDelegate.selectedRecipeForRecipeDetailView!
        
        // get the response from the purchases table
        hasUserPurchasedRecipe = mainDelegate.checkIfRecipePurchased(forUser: mainDelegate.USER_ID, forRecipe: selectedRecipe!.id!)
        
        // configure navigation bar
        configureNavigationBar()
        
        // configure recipe image
        configureRecipeImageView()
        
        // configure recipe name
        configureRecipeNameLabel()
        
        // configure owner name label
        configureRecipeOwnerNameLabel()
        
        // configure price label
        configureRecipePriceLabel()
        
        // configure likes label
        configureRecipeLikesLabel()
        
        // configure exerct (details)
        configureRecipeExcerptLabel()
        
        if hasUserPurchasedRecipe {
             // configure recipe notification label for ingredients (INGREDIENTS: )
            configureRecipeIngredientsNoficationLabel()
            // configure recipe ingredients label
            configureRecipeIngredientsLabel()
        } else {
            if selectedRecipe!.price! > 0 {
                configureRecipeLockedImageView()
                configureRecipePurchaseButton()
            } else {
                // configure recipe notification label for ingredients (INGREDIENTS: )
                configureRecipeIngredientsNoficationLabel()
                // configure recipe ingredients label
                configureRecipeIngredientsLabel()
            }
        }
    }
    
    func configureNavigationBar() {
        self.navigationBar.topItem?.title = "\(selectedRecipe!.name!)"
    }
    
    // configure recipe inmage view
    func configureRecipeImageView() {
        let imageURL: URL = URL(string: selectedRecipe!.img!)!
        if let data = try? Data(contentsOf: imageURL) {
            recipeImageView.image = UIImage(data: data)!
            recipeImageView.layer.cornerRadius = 12
            recipeImageView.clipsToBounds = true
            recipeImageView.layer.masksToBounds = true
            recipeImageView.contentMode = .scaleAspectFit
        }
    }
    
    func configureRecipeNameLabel() {
        view.addSubview(recipeNameLabel)
        
        recipeNameLabel.text = selectedRecipe!.name
        recipeNameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        
        recipeNameLabel.translatesAutoresizingMaskIntoConstraints = false
        recipeNameLabel.topAnchor.constraint(equalTo: recipeImageView.bottomAnchor, constant: 10).isActive = true
        recipeNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        recipeNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
    }
    
    func configureRecipeOwnerNameLabel() {
        view.addSubview(recipeOwnerNameLabel)
        
        // todo add name of the owner of the recipe
        let recipeOwner: User? = mainDelegate.getUserBasedOnUserID(userID: selectedRecipe!.user_id!)
        
        // safely output the owner's name
        if recipeOwner != nil {
            recipeOwnerNameLabel.text = "by \(recipeOwner!.firstName!) \(recipeOwner!.lastName!)"
        } else {
            recipeOwnerNameLabel.text = "by Anonymous User"
        }
        
        recipeOwnerNameLabel.textColor = mainDelegate.hexStringToUIColor(hex: "#333333")
        recipeOwnerNameLabel.font = UIFont.systemFont(ofSize: 16)
        
        recipeOwnerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        recipeOwnerNameLabel.topAnchor.constraint(equalTo: recipeNameLabel.bottomAnchor, constant: 3).isActive = true
        recipeOwnerNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
    }
    
    func configureRecipePriceLabel() {
        view.addSubview(recipePriceLabel)
        
        if hasUserPurchasedRecipe {
            // has purchased this recipe
            recipePriceLabel.textColor = mainDelegate.hexStringToUIColor(hex: "#1560b8")
            recipePriceLabel.text = "PURCHASED"
        } else {
            if selectedRecipe!.price == 0 {
                recipePriceLabel.textColor = mainDelegate.hexStringToUIColor(hex: "#1560b8")
                recipePriceLabel.text = "FREE"
            } else {
                recipePriceLabel.textColor = mainDelegate.hexStringToUIColor(hex: "#b12704")
                recipePriceLabel.text = "$\(String(selectedRecipe!.price!)) CAD"
            }
        }
        recipePriceLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        recipePriceLabel.translatesAutoresizingMaskIntoConstraints = false
        recipePriceLabel.topAnchor.constraint(equalTo: recipeOwnerNameLabel.bottomAnchor, constant: 10).isActive = true
        recipePriceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
    }
    
    func configureRecipeLikesLabel() {
        view.addSubview(recipeLikesLabel)
        
        if selectedRecipe!.likes == 0 {
            recipeLikesLabel.text = "No Likes"
        } else if selectedRecipe!.likes == 1 {
            recipeLikesLabel.text = "\(selectedRecipe!.likes!) like"
        } else {
            recipeLikesLabel.text = "\(selectedRecipe!.likes!) likes"
        }
        
        recipeLikesLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        recipeLikesLabel.textColor = mainDelegate.hexStringToUIColor(hex: "#79589f")
        
        recipeLikesLabel.translatesAutoresizingMaskIntoConstraints = false
        recipeLikesLabel.topAnchor.constraint(equalTo: recipeOwnerNameLabel.bottomAnchor, constant: 10).isActive = true
        recipeLikesLabel.leadingAnchor.constraint(equalTo: recipePriceLabel.trailingAnchor, constant: 20).isActive = true
    }
    
    func configureRecipeExcerptLabel() {
        view.addSubview(recipeExcerptLabel)
        
        recipeExcerptLabel.text = selectedRecipe!.details
        recipeExcerptLabel.numberOfLines = 0
        recipeExcerptLabel.lineBreakMode = .byWordWrapping
        recipeExcerptLabel.textColor = mainDelegate.hexStringToUIColor(hex: "#222222")
        recipeExcerptLabel.font = UIFont.systemFont(ofSize: 16)
        
        recipeExcerptLabel.translatesAutoresizingMaskIntoConstraints = false
        recipeExcerptLabel.topAnchor.constraint(equalTo: recipePriceLabel.bottomAnchor, constant: 10).isActive = true
        recipeExcerptLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        recipeExcerptLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
    }
    
    func configureRecipeIngredientsNoficationLabel() {
        view.addSubview(recipeIngredientsNotificationLabel)
        
        let attributedString = NSMutableAttributedString.init(string: "INGREDIENTS")
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: NSRange.init(location: 0, length: attributedString.length))
        recipeIngredientsNotificationLabel.attributedText = attributedString
        
        recipeIngredientsNotificationLabel.textColor = mainDelegate.hexStringToUIColor(hex: "#1560b8")
        recipeIngredientsNotificationLabel.font = UIFont.boldSystemFont(ofSize: 18)
        
        recipeIngredientsNotificationLabel.translatesAutoresizingMaskIntoConstraints = false
        recipeIngredientsNotificationLabel.topAnchor.constraint(equalTo: recipeExcerptLabel.bottomAnchor, constant: 20).isActive = true
        recipeIngredientsNotificationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        recipeIngredientsNotificationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true

    }
    
    func configureRecipeIngredientsLabel() {
        view.addSubview(recipeIngredientsLabel)
        
        recipeIngredientsLabel.text = selectedRecipe!.ingredients
        recipeIngredientsLabel.numberOfLines = 0
        recipeIngredientsLabel.lineBreakMode = .byWordWrapping
        recipeIngredientsLabel.textColor = mainDelegate.hexStringToUIColor(hex: "#222222")
        recipeIngredientsLabel.font = UIFont.systemFont(ofSize: 16)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 7
        let attrString = NSMutableAttributedString(string: selectedRecipe!.ingredients!)
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))

        recipeIngredientsLabel.attributedText = attrString
        
        recipeIngredientsLabel.translatesAutoresizingMaskIntoConstraints = false
        recipeIngredientsLabel.topAnchor.constraint(equalTo: recipeIngredientsNotificationLabel.bottomAnchor, constant: 6).isActive = true
        recipeIngredientsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        recipeIngredientsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
    }
    
    // confiure recipe locked image icon
    func configureRecipeLockedImageView() {
        view.addSubview(recipeLockedImageView)
        
        recipeLockedImageView.image = UIImage(named: "lockicon.png")
        recipeLockedImageView.frame = CGRect(x: view.frame.width / 2 - 50, y: view.frame.height - 335, width: 100, height: 120)
    }
    
    // confiure recipe purchase button
    func configureRecipePurchaseButton() {
        recipePurchaseButton = UIButton.init(type: .system)
        recipePurchaseButton!.frame = CGRect(x: view.frame.width / 2 - 186, y: view.frame.height - 185, width: 375, height: 52)
        recipePurchaseButton!.layer.borderWidth = 2.0
        recipePurchaseButton!.layer.borderColor = UIColor.white.cgColor
        recipePurchaseButton!.titleLabel?.tintColor = UIColor.white
        recipePurchaseButton?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        recipePurchaseButton!.setTitle("PURCHASE THIS RECIPE FOR $\(selectedRecipe!.price!) CAD", for: .normal)
        recipePurchaseButton!.layer.cornerRadius = 15
        recipePurchaseButton?.backgroundColor = mainDelegate.hexStringToUIColor(hex: "#79589f")
        recipePurchaseButton?.addTarget(self, action: #selector(handlePurchaseButtonClicked), for: .touchUpInside)
        
        view.addSubview(recipePurchaseButton!)
    }
    
    // handle purchase button clicked
    @objc func handlePurchaseButtonClicked(_: UIButton) {
        mainDelegate.selectedRecipeForPurchaseView = selectedRecipe!
        performSegue(withIdentifier: "RecipeDetailViewToPurchaseViewControllerSegue", sender: nil)
    }
    
    @IBAction func doneWithRecipeDetailView(sender: UIButton) {
        mainDelegate.selectedRecipeForRecipeDetailView = nil
        dismiss(animated: true)
    }
    
}
