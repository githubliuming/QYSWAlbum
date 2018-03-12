//
//  QYAsset.swift
//  QYSWAlbum
//
//  Created by liuming on 2018/3/12.
//  Copyright © 2018年 yoyo. All rights reserved.
//

import UIKit
import Photos
open  class QYAsset:NSObject
{
   open var phAsset:PHAsset;
    public init(asset:PHAsset)
    {
        phAsset = asset;
    }
}
