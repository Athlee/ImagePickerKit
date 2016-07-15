//
//  PhotoCell.swift
//  Athlee-ImagePicker
//
//  Created by mac on 15/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit

final class PhotoCell: UICollectionViewCell {
  
  @IBOutlet weak var photoImageView: UIImageView!
  
  let overlayView = UIView()
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    overlayView.translatesAutoresizingMaskIntoConstraints = false
    overlayView.backgroundColor = UIColor.blackColor()
    overlayView.alpha = 0
    
    addSubview(overlayView)
    
    let anchors = [
      overlayView.topAnchor.constraintEqualToAnchor(topAnchor),
      overlayView.bottomAnchor.constraintEqualToAnchor(bottomAnchor),
      overlayView.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
      overlayView.trailingAnchor.constraintEqualToAnchor(trailingAnchor)
      ].flatMap { $0 }
    
    NSLayoutConstraint.activateConstraints(anchors)
  }
  
  override var selected: Bool {
    didSet {
      if selected {
        overlayView.alpha = 0.6
      } else {
        overlayView.alpha = 0
      }
    }
  }
  
}