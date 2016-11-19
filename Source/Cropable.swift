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
public protocol Cropable {
  /// A type for content view.
  associatedtype ChildView: UIView
  
  /// A cropable area containing the content.
  var cropView: UIScrollView { get set }
  
  /// A cropable content view.
  var childView: ChildView { get set }
  
  /// This view is shown when cropping is happening.
  var linesView: LinesView { get set }
  
  /// Top offset for cropable content. If your `cropView`
  /// is constrained with `UINavigationBar` or anything on
  /// the top, set this offset so the content can be properly
  /// centered and scaled.
  ///
  /// Default value is `0.0`.
  var topOffset: CGFloat { get }
  
  /// Determines whether the guidelines' grid should be
  /// constantly showing on the cropping view.
  /// Default value is `false`.
  var alwaysShowGuidelines: Bool { get }
  
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
  /// This method is called whenever the zooming
  /// is about to start. It might be useful if
  /// you use a built-in `CropableScrollViewDelegate`.
  ///
  /// **ATTENTION**, default implementation
  /// is a placeholder!
  ///
  func willZoom()
  
  ///
  /// This method is called whenever the zooming
  /// is about to end. It might be useful if
  /// you use a built-in `CropableScrollViewDelegate`.
  ///
  /// **ATTENTION**, default implementation
  /// is a placeholder!
  ///
  func willEndZooming()
  
  ///
  /// Handles zoom gestures.
  ///
  func didZoom()
  
  ///
  /// Handles the end of zooming.
  ///
  func didEndZooming()
  
  ///
  /// Highlights an area of cropping by showing
  /// rectangular zone.
  ///
  /// - parameter highlght: A flag indicating whether it should show or hide the zone.
  /// - parameter animated: An animation flag, it's `true` by default.
  ///
  func highlightArea(_ highlight: Bool, animated: Bool)
}

// MARK: - Default implementations for UIImageView childs

public extension Cropable where ChildView == UIImageView {
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
      cropView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      cropView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      cropView.topAnchor.constraint(equalTo: view.topAnchor),
      cropView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
      ].flatMap { $0 }
    
    NSLayoutConstraint.activate(anchors)
    
    cropView.backgroundColor = .clear
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
  /// - parameter adjustingContent: Indicates whether the content should be adjusted or not. Default value is `true`.
  ///
  func addImage(_ image: UIImage, adjustingContent: Bool = true) {
    childView.image = image
    
    if adjustingContent {
      childView.sizeToFit()
      childView.frame.origin = .zero
      cropView.contentSize = childView.image!.size
      
      updateContent()
      highlightArea(false, animated: false)
    }
  }
}

// MARK: - Default implementations

public extension Cropable {
  /// Top offset for cropable content. If your `cropView`
  /// is constrained with `UINavigationBar` or anything on
  /// the top, set this offset so the content can be properly
  /// centered and scaled.
  ///
  /// Default value is `0.0`.
  var topOffset: CGFloat {
    return 0
  }
  
  /// Determines whether the guidelines' grid should be
  /// constantly showing on the cropping view.
  /// Default value is `false`.
  var alwaysShowGuidelines: Bool {
    return false
  }
  
  ///
  /// Updated the current cropable content area, zoom and scale.
  ///
  func updateContent() {
    let childViewSize = childView.bounds.size
    let scrollViewSize = cropView.superview!.frame
    let widthScale = scrollViewSize.width / childViewSize.width
    let heightScale = scrollViewSize.height / childViewSize.height
    let scale = min(heightScale, widthScale)
    
    if let _self = self as? UIScrollViewDelegate {
      cropView.delegate = _self
    }
    
    cropView.minimumZoomScale = scale
    cropView.maximumZoomScale = 4
    cropView.zoomScale = scale
    
    centerContent()
    
    highlightArea(alwaysShowGuidelines, animated: false)
  }
  
  ///
  /// Centers a content view in its superview depending on the size.
  ///
  func centerContent() {
    let boundsSize = cropView.bounds.size
    let contentFrame = childView.frame
    var origin = contentFrame.origin
    
    if contentFrame.size.width < boundsSize.width {
      origin.x = (boundsSize.width - contentFrame.width) / 2
    } else {
      origin.x = 0
    }
    
    if contentFrame.size.height < boundsSize.height {
      origin.y = (boundsSize.height - contentFrame.height) / 2
    } else {
      origin.y = 0
    }
    
    origin.y -= topOffset
    cropView.contentInset.bottom = -topOffset
    childView.frame.origin = origin
  }
  
  ///
  /// This method is called whenever the zooming
  /// is about to start. It might be useful if
  /// you use a built-in `CropableScrollViewDelegate`.
  ///
  /// **ATTENTION**, default implementation
  /// is a placeholder!
  ///
  func willZoom() { }
  
  ///
  /// This method is called whenever the zooming
  /// is about to end. It might be useful if
  /// you use a built-in `CropableScrollViewDelegate`.
  ///
  /// **ATTENTION**, default implementation
  /// is a placeholder!
  ///
  func willEndZooming() { }
  
  ///
  /// Handles zoom gestures.
  ///
  func didZoom() {
    centerContent()
    highlightArea(true)
  }
  
  ///
  /// Handles the end of zooming.
  ///
  func didEndZooming() {
    guard !alwaysShowGuidelines else { return }
    highlightArea(false)
  }
  
  ///
  /// Highlights an area of cropping by showing
  /// rectangular zone.
  ///
  /// - parameter highlght: A flag indicating whether it should show or hide the zone.
  /// - parameter animated: An animation flag, it's `true` by default.
  ///
  func highlightArea(_ highlight: Bool, animated: Bool = true) {
    guard UIApplication.shared.keyWindow != nil else {
      return
    }
    
    linesView.setNeedsDisplay()
    if linesView.superview == nil {
      cropView.insertSubview(linesView, aboveSubview: childView)
      linesView.backgroundColor = UIColor.clear
      linesView.alpha = 0
    } else {
      if animated {
        UIView.animate(
          withDuration: 0.3,
          delay: 0,
          options: [.allowUserInteraction],
          animations: {
            self.linesView.alpha = highlight ? 1 : 0
          },
          
          completion: nil
        )
      } else {
        linesView.alpha = highlight ? 1 : 0
      }
      
    }
    
    linesView.frame.size = CGSize(
      width: min(cropView.frame.width, childView.frame.width),
      height: min(cropView.frame.height, childView.frame.height)
    )
    
    let visibleRect = CGRect(origin: cropView.contentOffset, size: cropView.bounds.size)
    let intersection = visibleRect.intersection(childView.frame)
    linesView.frame = intersection
  }
}

