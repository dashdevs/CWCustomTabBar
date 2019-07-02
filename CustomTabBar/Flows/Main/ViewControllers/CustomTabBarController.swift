//
//  CustomTabBarController.swift
//  CustomTabBar
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import UIKit

final class CustomTabBarController: UITabBarController {
    
    // MARK: - Properties
    
    var customTabBar: CWTabBar = CWTabBar(frame: .zero)
    var rightSwipeGestureRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer()
    var leftSwipeGestureRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer()
    override var selectedViewController: UIViewController? {
        didSet { navigationItem.title = selectedViewController?.title }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBar()
        setupRecognizers()
        
        delegate = self
    }
    
    // MARK: - View Setup
    
    func setupRecognizers() {
        rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        rightSwipeGestureRecognizer.direction = .right
        
        leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        leftSwipeGestureRecognizer.direction = .left
        
        view.addGestureRecognizer(rightSwipeGestureRecognizer)
        view.addGestureRecognizer(leftSwipeGestureRecognizer)
    }
    
    func setupTabBar() {
        customTabBar = CWTabBar.fromNib()
        customTabBar.setup(tabBar: tabBar)
    }
    
    // MARK: - Actions
    
    @objc func didSwipe(_ sender: UISwipeGestureRecognizer) {
        var index = selectedIndex
        index += sender.direction == .left ? 1 : -1
        navigateTo(index)
    }
    
    // MARK: - Navigation
    
    func navigateTo(_ index: Int) {
        guard let controllers = viewControllers, index >= controllers.startIndex, index <= controllers.endIndex - 1 else { return }
        weak var weakSelf = self
        
        let vc = controllers[index]
        weakSelf?.selectedViewController = vc
    }
}

extension CustomTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let fromVCIndex = viewControllers?.lastIndex(of: fromVC), let toVCIndex = viewControllers?.lastIndex(of: toVC) else { return nil }
        let direction: CustomTabBarControllerAnimatedTransitioning.Direction = fromVCIndex < toVCIndex ? .left : .right
        return CustomTabBarControllerAnimatedTransitioning(direction)
    }
}

final class CustomTabBarControllerAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    enum Direction {
        case left
        case right
    }
    
    var direction: Direction
    
    init(_ translationDirection: Direction) {
        direction = translationDirection
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let destination = transitionContext.view(forKey: UITransitionContextViewKey.to) else { return }
        
        let horizontalTranslation = direction == .left ? destination.frame.width : -destination.frame.width
        destination.transform = .init(translationX: horizontalTranslation, y: 0)
        transitionContext.containerView.addSubview(destination)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            destination.transform = .identity
        }, completion: { transitionContext.completeTransition($0) })
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
}
