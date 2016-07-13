//
//  FloatingViewLayout.swift
//  Athlee-PhotoPicker
//
//  Created by mac on 12/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit

///
/// Defines states for the floating view. Originally it has 3 states:
/// - Unfolded: default state, the floating view has not been moved.
/// - Folded: the visible area is shown.
/// - Moved: the floating view is moved.
///
enum State {
  case Unfolded
  case Folded
  case Moved
  
  var description: String {
    switch self {
    case .Unfolded:
      return "Unfolded"
    case .Folded:
      return "Folded"
    case .Moved:
      return "Moved"
    }
  }
}

///
/// Defines directions for a movement with a distance between previous
/// and current touch points as an associated value. Note, that this value
/// type supports only vertical states for now.
///
enum Direction {
  case Up(delta: CGFloat)
  case Down(delta: CGFloat)
  case None
  
  ///
  /// Constructs the same direction type with a new
  /// distance passed.
  ///
  /// - parameter delta: The distance passed. 
  /// - returns: The same direction type with a new delta. 
  ///
  func changed(delta delta: CGFloat) -> Direction {
    if case .Up(_) = self {
      return .Up(delta: delta)
    } else if case .Down(_) = self {
      return .Down(delta: delta)
    } else {
      return .None
    }
  }
  
  var description: String {
    switch self {
    case .Up(_):
      return "Up"
    case .Down(_):
      return "Down"
    case .None:
      return "None"
    }
  }
}

///
/// The protocol allowing to move a certain view in its superview
/// on pan gestures. The default implementation supports vertical 
/// movement of a given view staying on the top of its superview.
///
protocol FloatingViewLayout: class {
  /// Determines the minimum area (height or width) to be visible
  /// when the floating view is folded.
  var visibleArea: CGFloat { get set }
  
  /// The previous location of touch.
  var previousPoint: CGPoint? { get set }
  
  /// Current floating view state.
  var state: State { get }
  
  /// Floating view's top constraint. Note, if you use Storyboard
  /// your outlets will be optional, so you'll have to return unwrapped
  /// constraint in a `topConstraint` getter or as a computed property's value.
  var topConstraint: NSLayoutConstraint { get }
  
  /// Determines whether the pans should be handled being found 
  /// outside of the floating view's frame.
  var allowPanOutside: Bool { get set }
  
  /// Allows to make preparations before the movement is commited.
  func prepareForMovement()
  
  ///
  /// Moves a view in a given direction with preset delta. 
  /// 
  /// - parameter view: The view to move. 
  /// - parameter direction: The movement's direction with preset delta. 
  ///
  func move(view view: UIView, in direction: Direction)
  
  ///
  /// Receives a pan gesture and provides handle actions.
  ///
  /// - parameter recognizer: The sender gesture recognizer of a pan. 
  /// - parameter view: The floating view that should be moved. 
  ///
  func receivePanGesture(recognizer recognizer: UIPanGestureRecognizer, with view: UIView)
  
  ///
  /// Restores a given floating view to the certain state. 
  /// Default implementation supports animations built-in.
  /// 
  /// - parameter view: The floating view. 
  /// - parameter state: The state to change to. 
  ///
  func restore(view view: UIView, to state: State)
  
  ///
  /// Determines whether the floating view is moved enough
  /// to be restored when the gesture is ended. 
  ///
  /// - parameter view: The floating view.
  /// - parameter direction: The movement's direction.
  ///
  func crossedEnough(view view: UIView, in direction: Direction) -> Bool
}

//
// MARK: - Helpers
//

extension FloatingViewLayout {
  func direction(withVelocity velocity: CGPoint, delta: CGFloat) -> Direction {
    if velocity.y < 0 {
      return Direction.Up(delta: delta)
    } else if velocity.y > 0 {
      return Direction.Down(delta: delta)
    } else {
      return Direction.None
    }
  }
  
  func closestState(of view: UIView) -> State {
    if view.frame.midY <= 0 {
      return .Folded
    } else {
      return .Unfolded
    }
  }
}

//
// MARK: - Default implmenetations
//

extension FloatingViewLayout {
  
