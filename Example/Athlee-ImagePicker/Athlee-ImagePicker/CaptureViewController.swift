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
        flashButton.isHidden = true
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
  
  var _parent: SelectionViewController!
  
  var flashMode: AVCaptureFlashMode = .on {
    didSet {
      switch flashMode {
      case .on:
        flashButton.setImage(UIImage(named: "Flash"), for: UIControlState())
      case .off:
        flashButton.setImage(UIImage(named: "FlashOff"), for: UIControlState())
      case .auto:
        flashButton.setImage(UIImage(named: "FlashAuto"), for: UIControlState())
      }
      
      setFlashMode(flashMode)
    }
  }
  
  // MARK: Life cycle
  
  var queue = OperationQueue()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    queue.addOperation {
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
  
  override var prefersStatusBarHidden : Bool {
    return true
  }
  
  // MARK: IBActions 
  
  @IBAction func recognizedTapGesture(_ rec: UITapGestureRecognizer) {
    let point = rec.location(in: previewViewContainer)
    focus(at: point)
  }
  
  @IBAction func didPressCapturePhoto(_ sender: AnyObject) {
    captureStillImage { image in
      self._parent.imageView.image = image
      self.dismiss(animated: true, completion: nil)
      self._parent = nil
    }
  }
  
  @IBAction func didPressFlipButton(_ sender: AnyObject) {
    flipCamera()
  }
  
  @IBAction func didPressFlashButton(_ sender: AnyObject) {
    switch flashMode {
    case .auto:
      flashMode = .on
    case .on:
      flashMode = .off
    case .off:
      flashMode = .auto
    }
  }
  
}

extension CaptureViewController {
  func didSetFlashMode(_ flashMode: AVCaptureFlashMode) {
    self.flashMode = flashMode
  }
}
