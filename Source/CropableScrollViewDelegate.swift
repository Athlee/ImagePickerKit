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
  
  // MARK:
  func scrollViewDidZoom(scrollView: UIScrollView) {
    cropable.didZoom()
    print(cropable.linesView.alpha)
  }
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    print("Draggin=\(scrollView.dragging), decelerating=\(scrollView.decelerating)")
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
    cropable.highlightArea(false, animated: !decelerate)
  }
  
  func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

  }
  
//  func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//    cropable.highlightArea(false)
//  }
  
  func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
    cropable.didEndZooming()
  }
  
  func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return cropable.childView
  }
}