  // Default implementation. It is not required to implement this method.
  func prepareForMovement() { }
  
  ///
  /// Restores a given floating view to the certain state.
  ///
  /// - parameter view: The floating view.
  /// - parameter state: The state to change to.
  ///
  func restore(view view: UIView, to state: State) {
    if state == .Unfolded {
      topConstraint.constant = 0
    } else if state == .Folded {
      topConstraint.constant = -(view.frame.height - visibleArea)
    }
  }
  
  ///
  /// Moves a view in a given direction with preset delta.
  ///
  /// - parameter view: The view to move.
  /// - parameter direction: The movement's direction with preset delta.
  ///
  func move(view view: UIView, in direction: Direction) {
    switch direction {
    case .Up(let delta):
      guard view.frame.maxY + delta >= visibleArea else {
        //restore(view: view, to: .Folded)
        return
      }
      
      prepareForMovement()
      topConstraint.constant += delta
    case .Down(let delta):
      guard view.frame.minY + delta <= 0 else {
        //restore(view: view, to: .Unfolded)
        return
      }
      
      prepareForMovement()
      topConstraint.constant += delta
    case .None:
      print("Direction is not found yet!")
    }
    
    UIView.animateWithDuration(
      0.1,
      delay: 0,
      options: [.AllowUserInteraction, .BeginFromCurrentState, .CurveEaseIn],
      animations: {
        view.superview?.layoutIfNeeded()
      },
      completion: nil
    )
  }
  
  ///
  /// Determines whether the floating view is moved enough
  /// to be restored when the gesture is ended.
  ///
  /// - parameter view: The floating view.
  /// - parameter direction: The movement's direction.
  ///
  func crossedEnough(view view: UIView, in direction: Direction) -> Bool {
    if case .Down(_) = direction {
      return view.frame.midY >= 0
    } else if case .Up(_) = direction {
      return view.frame.midY <= 0
    } else {
      return false
    }
  }
  
  ///
  /// Receives a pan gesture and provides handle actions.
  ///
  /// - parameter recognizer: The sender gesture recognizer of a pan.
  /// - parameter view: The floating view that should be moved.
  ///
  func receivePanGesture(recognizer recognizer: UIPanGestureRecognizer, with view: UIView) {
    guard let superview = recognizer.view else {
      assertionFailure("Unable to find a registered view for UIPangestureRecognizer: \(recognizer).")
      return
    }
    
    let location = recognizer.locationInView(superview)
    let velocity = recognizer.velocityInView(superview)
    
    guard recognizer.state != .Began else {
      previousPoint = location
      return
    }
    
    guard let previousPoint = previousPoint else {
      assertionFailure("Previous point has been unexpectedly mutated!")
      return
    }
    
    let delta = (location.y - previousPoint.y)
    let _direction = direction(withVelocity: velocity, delta: delta)
    self.previousPoint = location
    
    if view.frame.contains(location) {
      move(view: view, in: _direction)
    } else {
      if case .Down(_) = _direction where state == .Moved {
        move(view: view, in: _direction)
      } else if allowPanOutside {
        move(view: view, in: _direction)
      }
    }
    
    if recognizer.state == .Ended && state == .Moved {
      self.previousPoint = nil
      
      if abs(velocity.y) >= 1000.0 || crossedEnough(view: view, in: _direction) {
        if case .Up(_) = _direction {
          restore(view: view, to: .Folded)
        } else if case .Down(_) = _direction {
          restore(view: view, to: .Unfolded)
        } else {
          restore(view: view, to: closestState(of: view))
        }
      } else {
        if case .Up(_) = _direction {
          restore(view: view, to: .Unfolded)
        } else if case .Down(_) = _direction {
          restore(view: view, to: .Folded)
        } else {
          restore(view: view, to: closestState(of: view))
        }
      }

      UIView.animateWithDuration(
        0.25,
        delay: 0,
        options: [.AllowUserInteraction, .BeginFromCurrentState, .CurveEaseIn],
        animations: {
          view.superview?.layoutIfNeeded()
        },
        completion: nil
      )
    }
    
  }
  
}