//
//  LinesView.swift
//  Cropable
//
//  Created by mac on 14/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit

///
/// Draws the horizontal and vertical lines to show
/// that a cropping is happening right now.
///
public final class LinesView: UIView {
  public var lines = 3 { didSet { setNeedsDisplay() } }
  public var columns = 3 { didSet { setNeedsDisplay() } }
  public var width: CGFloat = 1 { didSet { setNeedsDisplay() } }
  public var color = UIColor.white { didSet { setNeedsDisplay() } }
  
  override public func draw(_ rect: CGRect) {
    let verticalSpace = rect.height / CGFloat(lines)
    let horizontalSpace = rect.width / CGFloat(columns)
    
    for i in 1..<lines {
      let path = UIBezierPath(
        rect: CGRect(
          origin: CGPoint(x: 0, y: verticalSpace * CGFloat(i)),
          size: CGSize(width: rect.width, height: width / 2)
        )
      )
      
      color.set()
      path.fill()
    }
    
    for i in 1..<columns {
      let path = UIBezierPath(
        rect: CGRect(
          origin: CGPoint(x: horizontalSpace * CGFloat(i), y: 0),
          size: CGSize(width: width / 2, height: rect.height)
        )
      )
      
      color.set()
      path.fill()
    }
    
    let rectPath = UIBezierPath(rect: rect)
    rectPath.lineWidth = width
    rectPath.stroke()
  }
}
