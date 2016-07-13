//
//  ViewController.swift
//  Athlee-ImagePicker
//
//  Created by mac on 13/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FloatingViewLayout {
  
  // MARK: Outlets 
  
  @IBOutlet weak var floatingTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var floatingView: UIView!
  @IBOutlet weak var tableView: UITableView!
  
  // MARK: FloatingViewLayout properties
  
  var topConstraint: NSLayoutConstraint {
    return floatingTopConstraint
  }
  
  var visibleArea: CGFloat = 80
  
  var previousPoint: CGPoint?
  
  var state: State {
    if floatingView.frame.origin.y == 0 {
      return .Unfolded
    } else if floatingView.frame.maxY == visibleArea {
      return .Folded
    } else {
      return .Moved
    }
  }
  
  var allowPanOutside = false
  
  // MARK: Life cycle 
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let pan = UIPanGestureRecognizer(target: self, action: #selector(ViewController.didRecognizeMainPan(_:)))
    view.addGestureRecognizer(pan)
    pan.delegate = self
    
    let checkPan = UIPanGestureRecognizer(target: self, action: #selector(ViewController.didRecognizeCheckPan(_:)))
    floatingView.addGestureRecognizer(checkPan)
    checkPan.delegate = self
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true 
  }
  
  // MARK: IBActions
  
  @IBAction func didRecognizeMainPan(rec: UIPanGestureRecognizer) {
    receivePanGesture(recognizer: rec, with: floatingView)
    tableView.scrollEnabled = true
    allowPanOutside = false
  }
  
  @IBAction func didRecognizeCheckPan(rec: UIPanGestureRecognizer) {
    allowPanOutside = true
    tableView.resignFirstResponder()
  }
  
  // MARK: FloatingViewLayout methods
  
  func prepareForMovement() {
    if state == .Unfolded {
      tableView.scrollEnabled = true
    } else {
      // TODO: Make it smoother
      tableView.scrollEnabled = true
    }
  }
  
  // MARK: UIScrollViewDelegate
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    if scrollView.contentOffset.y < 0 {
      allowPanOutside = true
    } else {
      allowPanOutside = false
    }
  }
}

// MARK: - UIGestureRecognizerDelegate

extension ViewController: UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}

// MARK: - UITableView management

extension ViewController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 50
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
    return cell
  }
}
