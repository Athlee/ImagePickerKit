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
    overlayView.backgroundColor = UIColor.black
    overlayView.alpha = 0
    
    addSubview(overlayView)
    
    let anchors = [
      overlayView.topAnchor.constraint(equalTo: topAnchor),
      overlayView.bottomAnchor.constraint(equalTo: bottomAnchor),
      overlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
      overlayView.trailingAnchor.constraint(equalTo: trailingAnchor)
      ].flatMap { $0 }
    
    NSLayoutConstraint.activate(anchors)
  }
  
  override var isSelected: Bool {
    didSet {
      if isSelected {
        overlayView.alpha = 0.6
      } else {
        overlayView.alpha = 0
      }
    }
  }
  
}
