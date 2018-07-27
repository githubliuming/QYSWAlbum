//
//  QYGroup.swift
//  QYSWAlbum
//
//  Created by liuming on 2018/3/12.
//  Copyright © 2018年 yoyo. All rights reserved.
//

import Photos
import UIKit
open class QYGroup: NSObject {
    open var assets: [QYAsset]
    open var phCollection: PHAssetCollection
    open var count: Int
    init(collection: PHAssetCollection, assetModels: [QYAsset]) {
        assets = assetModels
        phCollection = collection
        count = assets.count
    }
}
