//
//  CaptureViewController.swift
//  Athlee-ImagePicker
//
//  Created by mac on 16/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit
import AVFoundation

final class CaptureViewController: UIViewController, PhotoCapturable {

  // MARK: Outlets
  
  @IBOutlet weak var cameraView: UIView!
  @IBOutlet weak var flashButton: UIButton!
  
  // MARK: Capturable properties
  
  var session: AVCaptureSession?
  
  var device: AVCaptureDevice? {
    didSet {
      guard let device = device else { return }
      if !device.hasFlash {
        flashButton.hidden = true
      }
    }
  }
  
  var videoInput: AVCaptureDeviceInput?
  var imageOutput: AVCaptureStillImageOutput?
  
  var focusView: UIView?
  
  lazy var previewViewContainer: UIView = {
    return self.cameraView
  }()
  
  var captureNotificationObserver: CaptureNotificationObserver<CaptureViewController>?
  
  // MARK: Properties
  
  weak var selectionViewController: SelectionViewController!
  
  var flashMode: AVCaptureFlashMode = .On {
    didSet {
      switch flashMode {
      case .On:
        flashButton.setImage(UIImage(named: "Flash"), forState: .Normal)
      case .Off:
        flashButton.setImage(UIImage(named: "FlashOff"), forState: .Normal)
      case .Auto:
        flashButton.setImage(UIImage(named: "FlashAuto"), forState: .Normal)
      }
      
      setFlashMode(flashMode)
    }
  }
  
  // MARK: Life cycle
  
  var queue = NSOperationQueue()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    queue.addOperationWithBlock {
      self.prepareForCapturing()
      self.setFlashMode(self.flashMode)
    }
    
    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(CaptureViewController.recognizedTapGesture(_:)))
    previewViewContainer.addGestureRecognizer(tapRecognizer)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    reloadPreview(previewViewContainer)
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  // MARK: IBActions 
  
  @IBAction func recognizedTapGesture(rec: UITapGestureRecognizer) {
    let point = rec.locationInView(previewViewContainer)
    focus(at: point)
  }
  
  @IBAction func didPressCapturePhoto(sender: AnyObject) {
    captureStillImage { image in
      self.selectionViewController.imageView.image = image
      self.dismissViewControllerAnimated(true, completion: nil)
    }
  }
  
  @IBAction func didPressFlipButton(sender: AnyObject) {
    flipCamera()
  }
  
  @IBAction func didPressFlashButton(sender: AnyObject) {
    switch flashMode {
    case .Auto:
      flashMode = .On
    case .On:
      flashMode = .Off
    case .Off:
      flashMode = .Auto
    }
  }
  
}

extension CaptureViewController {
  func didSetFlashMode(flashMode: AVCaptureFlashMode) {
    self.flashMode = flashMode
  }
}
