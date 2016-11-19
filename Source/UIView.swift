//
//  UIView.swift
//  Athlee-ImagePicker
//
//  Created by mac on 15/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit

internal extension UIView {
  func snapshot() -> UIImage {
    UIGraphicsBeginImageContextWithOptions(frame.size, true, 0)
    drawHierarchy(in: bounds, afterScreenUpdates: false)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image!
  }
}
