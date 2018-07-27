//
//  QYPhotoContant.swift
//  QYSWAlbum
//
//  Created by liuming on 2018/3/12.
//  Copyright © 2018年 yoyo. All rights reserved.
//

import Foundation
import UIKit
public enum QYPhotoLibarayAssertType: Int {
    case All // 相册所有元素
    case Photos // 所有图片
    case Video // 所有视频
    case Panoramas // 全景图片
    case LivePhoto // livePhoto
    case LivePhotoAndVideos // livePhoto和视频
}

public enum QYPhotoAssetType: Int {
    case Unknown // 位置类型
    case Image // 图片
    case Gif // gif
    case Video // 视频
    case livePhoto // livePhoto
    case HighFrameRate // 慢动作视频
    case Aduio // 音频
}

public typealias QYPhotoProgress = (Double, Error?) -> Void
public typealias QYPhotoError = (Error?) -> Void
public typealias QYPhotoSuccess = (UIImage?) -> Void
public typealias QYVideoSucces = (_ url: URL?) -> Void
public typealias QYDeleteAssetCompletionBlock = (Bool, Error?) -> Void
