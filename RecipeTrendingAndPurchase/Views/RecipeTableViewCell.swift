//
//  RecipeTableViewCell.swift
//  RecipeTrendingAndPurchase
//
//  Created by Elmer Almeida on 2022-04-18.
//

import UIKit

class RecipeTableViewCell: UITableViewCell {
    
    var safeAreaGuide: UILayoutGuide!
    
    let imageViewItem = RecipeImageView()
    let recipeNameLabel = UILabel()
    let recipePriceLabel = UILabel()
    let recipePurchasedLabel = UILabel()
    let recipeLikesLabel = UILabel()
    let recipeExcerptLabel = UILabel()
    
    let mainDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = mainDelegate.hexStringToUIColor(hex: "#ffffff")
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        safeAreaGuide = layoutMarginsGuide
        setupImageViewItem()
        setupRecipeNameLabel()
        setupRecipePriceLabel()
        setupRecipePurchasedLabel()
        setupRecipeLikesLabel()
        setupRecipeExcerptLabel()
    }
    
    func setupImageViewItem() {
        addSubview(imageViewItem)
        
        imageViewItem.translatesAutoresizingMaskIntoConstraints = false
        imageViewItem.leadingAnchor.constraint(equalTo: safeAreaGuide.leadingAnchor).isActive = true
        imageViewItem.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageViewItem.widthAnchor.constraint(equalToConstant: 80).isActive = true
        imageViewItem.heightAnchor.constraint(equalToConstant: 80).isActive = true
        imageViewItem.layer.cornerRadius = 12
        imageViewItem.clipsToBounds = true
        imageViewItem.layer.masksToBounds = true
        imageViewItem.contentMode = .scaleAspectFill
        
    }
    
    func setupRecipeNameLabel() {
        addSubview(recipeNameLabel)
        
        recipeNameLabel.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        recipeNameLabel.textColor = mainDelegate.hexStringToUIColor(hex: "#333333")
        
        recipeNameLabel.translatesAutoresizingMaskIntoConstraints = false
        recipeNameLabel.leadingAnchor.constraint(equalTo: imageViewItem.trailingAnchor, constant: 15).isActive = true
        recipeNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30).isActive = true
        recipeNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
    }
    
    func setupRecipePriceLabel() {
        addSubview(recipePriceLabel)
        
        recipePriceLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        recipePriceLabel.textColor = mainDelegate.hexStringToUIColor(hex: "#b12704")
        
        recipePriceLabel.translatesAutoresizingMaskIntoConstraints = false
        recipePriceLabel.leadingAnchor.constraint(equalTo: imageViewItem.trailingAnchor, constant: 15).isActive = true
        recipePriceLabel.topAnchor.constraint(equalTo: recipeNameLabel.bottomAnchor, constant: 3).isActive = true
    }
    
    func setupRecipePurchasedLabel() {
        addSubview(recipePurchasedLabel)
        
        recipePurchasedLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        recipePurchasedLabel.textColor = mainDelegate.hexStringToUIColor(hex: "#1560b8")
        
        recipePurchasedLabel.translatesAutoresizingMaskIntoConstraints = false
        recipePurchasedLabel.leadingAnchor.constraint(equalTo: imageViewItem.trailingAnchor, constant: 15).isActive = true
        recipePurchasedLabel.topAnchor.constraint(equalTo: recipeNameLabel.bottomAnchor, constant: 3).isActive = true
    }
    
    func setupRecipeLikesLabel() {
        addSubview(recipeLikesLabel)
        
        recipeLikesLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        recipeLikesLabel.textColor = mainDelegate.hexStringToUIColor(hex: "#79589f")
        
        recipeLikesLabel.translatesAutoresizingMaskIntoConstraints = false
        recipeLikesLabel.leadingAnchor.constraint(equalTo: recipePurchasedLabel.trailingAnchor, constant: 10).isActive = true
        recipeLikesLabel.leadingAnchor.constraint(equalTo: recipePriceLabel.trailingAnchor, constant: 10).isActive = true
        recipeLikesLabel.topAnchor.constraint(equalTo: recipeNameLabel.bottomAnchor, constant: 3).isActive = true
    }
    
    func setupRecipeExcerptLabel() {
        addSubview(recipeExcerptLabel)
        
        recipeExcerptLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        recipeExcerptLabel.textColor = mainDelegate.hexStringToUIColor(hex: "#999999")
        
        recipeExcerptLabel.translatesAutoresizingMaskIntoConstraints = false
        recipeExcerptLabel.leadingAnchor.constraint(equalTo: imageViewItem.trailingAnchor, constant: 15).isActive = true
        recipeExcerptLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40).isActive = true
        recipeExcerptLabel.topAnchor.constraint(equalTo: recipeLikesLabel.bottomAnchor, constant: 3).isActive = true
        recipeExcerptLabel.lineBreakMode = .byTruncatingTail
        recipeExcerptLabel.textColor = .darkGray
    }
    
}
