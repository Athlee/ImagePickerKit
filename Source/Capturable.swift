//
//  Capturable.swift
//  Athlee-ImagePicker
//
//  Created by mac on 16/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit
import AVFoundation

///
/// Provides featrues for previewing and capturing
/// using a device camera.
///
public protocol Capturable: class {
  
  /// Current capture session.
  var session: AVCaptureSession? { get set }
  
  /// Current capture device.
  var device: AVCaptureDevice? { get set }
  
  /// An input to be captured from.
  var videoInput: AVCaptureDeviceInput? { get set }
  
  /// An output for capturing still images.
  var imageOutput: AVCaptureStillImageOutput? { get set }
  
  /// A view indicating the focusing area.
  var focusView: UIView? { get set }
  
  /// A preview container view where the live camera record is shown.
  var previewViewContainer: UIView { get set }
  
  /// A default capture notification observer. 
  /// If you want to observe by yourself, 
  /// implement `registerForNotifications` method. 
  /// And do not forget to unregister on deinit.
  var captureNotificationObserver: CaptureNotificationObserver<Self>? { get set }
  
  /// 
  /// Provides all necessary preparations for 
  /// the capture session.
  ///
  func prepareForCapturing()
  
  ///
  /// Starts capturing from a device camera.
  ///
  func startCamera()
  
  ///
  /// Stops capturing from a device camera.
  ///
  func stopCamera()
  
  ///
  /// Adds a preview layer at a given view.
  ///
  /// - parameter view: A view to contain the preview.
  ///
  func addPreviewLayer(at view: UIView)
  
  ///
  /// Reloads a given preview.
  ///
  /// - parameter view: A holder of the preview.
  ///
  func reloadPreview(view: UIView)
  
  ///
  /// Registers an observer for notifications (when the device
  /// goes in foreground).
  ///
  func registerForNotifications()
  
  ///
  /// Unregisters an observer for notifications.
  ///
  func unregisterForNotifications()
  
  ///
  /// Flips the camera.
  ///
  func flipCamera()
  
  ///
  /// Sets a camera capture flash mode.
  ///
  /// - parameter mode: A capture flash mode.
  ///
  func setFlashMode(mode: AVCaptureFlashMode)
  
  ///
  /// Provides camera focusing at the certain area aroung the point provided.
  ///
  /// - parameter point: A point around of which the focusing is done.
  ///
  func focus(at point: CGPoint)
}

// MARK: - Default implementations

extension Capturable {
  
  ///
  /// Provides all necessary preparations for
  /// the capture session.
  ///
  func prepareForCapturing() {
    if session == nil {
      session = AVCaptureSession()
    }
    
    for device in AVCaptureDevice.devices() {
      if let device = device as? AVCaptureDevice where device.position == AVCaptureDevicePosition.Back {
        self.device = device
      }
    }
    
    do {
      if let session = session {
        videoInput = try AVCaptureDeviceInput(device: device)
        session.addInput(videoInput)
        imageOutput = AVCaptureStillImageOutput()
        session.addOutput(imageOutput)
        
        addPreviewLayer(at: previewViewContainer)
        
        session.startRunning()
      }
    } catch {
      assertionFailure("Unable to connect to the device input....")
    }
    
    setFlashMode(.Auto)
    startCamera()
    registerForNotifications()
  }
  
  ///
  /// Starts capturing from a device camera.
  ///
  func startCamera() {
    let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
    
    if status == AVAuthorizationStatus.Authorized {
      session?.startRunning()
    } else if status == AVAuthorizationStatus.Denied || status == AVAuthorizationStatus.Restricted {
      session?.stopRunning()
    }
  }
  
  ///
  /// Stops capturing from a device camera.
  ///
  func stopCamera() {
    session?.stopRunning()
  }
  
  ///
  /// Adds a preview layer at a given view.
  ///
  /// - parameter view: A view to contain the preview.
  ///
  func addPreviewLayer(at view: UIView) {
    let videoLayer = AVCaptureVideoPreviewLayer(session: session)
    videoLayer.frame = view.bounds
    videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    
    dispatch_async(dispatch_get_main_queue()) {
      view.layer.addSublayer(videoLayer)
    }
  }
  
  ///
  /// Reloads a given preview.
  ///
  /// - parameter view: A holder of the preview.
  ///
  func reloadPreview(view: UIView) {
    view.layer.sublayers?.forEach {
      if $0 is AVCaptureVideoPreviewLayer {
        $0.frame = self.previewViewContainer.bounds
      }
    }
  }
  
