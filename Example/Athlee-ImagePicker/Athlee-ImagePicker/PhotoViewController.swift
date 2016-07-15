//
//  PhotoViewController.swift
//  Athlee-ImagePicker
//
//  Created by mac on 15/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit
import Photos

final class PhotoViewController: UIViewController, ContainerType {
  
  // MARK: Outlets
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  // MARK: Properties
  
  var parent: HolderViewController! 
  
  let space: CGFloat = 2
  
  lazy var fetchResult: PHFetchResult = {
    let options = PHFetchOptions()
    let fetchResult = PHAsset.fetchAssetsWithMediaType(.Image, options: options)
    
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
      collectionView.selectItemAtIndexPath(
        NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.None)
    }
    
    PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(observer)
    
    collectionView.backgroundColor = .clearColor()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    let firstReversed = fetchResult[fetchResult.count - 1] as! PHAsset
    cachingImageManager.requestImageForAsset(
      firstReversed,
      targetSize: UIScreen.mainScreen().bounds.size,
      contentMode: .AspectFill,
      options: nil) { result, info in
        if info!["PHImageFileURLKey"] != nil  {
          self.parent.image = result
        }
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    updateCachedAssets(for: collectionView.bounds, targetSize: cellSize)
  }
  
  
  deinit {
    if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.Authorized {
      PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(observer)
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
      case .Authorized:
        self.cachingImageManager = PHCachingImageManager()
        if self.fetchResult.count > 0 {
          // TODO: Set main initial image
        }
        
      case .Restricted, .Denied:
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          
          // TODO: Show error
          
        })
      default:
        break
      }
    }
  }
  
  internal func cachingAssets(at rect: CGRect) -> [PHAsset] {
    let indexPaths = collectionView.indexPaths(for: rect)
    return assets(at: indexPaths, in: fetchResult)
  }
}

extension PhotoViewController {
  func scrollViewDidScroll(scrollView: UIScrollView) {
    if scrollView == collectionView {
      updateCachedAssets(for: collectionView.bounds, targetSize: cellSize)
      
      if scrollView.contentOffset.y < 0 {
        parent.cropViewController?.allowPanOutside = true
      } else {
        parent.cropViewController?.allowPanOutside = false 
      }
    }
  }
}

extension PhotoViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return fetchResult.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
    
    let reversedIndex = fetchResult.count - indexPath.item - 1
    let asset = fetchResult[reversedIndex] as! PHAsset
    cachingImageManager.requestImageForAsset(
      asset,
      targetSize: cellSize,
      contentMode: .AspectFill,
      options: nil) { [cell] result, info in
        
        cell.photoImageView.image = result
        
    }
    
    cell.backgroundColor = .redColor()
    
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let reversedIndex = fetchResult.count - indexPath.item - 1
    
    let asset = fetchResult[reversedIndex] as! PHAsset
    cachingImageManager.requestImageForAsset(
      asset,
      targetSize: UIScreen.mainScreen().bounds.size,
      contentMode: .AspectFill,
      options: nil) { result, info in
        if info!["PHImageFileURLKey"] != nil  {
          if let cropViewController = self.parent.cropViewController {
            let floatingView = cropViewController.floatingView
            cropViewController.restore(view: floatingView, to: .Unfolded, animated: true)
            cropViewController.animationCompletion = { _ in
              self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
              cropViewController.animationCompletion = nil
            }
          }
          
          self.parent.image = result
        }
    }
    
  }
}

extension PhotoViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
    return space
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
    return space
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    return UIEdgeInsetsZero
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return cellSize
  }
}