//
//  HolderViewController.swift
//  Athlee-ImagePicker
//
//  Created by mac on 15/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit

final class HolderViewController: UIViewController, ContainerType {
  
  // MARK: Outlets 
  
  @IBOutlet weak var topConstraint: NSLayoutConstraint!
  @IBOutlet weak var topContainer: UIView!
  
  // MARK: Properties 
  
  var parent: SelectionViewController!
  
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
        child.parent = self
      } else if let child = child as? PhotoViewController {
        photoViewController = child
        child.parent = self 
      }
    }
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  // MARK: IBActions
  
  @IBAction func didPressNextButton(sender: AnyObject) {
    navigationController?.dismissViewControllerAnimated(true, completion: nil)
    let image = topContainer.snapshot()
    parent.imageView.image = image
    parent = nil
  }

}
