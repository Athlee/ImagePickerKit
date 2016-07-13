//
//  Cropable.swift
//  Cropable
//
//  Created by mac on 14/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit

///
/// A protocol providing zooming features to crop the content.
///
protocol Cropable {
  /// A type for content view.
  associatedtype ChildView: UIView
  
  /// A cropable area containing the content.
  var cropView: UIScrollView { get set }
  
  /// A cropable content view.
  var childView: ChildView { get set }
  
  /// This view is shown when cropping is happening.
  var linesView: LinesView { get set }
  
  ///
  /// Adds a cropable view with its content to the provided
  /// container view.
  ///
  /// - parameter view: A container view.
  ///
  func addCropable(to view: UIView)
  
  ///
  /// Updates the current cropable content area, zoom and scale.
  ///
  func updateContent()
  
  ///
  /// Centers a content view in its superview depending on the size.
  ///
  func centerContent()
  
  ///
  /// Handles zoom gestures.
  ///
  func didZoom()
  
  ///
  /// Handles the end of zooming.
  ///
  func didEndZooming()
}

// MARK: - Default implementations for UIImageView childs 

extension Cropable where ChildView == UIImageView {
  ///
  /// Adds a cropable view with its content to the provided
  /// container view.
  ///
  /// - parameter view: A container view.
  ///
  func addCropable(to view: UIView) {
    cropView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(cropView)
    
    let anchors = [
      cropView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
      cropView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
      cropView.topAnchor.constraintEqualToAnchor(view.topAnchor),
      cropView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor)
      ].flatMap { $0 }
    
    NSLayoutConstraint.activateConstraints(anchors)
    
    cropView.backgroundColor = .clearColor()
    cropView.showsHorizontalScrollIndicator = false
    cropView.showsVerticalScrollIndicator = false
    cropView.contentSize = view.bounds.size
    
    cropView.addSubview(childView)
  }
  
  ///
  /// Adds a cropable view with its image to the provided
  /// container view.
  ///
  /// - parameter view: A container view.
  /// - parameter image: An image to use. 
  ///
  func addCropable(to view: UIView, with image: UIImage) {
    addCropable(to: view)
    addImage(image)
  }
  
  ///
  /// Adds an image to the UIImageView child view.
  ///
  /// - parameter image: An image to use. 
  ///
  func addImage(image: UIImage) {
    childView.image = image
    childView.sizeToFit()
    cropView.contentSize = childView.image!.size
    updateContent()
  }
}

// MARK: - Default implementations 

extension Cropable {
  ///
  /// Updated the current cropable content area, zoom and scale.
  ///
  func updateContent() {
    let childViewSize = childView.bounds.size
    let scrollViewSize = cropView.superview!.frame
    let widthScale = scrollViewSize.width / childViewSize.width
    let heightScale = scrollViewSize.height / childViewSize.height
    let scale = min(widthScale, heightScale)
    
    if let _self = self as? UIScrollViewDelegate {
      cropView.delegate = _self
    }
    
    cropView.userInteractionEnabled = true
    cropView.minimumZoomScale = scale
    cropView.maximumZoomScale = 4
    cropView.zoomScale = scale
    
    centerContent()
  }
  
  ///
  /// Centers a content view in its superview depending on the size.
  ///
  func centerContent() {
    let boundsSize = cropView.bounds.size
    var contentFrame = childView.frame
    
    if contentFrame.size.width < boundsSize.width {
      contentFrame.origin.x = (boundsSize.width - contentFrame.width) / 2
    } else {
      contentFrame.origin.x = 0
    }
    
    if contentFrame.size.height < boundsSize.height {
      contentFrame.origin.y = (boundsSize.height - contentFrame.height) / 2
    } else {
      contentFrame.origin.y = 0
    }
    
    childView.frame = contentFrame
  }
  
  ///
  /// Handles zoom gestures.
  ///
  func didZoom() {
    centerContent()
    
    if linesView.superview == nil {
      cropView.addSubview(linesView)
      linesView.backgroundColor = UIColor.clearColor()
      linesView.alpha = 0
    } else {
      UIView.animateWithDuration(0.3) {
        self.linesView.alpha = 1
      }
    }
    
    linesView.frame.size = CGSize(
      width: min(cropView.frame.width, childView.frame.width),
      height: min(cropView.frame.height, childView.frame.height)
    )
    
    let visibleRect = CGRect(origin: cropView.contentOffset, size: cropView.bounds.size)
    let intersection = visibleRect.intersect(childView.frame)
    linesView.frame = intersection
  }
  
  ///
  /// Handles the end of zooming.
  ///
  func didEndZooming() {
    UIView.animateWithDuration(0.1) {
      self.linesView.alpha = 0
    }
  }
}
