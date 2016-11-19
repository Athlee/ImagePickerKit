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
  fileprivate unowned var capturable: T
  
  public init(capturable: T) {
    self.capturable = capturable
  }
  
  public func register() {
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(
      self,
      selector: #selector(CaptureNotificationObserver.willEnterForegroundNotification(_:)),
      name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil
    )
  }
  
  public func unregister() {
    NotificationCenter.default.removeObserver(self)
  }
  
  public func willEnterForegroundNotification(_ notification: Notification) {
    capturable.willEnterForegroundNotification(notification)
  }
}
