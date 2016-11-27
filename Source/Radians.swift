//
//  Radians.swift
//  Pods
//
//  Created by mac on 27/11/2016.
//
//

import Foundation

public extension Double {
  public func toRadians() -> Double {
    return self * .pi / 180.0
  }
}

public extension Float {
  public func toRadians() -> Float {
    return self * .pi / 180
  }
}
