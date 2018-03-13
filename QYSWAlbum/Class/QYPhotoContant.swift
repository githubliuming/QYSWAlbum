//
//  QYPhotoContant.swift
//  QYSWAlbum
//
//  Created by liuming on 2018/3/12.
//  Copyright © 2018年 yoyo. All rights reserved.
//

import Foundation
import UIKit
public enum QYPhotoLibarayAssertType : Int
{
    case All   //相册所有元素
    case Photos  //所有图片
    case Video  //所有视频
    case Panoramas // 全景图片
    case LivePhoto  // livePhoto
    case LivePhotoAndVideos  // livePhoto和视频
}

public typealias QYPhotoProgress = (Double,Error?)->Void
public typealias QYPhotoError = (Error?)->Void
public typealias QYPhotoSuccess = (UIImage?) ->Void
