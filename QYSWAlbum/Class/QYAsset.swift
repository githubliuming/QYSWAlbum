//
//  QYAsset.swift
//  QYSWAlbum
//
//  Created by liuming on 2018/3/12.
//  Copyright © 2018年 yoyo. All rights reserved.
//

import Photos
import UIKit
open class QYAsset: NSObject {
    public var phAsset: PHAsset?
    public var medaiType: QYPhotoAssetType = .Unknown
    public init(asset: PHAsset?) {
        super.init()
        phAsset = asset
        medaiType = transformAssetType(asset: asset)
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func transformAssetType(asset ast: PHAsset?) -> QYPhotoAssetType {
        guard let asset: PHAsset = ast else {
            return QYPhotoAssetType.Unknown
        }
        switch asset.mediaType {
        case .audio:
            return QYPhotoAssetType.Aduio
        case .video:
            if asset.mediaSubtypes == .videoHighFrameRate {
                return QYPhotoAssetType.HighFrameRate
            }
            return QYPhotoAssetType.Video
        case .image:
            if asset.mediaSubtypes == .photoLive || Int(asset.mediaSubtypes.rawValue) == 10 {
                return QYPhotoAssetType.livePhoto
            }
            if (asset.value(forKey: "filename") as! String).hasSuffix("GIF") {
                return QYPhotoAssetType.Gif
            }
            return QYPhotoAssetType.Image
        default:
            return QYPhotoAssetType.Unknown
        }
    }
}
