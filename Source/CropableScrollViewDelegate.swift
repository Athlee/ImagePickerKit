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
open class CropableScrollViewDelegate<T: Cropable>: NSObject, UIScrollViewDelegate where T: AnyObject {
  fileprivate unowned var cropable: T
  
  open let linesView = LinesView()
  
  fileprivate var panning = false
  
  public init(cropable: T) {
    self.cropable = cropable
  }
  
  // MARK: UIScrollViewDelegate
  
  open func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
    cropable.willZoom()
  }
  
  open func scrollViewDidZoom(_ scrollView: UIScrollView) {
    cropable.didZoom()
  }
  
  open func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if cropable.alwaysShowGuidelines {
      cropable.highlightArea(true)
    }
    
    guard panning else {
      return
    }
    
    cropable.highlightArea(true)
  }
  
  open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    panning = true
    cropable.highlightArea(true)
  }
  
  open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    panning = false
    
    if cropable.alwaysShowGuidelines {
      cropable.highlightArea(true, animated: false)
    } else {
      cropable.highlightArea(false, animated: !decelerate)
    }
  }
  
  open func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
    cropable.willEndZooming()
    cropable.didEndZooming()
  }
  
  open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return cropable.childView
  }
}
