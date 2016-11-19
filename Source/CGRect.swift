//
//  CGRect.swift
//  Cropable
//
//  Created by mac on 15/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit

internal extension CGRect {
  enum Difference {
    case added(area: CGRect)
    case removed(area: CGRect)
  }
  
  // TODO: Make this function accurate in case of Geometry.
  func exclusiveOr(_ rect: CGRect) -> [CGRect] {
    var res: [CGRect] = []
    
    if rect.maxY > self.maxY {
      let x = max(rect.origin.x, self.origin.x)
      let bottomExtraRect = CGRect(
        origin: CGPoint(x: x, y: self.maxY),
        size: CGSize(width: rect.width, height: rect.maxY - self.maxY)
      )
      
      res.append(bottomExtraRect)
    }
    
    if self.minY > rect.minY {
      let x = max(rect.origin.x, self.origin.x)
      let topExtraRect = CGRect(
        origin: CGPoint(x: x, y: rect.minY),
        size: CGSize(width: rect.width, height: self.minY - rect.minY)
      )
      
      res.append(topExtraRect)
    }
    
    return res
  }
  
  func difference(with rect: CGRect) -> [Difference] {
    guard intersects(rect) else {
      return [.added(area: rect), .removed(area: self)]
    }
    
    let added = exclusiveOr(rect).map { Difference.added(area: $0) }
    let removed = rect.exclusiveOr(self).map { Difference.removed(area: $0) }
    
    return added + removed
  }
}
