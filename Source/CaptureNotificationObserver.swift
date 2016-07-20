//
//  CaptureNotificationObserver.swift
//  Athlee-ImagePicker
//
//  Created by mac on 16/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit

///
/// A default observer around capture notifications.
///
public final class CaptureNotificationObserver<T: Capturable>: NSObject {
  private unowned var capturable: T
  
  public init(capturable: T) {
    self.capturable = capturable
  }
  
  public func register() {
    let notificationCenter = NSNotificationCenter.defaultCenter()
    notificationCenter.addObserver(
      self,
      selector: #selector(CaptureNotificationObserver.willEnterForegroundNotification(_:)),
      name: UIApplicationWillEnterForegroundNotification, object: nil
    )
  }
  
  public func unregister() {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  public func willEnterForegroundNotification(notification: NSNotification) {
    capturable.willEnterForegroundNotification(notification)
  }
}
