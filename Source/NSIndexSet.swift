//
//  NSIndexSet.swift
//  Cropable
//
//  Created by mac on 15/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import Foundation

internal extension IndexSet {
  func indexPaths(from section: Int) -> [IndexPath] {
    var indexPaths: [IndexPath] = []
    indexPaths.reserveCapacity(count)
    
    forEach {
        indexPaths.append(IndexPath(item: $0, section: section))
    }
    
    return indexPaths
  }
}
