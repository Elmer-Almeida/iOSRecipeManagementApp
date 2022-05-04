//
//  PurchaseViewController.swift
//  RecipeTrendingAndPurchase
//
//  Created by Elmer Almeida on 2022-04-16.
//

import UIKit
import PassKit

class PurchaseViewController: UIViewController {
    
    @IBOutlet var navigationBar: UINavigationBar!
    
    @IBOutlet var recipeImageView: UIImageView!
    
    // selected recipe
    var selectedRecipe: Recipe?
    
    var recipeNameLabel: UILabel = UILabel()
    var recipeOwnerNameLabel: UILabel = UILabel()
    var recipePriceLabel: UILabel = UILabel()
    var recipeLikesLabel: UILabel = UILabel()
    var recipeExcerptLabel: UILabel = UILabel()
    var recipeLockedImageView: UIImageView = UIImageView()
    var recipeConfirmPurchaseButton: UIButton?
    
    // main delegate
    var mainDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.backgroundColor = mainDelegate.hexStringToUIColor(hex: "#f7f4fb")
        
        selectedRecipe = mainDelegate.selectedRecipeForPurchaseView!
        
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
        
        // configure recipe locked icon image
        configureRecipeLockedImageView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if PKPaymentAuthorizationViewController.canMakePayments() {
            configureConfirmPurchaseButton()
        } else {
            let alertController = UIAlertController(title: "Error", message: "Unable to create a payment request", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true)

        }
    }
    
    func configureNavigationBar() {
        navigationBar.topItem?.title = "Confirm Purchase"
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
        
        recipePriceLabel.text = "$\(String(selectedRecipe!.price!)) CAD"
        recipePriceLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        recipePriceLabel.textColor = mainDelegate.hexStringToUIColor(hex: "#b12704")
        
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
        
        recipeLikesLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
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
    
    func configureRecipeLockedImageView() {
        view.addSubview(recipeLockedImageView)
        
        recipeLockedImageView.image = UIImage(named: "lockicon.png")
        recipeLockedImageView.frame = CGRect(x: view.frame.width / 2 - 50, y: view.frame.height - 345, width: 100, height: 120)
    }
    
    func configureConfirmPurchaseButton() {
        recipeConfirmPurchaseButton = UIButton.init(type: .system)
        recipeConfirmPurchaseButton!.frame = CGRect(x: view.frame.width / 2 - 186, y: view.frame.height - 125, width: 375, height: 52)
        recipeConfirmPurchaseButton!.layer.borderWidth = 2.0
        recipeConfirmPurchaseButton!.layer.borderColor = UIColor.white.cgColor
        recipeConfirmPurchaseButton!.titleLabel?.tintColor = UIColor.white
        recipeConfirmPurchaseButton?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        recipeConfirmPurchaseButton!.setTitle("CONFIRM PURCHASE OF $\(selectedRecipe!.price!) CAD", for: .normal)
        recipeConfirmPurchaseButton!.layer.cornerRadius = 15
        recipeConfirmPurchaseButton?.backgroundColor = mainDelegate.hexStringToUIColor(hex: "#79589f")
        recipeConfirmPurchaseButton?.addTarget(self, action: #selector(handleConfirmPurchaseButtonClicked), for: .touchUpInside)
        
        view.addSubview(recipeConfirmPurchaseButton!)
    }
    
    @objc func handleConfirmPurchaseButtonClicked(_: UIButton) {
        let controller = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
        if controller != nil {
            controller!.delegate = self
            present(controller!, animated: true, completion: nil)
        }
    }
    
    private var paymentRequest: PKPaymentRequest {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "merchant.com.stn991507719.recipeapp"
        request.supportedNetworks = [.masterCard, .visa, .amex]
        request.supportedCountries = ["CA"]
        request.merchantCapabilities = .capability3DS
        request.countryCode = "CA"
        request.currencyCode = "CAD"
        
        request.paymentSummaryItems = [PKPaymentSummaryItem(label: "Recipe: \(selectedRecipe!.name!)", amount: NSDecimalNumber(value: selectedRecipe!.price!))]

        return request
    }
    
    // remove the selectedRecipeForPurchase from the stack
    @IBAction func doneButtonClicked(sender: UIButton) {
        mainDelegate.selectedRecipeForPurchaseView = nil
        dismiss(animated: true)
    }
}

extension PurchaseViewController: PKPaymentAuthorizationViewControllerDelegate {
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        print("recipe purchase completed")
        let success = mainDelegate.markRecipeAsPurchased(forUser: mainDelegate.USER_ID, forRecipe: selectedRecipe!.id!)
        if success {
            self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
        }
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
    }
    
}
