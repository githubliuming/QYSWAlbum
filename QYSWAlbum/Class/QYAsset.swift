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
   public var phAsset:PHAsset?;
   public var medaiType:QYPhotoAssetType = .Unknown;
    public init(asset:PHAsset)
    {
        super.init();
        self.phAsset = asset;
       self.medaiType = transformAssetType(asset: asset);
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")

    }
    
    private func transformAssetType(asset ast:PHAsset)-> QYPhotoAssetType{
    
        switch ast.mediaType {
        case .audio:
            return QYPhotoAssetType.Aduio;
        case .video:
            if ast.mediaSubtypes == .videoHighFrameRate {
             
                return QYPhotoAssetType.HighFrameRate;
            }
            return QYPhotoAssetType.Video;
        case .image:
            if ast.mediaSubtypes == .photoLive || Int(ast.mediaSubtypes.rawValue) == 10 {
                return QYPhotoAssetType.livePhoto;
            }
            if (ast.value(forKey: "filename") as! String).hasSuffix("GIF"){
                return QYPhotoAssetType.Gif;
            }
            return QYPhotoAssetType.Image
        default:
           return QYPhotoAssetType.Unknown;
        }
    }
}
