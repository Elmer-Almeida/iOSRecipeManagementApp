//
//  UserTableViewCell.swift
//  RecipeTrendingAndPurchase
//
//  Created by Elmer Almeida on 2022-04-18.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    
    var safeAreaGuide: UILayoutGuide!
    
    let imageViewItem = UserImageView()
    let userNameLabel = UILabel()
    let userEmailLabel = UILabel()
    let userRecipeCountLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .white
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        safeAreaGuide = layoutMarginsGuide
        setupImageViewItem()
        setupUserNameLabel()
        setupUserEmailLabel()
        setupUserRecipeCountLabel()
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
    
    func setupUserNameLabel() {
        addSubview(userNameLabel)
        
        userNameLabel.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        userNameLabel.textColor = hexStringToUIColor(hex: "#333333")
        
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.leadingAnchor.constraint(equalTo: imageViewItem.trailingAnchor, constant: 15).isActive = true
        userNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14).isActive = true
    }
    
    func setupUserEmailLabel() {
        addSubview(userEmailLabel)
        
        userEmailLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        userEmailLabel.textColor = hexStringToUIColor(hex: "#777777")
        
        userEmailLabel.translatesAutoresizingMaskIntoConstraints = false
        userEmailLabel.leadingAnchor.constraint(equalTo: imageViewItem.trailingAnchor, constant: 15).isActive = true
        userEmailLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 6).isActive = true
    }
    
    func setupUserRecipeCountLabel() {
        addSubview(userRecipeCountLabel)
        
        userRecipeCountLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        userRecipeCountLabel.textColor = .darkGray
        
        userRecipeCountLabel.translatesAutoresizingMaskIntoConstraints = false
        userRecipeCountLabel.leadingAnchor.constraint(equalTo: imageViewItem.trailingAnchor, constant: 15).isActive = true
        userRecipeCountLabel.topAnchor.constraint(equalTo: userEmailLabel.bottomAnchor, constant: 6).isActive = true
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

        return UIColor(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0, blue: CGFloat(rgbValue & 0x0000FF) / 255.0, alpha: CGFloat(1.0))
    }
}
