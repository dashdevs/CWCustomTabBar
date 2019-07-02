//
//  UIViewExtensions.swift
//  CustomTabBar
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import UIKit

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}
