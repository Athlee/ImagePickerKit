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
open class CaptureNotificationObserver<T: Capturable>: NSObject {
  fileprivate unowned var capturable: T
  
  public init(capturable: T) {
    self.capturable = capturable
  }
  
  open func register() {
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(
      self,
      selector: #selector(CaptureNotificationObserver.willEnterForegroundNotification(_:)),
      name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil
    )
  }
  
  open func unregister() {
    NotificationCenter.default.removeObserver(self)
  }
  
  open func willEnterForegroundNotification(_ notification: Notification) {
    capturable.willEnterForegroundNotification(notification)
  }
}
