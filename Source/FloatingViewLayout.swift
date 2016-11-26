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
public enum State {
  case unfolded
  case folded
  case moved
  
  var description: String {
    switch self {
    case .unfolded:
      return "Unfolded"
    case .folded:
      return "Folded"
    case .moved:
      return "Moved"
    }
  }
}

///
/// Defines directions for a movement with a distance between previous
/// and current touch points as an associated value. Note, that this value
/// type supports only vertical states for now.
///
public enum Direction {
  case up(delta: CGFloat)
  case down(delta: CGFloat)
  case none
  
  ///
  /// Constructs the same direction type with a new
  /// distance passed.
  ///
  /// - parameter delta: The distance passed. 
  /// - returns: The same direction type with a new delta. 
  ///
  func changed(delta: CGFloat) -> Direction {
    if case .up(_) = self {
      return .up(delta: delta)
    } else if case .down(_) = self {
      return .down(delta: delta)
    } else {
      return .none
    }
  }
  
  var description: String {
    switch self {
    case .up(_):
      return "Up"
    case .down(_):
      return "Down"
    case .none:
      return "None"
    }
  }
}

///
/// Options for floating dragging zone.
///
public enum DraggingZone {
  case all
  case some(CGFloat)
}

///
/// The protocol allowing to move a certain view in its superview
/// on pan gestures. The default implementation supports vertical 
/// movement of a given view staying on the top of its superview.
///
public protocol FloatingViewLayout: class {
  /// Determines the minimum area (height or width) to be visible
  /// when the floating view is folded.
  var visibleArea: CGFloat { get set }
  
  /// A zone allowed to drag on.
  var draggingZone: DraggingZone { get set }
  
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
  
  /// A view that fades in on moving the floating view.
  var overlayBlurringView: UIView! { get set }
  
  /// A completion for movement animation.
  var animationCompletion: ((Bool) -> Void)? { get set }
  
  /// Allows to make preparations before the movement is commited.
  func prepareForMovement()
  
  /// This method is called every time the movement is ended.
  func didEndMoving()
  
  ///
  /// Moves a view in a given direction with preset delta. 
  /// 
  /// - parameter view: The view to move. 
  /// - parameter direction: The movement's direction with preset delta. 
  ///
  func move(view: UIView, in direction: Direction)
  
  ///
  /// Receives a pan gesture and provides handle actions.
  ///
  /// - parameter recognizer: The sender gesture recognizer of a pan. 
  /// - parameter view: The floating view that should be moved. 
  ///
  func receivePanGesture(recognizer: UIPanGestureRecognizer, with view: UIView)
  
  ///
  /// Restores a given floating view to the certain state.
  ///
  /// - parameter view: The floating view.
  /// - parameter state: The state to change to.
  /// - parameter animated: Indicates whether the transition should be animated or not. Default value is `false`.
  ///
  func restore(view: UIView, to state: State, animated: Bool)
  
  ///
  /// Determines whether the floating view is moved enough
  /// to be restored when the gesture is ended. 
  ///
  /// - parameter view: The floating view.
  /// - parameter direction: The movement's direction.
  ///
  func crossedEnough(view: UIView, in direction: Direction) -> Bool
}

//
// MARK: - Helpers
//

internal extension FloatingViewLayout {
  func direction(withVelocity velocity: CGPoint, delta: CGFloat) -> Direction {
    if velocity.y < 0 {
      return Direction.up(delta: delta)
    } else if velocity.y > 0 {
      return Direction.down(delta: delta)
    } else {
      return Direction.none
    }
  }
  
  func closestState(of view: UIView) -> State {
    if view.frame.midY <= 0 {
      return .folded
    } else {
      return .unfolded
    }
  }
  
  func prepareOverlayBlurringViews(with view: UIView) {
    overlayBlurringView = UIView()
    overlayBlurringView.backgroundColor = .black
    overlayBlurringView.translatesAutoresizingMaskIntoConstraints = false
    overlayBlurringView.alpha = 0
    
    view.addSubview(overlayBlurringView)
    
    let anchors = [
      overlayBlurringView.topAnchor.constraint(equalTo: view.topAnchor),
      overlayBlurringView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      overlayBlurringView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      overlayBlurringView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
      ].flatMap { $0 }
    
    NSLayoutConstraint.activate(anchors)
  }
}

//
// MARK: - Default implmenetations
//

public extension FloatingViewLayout {
  // Default implementation. It is not required to implement this property.
  var animationCompletion: ((Bool) -> Void)? {
    return nil
  }
  
