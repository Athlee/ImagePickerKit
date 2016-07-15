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
  
  var selectionViewController: SelectionViewController!
  
  var cropViewController: CropViewController? {
    for child in childViewControllers {
      if let child = child as? CropViewController {
        return child
      }
    }
    
    return nil
  }
  
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
        child.parent = self
      } else if let child = child as? PhotoViewController {
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
    selectionViewController.imageView.image = image
    selectionViewController = nil
  }

}
