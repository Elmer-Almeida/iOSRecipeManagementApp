//
//  TrendingTableViewCell.swift
//  RecipeTrendingAndPurchase
//
//  Created by Elmer Almeida on 2022-04-18.
//

import UIKit

class TrendingTableViewCell: UITableViewCell {
    
    var safeAreaGuide: UILayoutGuide!
    
    let imageViewItem = RecipeImageView()
    let recipeNameLabel = UILabel()
    let recipePriceLabel = UILabel()
    let recipeExcerptLabel = UILabel()
    let recipeLikesLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = hexStringToUIColor(hex: "#ffffff")
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        safeAreaGuide = layoutMarginsGuide
        setupRecipeNameLabel()
        setupRecipePriceLabel()
        setupRecipeExcerptLabel()
    }
    
    func setupRecipeNameLabel() {
        addSubview(recipeNameLabel)
        
    }
    
    func setupRecipePriceLabel() {
        
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