  // Default implementation. It is not required to implement this method.
  func prepareForMovement() { }
  
  // Default implementation. It is not required to implement this method.
  func didEndMoving() { }
  
  ///
  /// Restores a given floating view to the certain state.
  ///
  /// - parameter view: The floating view.
  /// - parameter state: The state to change to.
  /// - parameter animated: Indicates whether the transition should be animated or not. Default value is `false`.
  ///
  func restore(view: UIView, to state: State, animated: Bool = false) {
    if state == .unfolded {
      topConstraint.constant = 0
    } else if state == .folded {
      topConstraint.constant = -(view.frame.height - visibleArea)
    }
    
    if animated {
      if overlayBlurringView == nil {
        prepareOverlayBlurringViews(with: view)
      }
      
      UIView.animate(
        withDuration: 0.25,
        delay: 0,
        options: [.allowUserInteraction, .beginFromCurrentState, .curveEaseIn],
        animations: {
          view.superview?.layoutIfNeeded()
          self.overlayBlurringView.alpha = self.state == .unfolded ? 0 : 0.6
        },
        
        completion: { finished in
          self.didEndMoving()
          self.animationCompletion?(finished)
        }
      )
    }
  }
  
  ///
  /// Moves a view in a given direction with preset delta.
  ///
  /// - parameter view: The view to move.
  /// - parameter direction: The movement's direction with preset delta.
  ///
  func move(view: UIView, in direction: Direction) {
    switch direction {
    case .up(var delta):
      let maxY = (topConstraint.constant + view.frame.height)
      
      if maxY + delta < visibleArea {
        guard state == .moved else { return }
        delta += visibleArea - (delta + maxY)
      }
      
      prepareForMovement()
      topConstraint.constant += delta
    case .down(var delta):
      let minY = topConstraint.constant
      
      if minY + delta > 0 {
        guard state == .moved else { return }
        delta -= minY + delta
      }
      
      prepareForMovement()
      topConstraint.constant += delta
    case .none:
      print("Direction is not found yet!")
    }
    
    
    if overlayBlurringView == nil {
      prepareOverlayBlurringViews(with: view)
    }
    
    let _progress = abs(topConstraint.constant / -(view.frame.height - visibleArea))
    let progress = _progress > 0.6 ? 0.6 : _progress
    overlayBlurringView.alpha = progress
    
    didEndMoving()
  }
  
  ///
  /// Determines whether the floating view is moved enough
  /// to be restored when the gesture is ended.
  ///
  /// - parameter view: The floating view.
  /// - parameter direction: The movement's direction.
  ///
  func crossedEnough(view: UIView, in direction: Direction) -> Bool {
    if case .down(_) = direction {
      return view.frame.midY >= 0
    } else if case .up(_) = direction {
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
  func receivePanGesture(recognizer: UIPanGestureRecognizer, with view: UIView) {
    guard let superview = recognizer.view else {
      assertionFailure("Unable to find a registered view for UIPangestureRecognizer: \(recognizer).")
      return
    }
    
    let location = recognizer.location(in: superview)
    let velocity = recognizer.velocity(in: superview)
    
    if case let .some(height) = draggingZone, recognizer.state == .began {
      if location.y < view.frame.maxY - height {
        return
      }
    }
    
    guard recognizer.state != .began else {
      previousPoint = location
      return
    }
    
    guard let previousPoint = previousPoint else {
      return
    }
    
    let delta = (location.y - previousPoint.y)
    let _direction = direction(withVelocity: velocity, delta: delta)
    self.previousPoint = location
    
    if view.frame.contains(location) {
      move(view: view, in: _direction)
    } else {
      if case .down(_) = _direction, state == .moved {
        move(view: view, in: _direction)
      } else if allowPanOutside {
        move(view: view, in: _direction)
      }
    }
    
    if recognizer.state == .ended {
      self.previousPoint = nil
      
      guard state == .moved else {
        return
      }
      
      if abs(velocity.y) >= 1000.0 || crossedEnough(view: view, in: _direction) {
        if case .up(_) = _direction {
          restore(view: view, to: .folded, animated: true)
        } else if case .down(_) = _direction {
          restore(view: view, to: .unfolded, animated: true)
        } else {
          restore(view: view, to: closestState(of: view), animated: true)
        }
      } else {
        if case .up(_) = _direction {
          restore(view: view, to: .unfolded, animated: true)
        } else if case .down(_) = _direction {
          restore(view: view, to: .folded, animated: true)
        } else {
          restore(view: view, to: closestState(of: view), animated: true)
        }
      }
    }
  }
  
}
