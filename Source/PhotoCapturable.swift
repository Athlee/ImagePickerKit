//
//  PhotoCapturable.swift
//  Athlee-ImagePicker
//
//  Created by mac on 16/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

///
/// Provides still image capturing features.
///
public protocol PhotoCapturable: Capturable {
  
  /// Captures a still image from the current input.
  ///
  /// - Parameters:
  ///   - saving:  Indicates if taken image should be saved to albums.
  ///   - handler: A handler that is called when the image is taken. Default value is `nil`.
  func captureStillImage(saving: Bool, handler: ((UIImage) -> Void)?)
  
  /// This function is optional. It is called when
  /// captured still image could not
  /// be saved to albums.
  ///
  /// - Parameter error: Photo Library change error.
  func captureStillImageFailed(with error: Error?)
}

// MARK: - Default implementations 

public extension PhotoCapturable {
  
  /// Captures a still image from the current input.
  ///
  /// - Parameters:
  ///   - saving:  Indicates if taken image should be saved to albums.
  ///   - handler: A handler that is called when the image is taken. Default value is `nil`.
  func captureStillImage(saving: Bool = true, handler: ((UIImage) -> Void)?) {
    guard let imageOutput = imageOutput else {
      return
    }
    
    // TODO: Refactor this code 
    
    DispatchQueue.global(qos: DispatchQoS.userInitiated.qosClass).async(execute: {
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
            let resizedImage = UIImage(cgImage: imageRef!, scale: sw / iw, orientation: image.imageOrientation)
            handler?(resizedImage)
            
            if saving {
              PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: resizedImage)
              }, completionHandler: { [weak self] (success, error) in
                if !success {
                  self?.captureStillImageFailed(with: error)
                }
              })
            }
            
            self.session     = nil
            self.device      = nil
            self.imageOutput = nil
          }
        }
        
      })
      
    })
  }
  
  /// This function is optional. It is called when
  /// captured still image could not
  /// be saved to albums.
  ///
  /// - Parameter error: Photo Library change error.
  func captureStillImageFailed(with error: Error?) { }
}
