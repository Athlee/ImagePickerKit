//
//  CropViewController.swift
//  Athlee-ImagePicker
//
//  Created by mac on 15/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit

final class CropViewController: UIViewController, FloatingViewLayout, Cropable, ContainerType {

  // MARK: Outlets 
  
  @IBOutlet weak var cropContainerView: UIView!
  
  // MARK: Properties
  
  var parent: HolderViewController! 
  
  var floatingView: UIView {
    return parent.topContainer
  }
  
  // MARK: Cropable properties
  
  var cropView = UIScrollView()
  var childView = UIImageView()
  var linesView = LinesView()
  
  var topOffset: CGFloat {
    guard let navBar = navigationController?.navigationBar else {
      return 0
    }
    
    return !navBar.hidden ? navBar.frame.height : 0
  }
  
  lazy var delegate: CropableScrollViewDelegate<CropViewController> = {
    return CropableScrollViewDelegate(cropable: self)
  }()
  
  // MARK: FloatingViewLayout properties
  
  var topConstraint: NSLayoutConstraint {
    return parent.topConstraint
  }
  
  var draggingZone: DraggingZone = .Some(50)
  
  var visibleArea: CGFloat = 50
  
  var previousPoint: CGPoint?
  
  var state: State {
    if topConstraint.constant == 0 {
      return .Unfolded
    } else if topConstraint.constant + floatingView.frame.height == visibleArea {
      return .Folded
    } else {
      return .Moved
    }
  }
  
  var allowPanOutside = false
  
  // MARK: Life cycle 
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    addCropable(to: cropContainerView)
    cropView.delegate = delegate
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    updateContent()
  }
  
  var recognizersAdded = false
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    updateContent()
    centerContent()
    
    if !recognizersAdded {
      recognizersAdded = true
      
      let pan = UIPanGestureRecognizer(target: self, action: #selector(CropViewController.didRecognizeMainPan(_:)))
      parent.view.addGestureRecognizer(pan)
      pan.delegate = self
      
      let checkPan = UIPanGestureRecognizer(target: self, action: #selector(CropViewController.didRecognizeCheckPan(_:)))
      floatingView.addGestureRecognizer(checkPan)
      checkPan.delegate = self
    }
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  // MARK: IBActions
  
  var zooming = false
  @IBAction func didRecognizeMainPan(rec: UIPanGestureRecognizer) {
    guard !zooming else { return }
    receivePanGesture(recognizer: rec, with: floatingView)
    //tableView.scrollEnabled = true
    allowPanOutside = false
  }
  
  @IBAction func didRecognizeCheckPan(rec: UIPanGestureRecognizer) {
    guard !zooming else { return }
    allowPanOutside = true
    //tableView.resignFirstResponder()
  }
  
  // MARK: FloatingViewLayout methods
  
  func prepareForMovement() {
    updateCropViewScrolling()
  }
  
  func didEndMoving() {
    updateCropViewScrolling()
  }
  
  func updateCropViewScrolling() {
    if state == .Folded || state == .Moved {
      cropView.userInteractionEnabled = false
    } else {
      cropView.userInteractionEnabled = true
    }
  }
  
  // MARK: Cropable methods 
  
  func willZoom() {
    zooming = true
  }
  
  func willEndZooming() {
    zooming = false
  }
  
}

extension CropViewController: UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}
