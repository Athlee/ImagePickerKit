//
//  NSIndexSet.swift
//  Cropable
//
//  Created by mac on 15/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import Foundation

internal extension NSIndexSet {
  func indexPaths(from section: Int) -> [NSIndexPath] {
    var indexPaths: [NSIndexPath] = []
    indexPaths.reserveCapacity(count)
    
    enumerateIndexesUsingBlock { idx, stop in
      indexPaths.append(NSIndexPath(forItem: idx, inSection: section))
    }
    
    return indexPaths
  }
}