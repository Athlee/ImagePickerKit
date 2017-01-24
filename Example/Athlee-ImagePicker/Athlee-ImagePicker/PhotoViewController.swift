//
//  PhotoViewController.swift
//  Athlee-ImagePicker
//
//  Created by mac on 15/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit
import Photos

final class PhotoViewController: UIViewController {
  
  // MARK: Outlets
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  // MARK: Properties
  
  var _parent: HolderViewController!
  
  let space: CGFloat = 2
  
  lazy var fetchResult: PHFetchResult = { () -> PHFetchResult<PHAsset> in 
    let options = PHFetchOptions()
    options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    let fetchResult = PHAsset.fetchAssets(with: .image, options: options)
    
    return fetchResult
  }()
  
  lazy var cachingImageManager = PHCachingImageManager()
  
  var previousPreheatRect: CGRect = .zero
  
  var cellSize: CGSize {
    let side = (collectionView.frame.width - space * 3) / 4
    return CGSize(
      width: side,
      height: side
    )
  }
  
  lazy var observer: CollectionViewChangeObserver = {
    return CollectionViewChangeObserver(collectionView: self.collectionView, source: self)
  }()
  
  // MARK: Life cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    resetCachedAssets()
    checkPhotoAuth()
    
    if fetchResult.count > 0 {
      collectionView.reloadData()
      collectionView.selectItem(
        at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition())
    }
    
    PHPhotoLibrary.shared().register(observer)
    
    collectionView.backgroundColor = .clear
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    guard let firstAsset = fetchResult.firstObject else {
      debugPrint("[ATHImagePickerController] Could not get the first asset!")
      return
    }
    
    cachingImageManager.requestImage(
      for: firstAsset,
      targetSize: UIScreen.main.bounds.size,
      contentMode: .aspectFill,
      options: nil) { result, info in
        if info!["PHImageFileURLKey"] != nil  {
          self._parent.image = result
        }
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    updateCachedAssets(for: collectionView.bounds, targetSize: cellSize)
  }
  
  
  deinit {
    if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
      PHPhotoLibrary.shared().unregisterChangeObserver(observer)
    }
  }
  
}

// MARK: - PhotoFetchable

extension PhotoViewController: PhotoFetchable { }

// MARK: - PhotoCachable

extension PhotoViewController: PhotoCachable {
  internal func checkPhotoAuth() {
    
    PHPhotoLibrary.requestAuthorization { (status) -> Void in
      switch status {
      case .authorized:
        self.cachingImageManager = PHCachingImageManager()
        if self.fetchResult.count > 0 {
          // TODO: Set main initial image
        }
        
      case .restricted, .denied:
        DispatchQueue.main.async(execute: { () -> Void in
          
          // TODO: Show error
          
        })
      default:
        break
      }
    }
  }
  
  internal func cachingAssets(at rect: CGRect) -> [PHAsset] {
    let indexPaths = collectionView.indexPaths(for: rect)
    return assets(at: indexPaths, in: fetchResult as! PHFetchResult<AnyObject>)
  }
}

extension PhotoViewController {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView == collectionView {
      updateCachedAssets(for: collectionView.bounds, targetSize: cellSize)
      
      if scrollView.contentOffset.y < 0 {
        _parent.cropViewController?.allowPanOutside = true
      } else {
        _parent.cropViewController?.allowPanOutside = false
      }
    }
  }
}

extension PhotoViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return fetchResult.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
    
    guard indexPath.item < fetchResult.count else {
      return cell
    }
    
    let asset = fetchResult[indexPath.item]
    cachingImageManager.requestImage(
      for: asset,
      targetSize: cellSize,
      contentMode: .aspectFill,
      options: nil) { [cell] result, info in
        
        cell.photoImageView.image = result
        
    }
    
    cell.backgroundColor = .red
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard indexPath.item < fetchResult.count else {
      return
    }
    
    let asset = fetchResult[indexPath.item]
    cachingImageManager.requestImage(
      for: asset,
      targetSize: UIScreen.main.bounds.size,
      contentMode: .aspectFill,
      options: nil) { result, info in
        if info!["PHImageFileURLKey"] != nil  {
          if let cropViewController = self._parent.cropViewController {
            let floatingView = cropViewController.floatingView
            cropViewController.restore(view: floatingView, to: .unfolded, animated: true)
            cropViewController.animationCompletion = { _ in
              self.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
              cropViewController.animationCompletion = nil
            }
          }
          
          self._parent.image = result
        }
    }
    
  }
}

extension PhotoViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return space
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return space
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets.zero
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return cellSize
  }
}
