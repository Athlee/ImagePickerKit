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
final class CollectionViewChangeObserver: NSObject {
  let collectionView: UICollectionView
  
  unowned var source: protocol<PhotoFetchable, PhotoCachable>
  
  init(collectionView: UICollectionView, source: protocol<PhotoFetchable, PhotoCachable>) {
    self.collectionView = collectionView
    self.source = source
  }
}

// MARK: - PHPhotoLibraryChangeObserver

extension CollectionViewChangeObserver: PHPhotoLibraryChangeObserver {
  func photoLibraryDidChange(changeInstance: PHChange) {
    dispatch_async(dispatch_get_main_queue()) {
      guard let collectionChanges = changeInstance.changeDetailsForFetchResult(self.source.fetchResult) else {
        return
      }
      
      self.source.fetchResult = collectionChanges.fetchResultAfterChanges
      
      if !collectionChanges.hasIncrementalChanges || collectionChanges.hasMoves {
        self.collectionView.reloadData()
      } else {
        self.collectionView.performBatchUpdates({
          let removedIndexes = collectionChanges.removedIndexes
          if (removedIndexes?.count ?? 0) != 0 {
            self.collectionView.deleteItemsAtIndexPaths(removedIndexes!.indexPaths(from: 0))
          }
          
          let insertedIndexes = collectionChanges.insertedIndexes
          if (insertedIndexes?.count ?? 0) != 0 {
            self.collectionView.insertItemsAtIndexPaths(insertedIndexes!.indexPaths(from: 0))
          }
          
          let changedIndexes = collectionChanges.changedIndexes
          if (changedIndexes?.count ?? 0) != 0 {
            self.collectionView.reloadItemsAtIndexPaths(changedIndexes!.indexPaths(from: 0))
          }
          
          }, completion: nil)
      }
      
      self.source.resetCachedAssets()
    }
  }
}
