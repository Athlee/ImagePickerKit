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
  
  var panning = false
  
  init(cropable: T) {
    self.cropable = cropable
  }
  
  // MARK: UIScrollViewDelegate
  
  func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView?) {
    cropable.willZoom()
  }
  
  func scrollViewDidZoom(scrollView: UIScrollView) {
    cropable.didZoom()
  }
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    if cropable.alwaysShowGuidelines {
      cropable.highlightArea(true)
    }
    
    guard panning else {
      return
    }
    
    cropable.highlightArea(true)
  }
  
  func scrollViewWillBeginDragging(scrollView: UIScrollView) {
    panning = true
    cropable.highlightArea(true)
  }
  
  func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    panning = false
    
    if cropable.alwaysShowGuidelines {
      cropable.highlightArea(true, animated: false)
    } else {
      cropable.highlightArea(false, animated: !decelerate)
    }
  }
  
  func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    
  }
  
  func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
    cropable.willEndZooming()
    cropable.didEndZooming()
  }
  
  func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return cropable.childView
  }
}