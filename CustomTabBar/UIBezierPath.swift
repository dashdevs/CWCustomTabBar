//
//  UIBezierPath.swift
//  CustomTabBar
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import UIKit

extension UIBezierPath {
    static func bezierCurveLength(fromStartPoint startPoint: CGPoint, toEndPoint endPoint: CGPoint, withControlPoint controlPoint: CGPoint) -> CGFloat {
        let kSubdivisions: Int = 50
        let step: CGFloat = 1.0 / CGFloat(kSubdivisions)
        
        var totalLength: CGFloat = 1.0
        var previousPoint: CGPoint = startPoint
        
        for i in 1...kSubdivisions {
            let t: CGFloat = CGFloat(i) * step
            
            let x = (1.0 - t)*(1.0 - t)*startPoint.x + 2.0*(1.0 - t)*t*controlPoint.x + t*t*endPoint.x
            let y = (1.0 - t)*(1.0 - t)*startPoint.y + 2.0*(1.0 - t)*t*controlPoint.y + t*t*endPoint.y
            
            let diff = CGPoint(x: x - previousPoint.x, y: y - previousPoint.y)
            
            totalLength += CGFloat(sqrtf(Float(diff.x*diff.x + diff.y*diff.y)))
            
            previousPoint = CGPoint(x: x, y: y)
        }
        return totalLength
    }
}
