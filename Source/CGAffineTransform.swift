//
//  CGAffineTransform.swift
//  Pods
//
//  Created by mac on 27/11/2016.
//
//

import UIKit 

public extension CGAffineTransform {
  public static func scalingFactor(toFill containerSize: CGSize, with contentSize: CGSize, atAngle angle: Double) -> Double {
    var theta = fabs(angle - 2 * .pi * trunc(angle / .pi / 2) - .pi)
    
    if theta > .pi / 2 {
      theta = fabs(.pi - theta)
    }
    
    let h = Double(contentSize.height)
    let H = Double(containerSize.height)
    let w = Double(contentSize.width)
    let W = Double(containerSize.width)
    
    let scale1 = (H * cos(theta) + W * sin(theta)) / min(H, h)
    let scale2 = (H * sin(theta) + W * cos(theta)) / min(W, w)
    
    let scalingFactor = max(scale1, scale2)
    
    return scalingFactor
  }
  
  func scaling(toFill containerSize: CGSize, with contentSize: CGSize, atAngle angle: Double) -> CGAffineTransform {
    let factor = CGFloat(CGAffineTransform.scalingFactor(toFill: containerSize,
                                                         with: contentSize,
                                                         atAngle: angle))
    
    return self.scaledBy(x: factor, y: factor)
  }
}
