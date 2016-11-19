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
public protocol PhotoCapturable: Capturable {
  ///
  /// Captures a still image from the current input. 
  ///
  /// - parameter handler: A handler that is called when the image is taken. Default value is `nil`.
  ///
  func captureStillImage(_ handler: ((UIImage) -> Void)?)
}

// MARK: - Default implementations 

public extension PhotoCapturable {
  
  ///
  /// Captures a still image from the current input.
  ///
  /// - parameter handler: A handler that is called when the image is taken. Default value is `nil`.
  ///
  func captureStillImage(_ handler: ((UIImage) -> Void)? = nil) {
    guard let imageOutput = imageOutput else {
      return
    }
    
    
    
    DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
      let videoConnection = imageOutput.connection(withMediaType: AVMediaTypeVideo)
      
      imageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (buffer, error) in
        self.session?.stopRunning()
        
        let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
        
        if let image = UIImage(data: data!) {
          
          // Image size
          let iw = image.size.width
          let ih = image.size.height
          
          // Frame size
          let sw = self.previewViewContainer.frame.width
          
          // The center coordinate along Y axis
          let rcy = ih * 0.5
          
          let imageRef = image.cgImage?.cropping(to: CGRect(x: rcy - iw * 0.5, y: 0 , width: iw, height: iw)
          )
          
          DispatchQueue.main.async {
            let resizedImage = UIImage(cgImage: imageRef!, scale: sw/iw, orientation: image.imageOrientation)
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
