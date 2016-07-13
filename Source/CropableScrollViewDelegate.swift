//
//  CropableScrollViewDelegate.swift
//  Cropable
//
//  Created by mac on 14/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit

///
/// A `UIScrollViewDelegate` for `Cropable` objects.
///
final class CropableScrollViewDelegate<T: Cropable where T: AnyObject>: NSObject, UIScrollViewDelegate {
  unowned var cropable: T
  
  let linesView = LinesView()
  
  init(cropable: T) {
    self.cropable = cropable
  }
  
  func scrollViewDidZoom(scrollView: UIScrollView) {
    cropable.didZoom()
  }
  
  func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
    cropable.didEndZooming()
  }
  
  func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return cropable.childView
  }
}