//
//  ViewController.swift
//  Athlee-ImagePicker
//
//  Created by mac on 13/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit

class ImagePickerController: UIViewController, FloatingViewLayout {
  
  // MARK: Outlets 
  
  @IBOutlet weak var floatingTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var floatingView: UIView!
  @IBOutlet weak var tableView: UITableView!
  
  // MARK: FloatingViewLayout properties
  
  var animationCompletion: ((Bool) -> Void)? = nil 
  
  var overlayBlurringView: UIView!
  
  var topConstraint: NSLayoutConstraint {
    return floatingTopConstraint
  }
  
  var draggingZone: DraggingZone = .all
  
  var visibleArea: CGFloat = 80
  
  var previousPoint: CGPoint?
  
  var state: State {
    if floatingView.frame.origin.y == 0 {
      return .unfolded
    } else if floatingView.frame.maxY == visibleArea {
      return .folded
    } else {
      return .moved
    }
  }
  
  var allowPanOutside = false
  
  // MARK: Life cycle 
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let pan = UIPanGestureRecognizer(target: self, action: #selector(ImagePickerController.didRecognizeMainPan(_:)))
    view.addGestureRecognizer(pan)
    pan.delegate = self
    
    let checkPan = UIPanGestureRecognizer(target: self, action: #selector(ImagePickerController.didRecognizeCheckPan(_:)))
    floatingView.addGestureRecognizer(checkPan)
    checkPan.delegate = self
  }
  
  override var prefersStatusBarHidden : Bool {
    return true 
  }
  
  // MARK: IBActions
  
  @IBAction func didRecognizeMainPan(_ rec: UIPanGestureRecognizer) {
    receivePanGesture(recognizer: rec, with: floatingView)
    tableView.isScrollEnabled = true
    allowPanOutside = false
  }
  
  @IBAction func didRecognizeCheckPan(_ rec: UIPanGestureRecognizer) {
    allowPanOutside = true
    tableView.resignFirstResponder()
  }
  
  // MARK: FloatingViewLayout methods
  
  func prepareForMovement() {
    if state == .unfolded {
      tableView.isScrollEnabled = true
    } else {
      // TODO: Make it smoother
      tableView.isScrollEnabled = true
    }
  }
  
  // MARK: UIScrollViewDelegate
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.y < 0 {
      allowPanOutside = true
    } else {
      allowPanOutside = false
    }
  }
}

// MARK: - UIGestureRecognizerDelegate

extension ImagePickerController: UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}

// MARK: - UITableView management

extension ImagePickerController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 50
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
    return cell
  }
}
