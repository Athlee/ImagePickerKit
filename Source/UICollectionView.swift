//
//  UICollectionView.swift
//  Cropable
//
//  Created by mac on 15/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit

internal extension UICollectionView {
  func indexPaths(for rect: CGRect) -> [NSIndexPath] {
    guard let allLayoutAttributes = collectionViewLayout.layoutAttributesForElementsInRect(rect) else {
      return []
    }
    
    guard allLayoutAttributes.count > 0 else {
      return []
    }
    
    let indexPaths = allLayoutAttributes.map { $0.indexPath }
    
    return indexPaths
  }
}