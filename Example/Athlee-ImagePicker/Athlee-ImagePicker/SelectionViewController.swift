//
//  SelectionViewController.swift
//  Athlee-ImagePicker
//
//  Created by mac on 15/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit

final class SelectionViewController: UIViewController {
  
  // MARK: Outlets
  
  @IBOutlet weak var imageView: UIImageView!
  
  // MARK: Life cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let dest = segue.destinationViewController
    if let dest = dest as? UINavigationController, holder = dest.topViewController as? HolderViewController {
      holder.selectionViewController = self
    } else if let dest = dest as? CaptureViewController {
      dest.selectionViewController = self
    }
  }

}
