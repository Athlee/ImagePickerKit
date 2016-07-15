//
//  ContainerType.swift
//  Athlee-ImagePicker
//
//  Created by mac on 15/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit

protocol ContainerType {
  associatedtype ParentType
  var parent: ParentType { get set }
}
