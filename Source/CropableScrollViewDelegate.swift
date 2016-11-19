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
public final class CropableScrollViewDelegate<T: Cropable>: NSObject, UIScrollViewDelegate where T: AnyObject {
  fileprivate unowned var cropable: T
  
  public let linesView = LinesView()
  
  fileprivate var panning = false
  
  public init(cropable: T) {
    self.cropable = cropable
  }
  
  // MARK: UIScrollViewDelegate
  
  public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
    cropable.willZoom()
  }
  
  public func scrollViewDidZoom(_ scrollView: UIScrollView) {
    cropable.didZoom()
  }
  
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if cropable.alwaysShowGuidelines {
      cropable.highlightArea(true)
    }
    
    guard panning else {
      return
    }
    
    cropable.highlightArea(true)
  }
  
  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    panning = true
    cropable.highlightArea(true)
  }
  
  public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    panning = false
    
    if cropable.alwaysShowGuidelines {
      cropable.highlightArea(true, animated: false)
    } else {
      cropable.highlightArea(false, animated: !decelerate)
    }
  }
  
  public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
    cropable.willEndZooming()
    cropable.didEndZooming()
  }
  
  public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return cropable.childView
  }
}
