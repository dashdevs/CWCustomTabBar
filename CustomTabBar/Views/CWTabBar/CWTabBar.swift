//
//  CWTabBar.swift
//  CustomTabBar
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import UIKit

@IBDesignable final class CWTabBar: UIView {
    
    // MARK: - Properties
    
    var observation: NSKeyValueObservation?
    
    @IBInspectable var curveHeight: CGFloat = 100.0 {
        willSet {
            self.curveHeight = min(newValue, frame.width)
            generateCurve()
        }
    }
    
    @IBInspectable var curveFactor: CGFloat = 4.0 {
        willSet {
            self.curveFactor = max(0, newValue)
            generateCurve()
        }
    }
    
    @IBInspectable var curveStart: CGFloat = 100.0 {
        willSet {
            self.curveStart = min(newValue, frame.width)
            generateCurve()
        }
    }
    
    @IBInspectable var curveLineWidth: CGFloat = 0.26 {
        willSet {
            self.curveLineWidth = newValue
            generateCurve()
        }
    }
    
    @IBOutlet weak var itemsView: UIStackView!
    @IBOutlet weak var selectionView: UIView!
    
    var borderColor: UIColor = .darkGray
    
    var selectedItem: CWTabBarControl? {
        didSet {
            let didUpdate = selectedItem != oldValue
            let duration = 0.5
            UIView.animate(withDuration: duration) {
                if let selected = self.selectedItem?.isSelected, didUpdate { self.selectedItem?.isSelected = !selected }
                if let selected = oldValue?.isSelected, didUpdate { oldValue?.isSelected = !selected }
                
                if let item = self.selectedItem {
                    self.selectionView.backgroundColor = self.selectedItem?.itemTintColor
                    
                    let identityModifier: CGFloat = 1.0
                    let heightModifier: CGFloat = 1.5
                    let rightSpacing: CGFloat = 4.0
                    
                    var selectionViewFrame = item.frame.applying(.init(scaleX: identityModifier, y: heightModifier))
                    
                    selectionViewFrame.origin = CGPoint(x: selectionViewFrame.origin.x, y: selectionViewFrame.origin.y - selectionViewFrame.height / (identityModifier + heightModifier))
                    selectionViewFrame.size = CGSize(width: item.itemTitleLabel.frame.origin.x + item.itemTitleLabel.frame.width + rightSpacing,
                                                     height: selectionViewFrame.height)
                    self.selectionView.frame = selectionViewFrame
                }
                self.layoutIfNeeded()
            }
        }
    }
    
    var items: [CWTabBarControl]?
    
    private var curveLayer = CAShapeLayer()
    
    // MARK: - Lifecycle
    
    func setup(tabBar: UITabBar) {
        self.backgroundColor = tabBar.backgroundColor ?? tabBar.barTintColor
        
        autoresizingMask = .flexibleWidth
        tabBar.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([bottomAnchor.constraint(equalTo: tabBar.bottomAnchor),
                                     leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
                                     trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
                                     heightAnchor.constraint(equalTo: tabBar.heightAnchor)])
        
        isUserInteractionEnabled = false
        
        items = [CWTabBarControl]()
        for tabBarIndex in 0...(tabBar.items?.count ?? 1) - 1 {
            let control: CWTabBarControl = CWTabBarControl.fromNib()
            guard let tabBarItem = tabBar.items?[tabBarIndex] else { break }
            control.setup(withTabBarItem: tabBarItem)
            items?.append(control)
            itemsView.addArrangedSubview(control)
        }
        
        self.observation = tabBar.observe(\.selectedItem) { [unowned self] tabBar, change in
            if let item = tabBar.selectedItem, let index = tabBar.items?.lastIndex(of: item) {
                self.selectedItem = self.items?[index]
            }
        }
        
        setupAppearance()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupAppearance()
    }
    
    // MARK: - View setup
    
    private func setupAppearance() {
        self.generateCurve()
        
        layer.masksToBounds = false
        layoutIfNeeded()
    }
    
    func generateCurve() {
        let endPoint = CGPoint(x: 0, y: -curveHeight)
        let startPoint = CGPoint(x: curveStart, y: 0)
        let controlPoint = CGPoint(x: startPoint.x / curveFactor, y: endPoint.y / curveFactor)
        
        let curveLength = UIBezierPath.bezierCurveLength(fromStartPoint: startPoint, toEndPoint: endPoint, withControlPoint: controlPoint)
        let pathLength = curveStart + curveHeight + curveLength
        let curveRatio = curveLength / pathLength
        let curveBeginning = (1.0 - curveRatio) / 2
        
        let rectangle = UIBezierPath(rect: .zero)
        rectangle.addLine(to: startPoint)
        rectangle.addQuadCurve(to: endPoint, controlPoint: controlPoint)
        rectangle.addLine(to: frame.origin)
        rectangle.close()
        
        curveLayer.removeFromSuperlayer()
        curveLayer.frame = CGRect(origin: .zero, size: CGSize(width: bounds.width, height: bounds.height + curveHeight))
        curveLayer.strokeColor = borderColor.cgColor
        curveLayer.lineWidth = curveLineWidth
        curveLayer.strokeStart = curveBeginning + curveLineWidth / curveLength
        curveLayer.strokeEnd = curveBeginning + curveRatio
        curveLayer.path = rectangle.cgPath
        curveLayer.fillColor = backgroundColor?.cgColor
        
        layer.addSublayer(curveLayer)
    }
}
