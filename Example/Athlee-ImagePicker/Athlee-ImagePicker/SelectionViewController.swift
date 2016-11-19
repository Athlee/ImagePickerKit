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
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let dest = segue.destination
    if let dest = dest as? UINavigationController, let holder = dest.topViewController as? HolderViewController {
      holder._parent = self
    } else if let dest = dest as? CaptureViewController {
      dest._parent = self
    }
  }

}
