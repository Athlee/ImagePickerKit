//
//  HolderViewController.swift
//  Athlee-ImagePicker
//
//  Created by mac on 15/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit

final class HolderViewController: UIViewController {
  
  // MARK: Outlets 
  
  @IBOutlet weak var topConstraint: NSLayoutConstraint!
  @IBOutlet weak var topContainer: UIView!
  
  // MARK: Properties 
  
  var _parent: SelectionViewController!
  
  var cropViewController: CropViewController!
  var photoViewController: PhotoViewController!
  
  var image: UIImage? {
    didSet {
      guard let image = image else { return }
      for child in childViewControllers {
        if let child = child as? CropViewController {
          child.addImage(image)
        }
      }
    }
  }
  
  // MARK: Life cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    for child in childViewControllers {
      if let child = child as? CropViewController {
        cropViewController = child
        child._parent = self
      } else if let child = child as? PhotoViewController {
        photoViewController = child
        child._parent = self
      }
    }
  }
  
  override var prefersStatusBarHidden : Bool {
    return true
  }
  
  // MARK: IBActions
  
  @IBAction func didPressNextButton(_ sender: AnyObject) {
    navigationController?.dismiss(animated: true, completion: nil)
    let image = topContainer.snapshot()
    _parent.imageView.image = image
    _parent = nil
  }

}
