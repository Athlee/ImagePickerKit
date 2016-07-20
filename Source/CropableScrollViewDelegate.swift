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
public final class CropableScrollViewDelegate<T: Cropable where T: AnyObject>: NSObject, UIScrollViewDelegate {
  private unowned var cropable: T
  
  public let linesView = LinesView()
  
  private var panning = false
  
  init(cropable: T) {
    self.cropable = cropable
  }
  
  // MARK: UIScrollViewDelegate
  
  public func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView?) {
    cropable.willZoom()
  }
  
  public func scrollViewDidZoom(scrollView: UIScrollView) {
    cropable.didZoom()
  }
  
  public func scrollViewDidScroll(scrollView: UIScrollView) {
    if cropable.alwaysShowGuidelines {
      cropable.highlightArea(true)
    }
    
    guard panning else {
      return
    }
    
    cropable.highlightArea(true)
  }
  
  public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
    panning = true
    cropable.highlightArea(true)
  }
  
  public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    panning = false
    
    if cropable.alwaysShowGuidelines {
      cropable.highlightArea(true, animated: false)
    } else {
      cropable.highlightArea(false, animated: !decelerate)
    }
  }
  
  public func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
    cropable.willEndZooming()
    cropable.didEndZooming()
  }
  
  public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return cropable.childView
  }
}