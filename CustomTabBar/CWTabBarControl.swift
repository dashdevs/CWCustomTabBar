//
//  CWTabBarControl.swift
//  CustomTabBar
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import UIKit

final class CWTabBarControl: UIControl {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemTitleLabel: UILabel!
    var itemTintColor: UIColor?
    
    override var isSelected: Bool {
        didSet {
            itemTitleLabel.isHidden = !isSelected
            itemTitleLabel.alpha = isSelected ? 1.0 : 0.0
            itemImageView.tintColor = isSelected ? .white : .black
        }
    }
    
    func setup(withTabBarItem tabBarItem: UITabBarItem) {
        itemImageView.image = tabBarItem.image?.withRenderingMode(.alwaysTemplate)
        itemImageView.tintColor = .black
        itemTitleLabel.text = tabBarItem.title
        itemTintColor = tabBarItem.badgeColor
    }
}