  ///
  /// Registers an observer for notifications (when the device
  /// goes in foreground).
  ///
  func registerForNotifications() {
    captureNotificationObserver = CaptureNotificationObserver(capturable: self)
    captureNotificationObserver?.register()
  }
  
  ///
  /// Unregisters an observer for notifications.
  ///
  func unregisterForNotifications() {
    captureNotificationObserver?.unregister()
  }
  
  ///
  /// Flips the camera.
  ///
  func flipCamera() {
    if !cameraIsAvailable() {
      return
    }
    
    session?.stopRunning()
    
    do {
      session?.beginConfiguration()
      
      if let session = session {
        for input in session.inputs {
          session.removeInput(input as! AVCaptureInput)
        }
        
        let position = (videoInput?.device.position == AVCaptureDevicePosition.Front) ? AVCaptureDevicePosition.Back : AVCaptureDevicePosition.Front
        
        for device in AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) {
          if let device = device as? AVCaptureDevice where device.position == position {
            videoInput = try AVCaptureDeviceInput(device: device)
            session.addInput(videoInput)
          }
        }
      }
      
      session?.commitConfiguration()
    } catch {
      assertionFailure("Unable to connect to the device input....")
    }
    
    session?.startRunning()
  }
  
  ///
  /// Sets a camera capture flash mode.
  ///
  /// - parameter mode: A capture flash mode.
  ///
  func setFlashMode(mode: AVCaptureFlashMode) {
    guard cameraIsAvailable() else { return }
    
    do {
      if let device = device {
        guard device.hasFlash else { return }
        try device.lockForConfiguration()
        device.flashMode = mode
        device.unlockForConfiguration()
      }
    } catch {
      assertionFailure("Unable to lock device for configuration. Error: \(error)")
      device?.flashMode = .Off
      return
    }
  }
  
  ///
  /// Provides camera focusing at the certain area aroung the point provided.
  ///
  /// - parameter point: A point around of which the focusing is done.
  ///
  func focus(at point: CGPoint) {
    if focusView == nil {
      focusView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
      previewViewContainer.addSubview(focusView!)
    }
    
    guard let superview = previewViewContainer.superview else {
      assertionFailure("Preview does not have a superview!")
      return
    }
    
    let viewsize = superview.bounds.size
    let newPoint = CGPoint(
      x: point.y / viewsize.height,
      y: 1.0 - point.x / viewsize.width
    )
    
    let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    
    do {
      try device.lockForConfiguration()
    } catch {
      assertionFailure("Unable to lock device for configuration. Error: \(error)")
      return
    }
    
    if device.isFocusModeSupported(AVCaptureFocusMode.AutoFocus) == true {
      device.focusMode = AVCaptureFocusMode.AutoFocus
      device.focusPointOfInterest = newPoint
    }
    
    if device.isExposureModeSupported(AVCaptureExposureMode.ContinuousAutoExposure) == true {
      device.exposureMode = AVCaptureExposureMode.ContinuousAutoExposure
      device.exposurePointOfInterest = newPoint
    }
    
    device.unlockForConfiguration()
    
    focusView?.alpha = 0.0
    focusView?.center = point
    focusView?.backgroundColor = UIColor.clearColor()
    focusView?.layer.borderColor = UIColor.orangeColor().CGColor
    focusView?.layer.borderWidth = 1.0
    focusView!.transform = CGAffineTransformMakeScale(1.0, 1.0)
    
    UIView.animateWithDuration(
      0.8,
      delay: 0.0,
      usingSpringWithDamping: 0.8,
      initialSpringVelocity: 3.0,
      options: UIViewAnimationOptions.CurveEaseIn,
      
      animations: {
        self.focusView!.alpha = 1.0
        self.focusView!.transform = CGAffineTransformMakeScale(0.7, 0.7)
      },
      
      completion: { _ in
        self.focusView!.transform = CGAffineTransformMakeScale(1.0, 1.0)
        self.focusView!.alpha = 0
      }
    )
  }
  
}

// MARK: - Internal helpers 

extension Capturable {
  ///
  /// Returns `true` if a user has given access to the camera.
  ///
  func cameraIsAvailable() -> Bool {
    let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
    
    if status == AVAuthorizationStatus.Authorized {
      return true
    }
    
    return false
  }
  
  ///
  /// Stops and resumes current session depending on the foreground mode.
  ///
  /// - parameter notification: A foregound entry notification. 
  ///
  func willEnterForegroundNotification(notification: NSNotification) {
    let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
    
    if status == AVAuthorizationStatus.Authorized {
      session?.startRunning()
    } else if status == AVAuthorizationStatus.Denied || status == AVAuthorizationStatus.Restricted {
      session?.stopRunning()
    }
  }
}

