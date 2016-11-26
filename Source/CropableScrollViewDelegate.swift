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
  
  /// Indicates whether cropping should or should not be enabled for using.
  open var isEnabled = true {
    didSet {
      if isEnabled {
        cropable.cropView.isScrollEnabled = true
      } else {
        cropable.highlightArea(false, animated: false)
        cropable.cropView.isScrollEnabled = false 
      }
    }
  }
  
  fileprivate var isPanning = false
  
  // MARK: Initialization
  
  public init(cropable: T) {
    self.cropable = cropable
  }
  
  // MARK: UIScrollViewDelegate
  
  open func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
    guard isEnabled else { return }
    
    cropable.willZoom()
  }
  
  open func scrollViewDidZoom(_ scrollView: UIScrollView) {
    guard isEnabled else { return }
    
    cropable.didZoom()
  }
  
  open func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard isEnabled else { return }
    
    if cropable.alwaysShowGuidelines {
      cropable.highlightArea(true)
    }
    
    guard isPanning else {
      return
    }
    
    cropable.highlightArea(true)
  }
  
  open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    guard isEnabled else { return }
    
    isPanning = true
    cropable.highlightArea(true)
  }
  
  open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    guard isEnabled else { return }
    
    isPanning = false
    
    if cropable.alwaysShowGuidelines {
      cropable.highlightArea(true, animated: false)
    } else {
      cropable.highlightArea(false, animated: !decelerate)
    }
  }
  
  open func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
    guard isEnabled else { return }
    
    cropable.willEndZooming()
    cropable.didEndZooming()
  }
  
  open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return cropable.childView
  }
}
