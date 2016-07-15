//
//  PhotoCapturable.swift
//  Athlee-ImagePicker
//
//  Created by mac on 16/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit
import AVFoundation

///
/// Provides still image capturing features.
///
protocol PhotoCapturable: Capturable {
  ///
  /// Captures a still image from the current input. 
  ///
  /// - parameter handler: A handler that is called when the image is taken. Default value is `nil`.
  ///
  func captureStillImage(handler: ((UIImage) -> Void)?)
}

// MARK: - Default implementations 

extension PhotoCapturable {
  
  ///
  /// Captures a still image from the current input.
  ///
  /// - parameter handler: A handler that is called when the image is taken. Default value is `nil`.
  ///
  func captureStillImage(handler: ((UIImage) -> Void)? = nil) {
    guard let imageOutput = imageOutput else {
      return
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      let videoConnection = imageOutput.connectionWithMediaType(AVMediaTypeVideo)
      
      imageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (buffer, error) in
        self.session?.stopRunning()
        
        let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
        
        if let image = UIImage(data: data) {
          
          // Image size
          let iw = image.size.width
          let ih = image.size.height
          
          // Frame size
          let sw = self.previewViewContainer.frame.width
          
          // The center coordinate along Y axis
          let rcy = ih * 0.5
          
          let imageRef = CGImageCreateWithImageInRect(
            image.CGImage,
            CGRect(x: rcy - iw * 0.5, y: 0 , width: iw, height: iw)
          )
          
          dispatch_async(dispatch_get_main_queue()) {
            let resizedImage = UIImage(CGImage: imageRef!, scale: sw/iw, orientation: image.imageOrientation)
            handler?(resizedImage)
            
            self.session     = nil
            self.device      = nil
            self.imageOutput = nil
          }
        }
        
      })
      
    })
  }
  
}