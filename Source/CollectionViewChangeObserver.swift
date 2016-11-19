//
//  CollectionViewChangeObserver.swift
//  Cropable
//
//  Created by mac on 15/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit
import Photos

///
/// A default implementation for `PHPhotoLibraryChangeObserver` 
/// protocol observer object.
///
open class CollectionViewChangeObserver: NSObject {
  open let collectionView: UICollectionView
  
  internal unowned var source: PhotoFetchable & PhotoCachable
  
  public init(collectionView: UICollectionView, source: PhotoFetchable & PhotoCachable) {
    self.collectionView = collectionView
    self.source = source
  }
}

// MARK: - PHPhotoLibraryChangeObserver

extension CollectionViewChangeObserver: PHPhotoLibraryChangeObserver {
  open func photoLibraryDidChange(_ changeInstance: PHChange) {
    DispatchQueue.main.async {
      guard let collectionChanges = changeInstance.changeDetails(for: self.source.fetchResult as! PHFetchResult<PHObject>) else {
        return
      }
      
      self.source.fetchResult = collectionChanges.fetchResultAfterChanges as! PHFetchResult<PHAsset> 
      
      if !collectionChanges.hasIncrementalChanges || collectionChanges.hasMoves {
        self.collectionView.reloadData()
      } else {
        self.collectionView.performBatchUpdates({
          let removedIndexes = collectionChanges.removedIndexes
          if (removedIndexes?.count ?? 0) != 0 {
            self.collectionView.deleteItems(at: removedIndexes!.indexPaths(from: 0))
          }
          
          let insertedIndexes = collectionChanges.insertedIndexes
          if (insertedIndexes?.count ?? 0) != 0 {
            self.collectionView.insertItems(at: insertedIndexes!.indexPaths(from: 0))
          }
          
          let changedIndexes = collectionChanges.changedIndexes
          if (changedIndexes?.count ?? 0) != 0 {
            self.collectionView.reloadItems(at: changedIndexes!.indexPaths(from: 0))
          }
          
          }, completion: nil)
      }
      
      self.source.resetCachedAssets()
    }
  }
}
