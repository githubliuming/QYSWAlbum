//
//  QYPhotoSever.swift
//  QYSWAlbum
//
//  Created by liuming on 2018/3/12.
//  Copyright © 2018年 yoyo. All rights reserved.
//

import UIKit
import Photos
class QYPhotoSever: NSObject {

    let photoQueue:OperationQueue = OperationQueue();
    static let shareInstanced:QYPhotoSever = QYPhotoSever.init();
    override init()
    {
        super.init();
        photoQueue.maxConcurrentOperationCount = 5;
    }
    
    // MARK:- 相册权限
    /// 判断当前用户相册权限的状态
    ///
    /// - Returns: 当前用户的权限状态
    open class func albumPermissonStatues() -> PHAuthorizationStatus
    {
        return PHPhotoLibrary.authorizationStatus();
    }
    
    /// 请求相册权限
    ///
    /// - Parameter gratend: 结果回调 YES - 有相册权限 NO --没有相册权限
    open class func requestAlbumAuthor(gratend:@escaping (_:Bool)->Void) -> Void{
        
        PHPhotoLibrary.requestAuthorization { (status) in
            
            gratend(status == PHAuthorizationStatus.authorized);
        }
    }
    /// 判断用户是否有相册权限
    ///
    /// - Returns: true -有现相册权限 false - 没有相册权限
    open class func hasAlbumPermiss() ->Bool
    {
        return self.albumPermissonStatues() == .authorized;
    }
    //MARK:- 遍历相册
    open func fetchAlbum(type:QYPhotoLibarayAssertType,result:@escaping(_:Array<QYGroup>)->Void)->Void{
        photoQueue.addOperation {
          
            let albums:Array = self.getAlubms();
            var groups:[QYGroup] = Array<QYGroup>();
            for alubm:PHFetchResult  in albums
            {
                alubm .enumerateObjects({ (obj, index, stop) in
                    if obj.assetCollectionSubtype.rawValue > 213
                    {
                        print("抛弃最近删除数据");
                        return;
                    }
                    let option:PHFetchOptions = self.getFetchOption(type:type);
                    let assetModels:[QYAsset] = self.fetchCollection(collection: obj, option: option);
                    if  assetModels.count <= 0
                    {
                        print("没有数据抛弃掉 \(obj.localizedTitle!)")
                        return ;
                    }
                    guard let _ :String = obj.localizedTitle else{
                        print("标题为空 抛弃掉数据");
                        return ;
                    }
                    let group:QYGroup = QYGroup(collection: obj, assetModels: assetModels);
                    if  obj.assetCollectionType == .smartAlbum &&
                        obj.assetCollectionSubtype  == .smartAlbumUserLibrary
                    {
                        if groups.count > 0
                        {
                            groups.insert(group, at: 0);
                        }
                        else
                        {
                            groups.append(group);
                        }
                    } else
                    {
                        groups.append(group);
                    }
                })
            }
            result(groups);
        };
    }
    open func fetchCollection(collection:PHAssetCollection?,option:PHFetchOptions) -> Array<QYAsset>
    {
        guard let _:PHAssetCollection = collection else{
            print("collection 对象为空");
            return [];
        }
        var assetModels:[QYAsset] = Array<QYAsset>();
        let assets:PHFetchResult = PHAsset.fetchAssets(in: collection!, options: option);
        assets .enumerateObjects { (asset, idx, stop) in
            let assetModel:QYAsset  = QYAsset(asset: asset);
            assetModels.append(assetModel);
        };
        return assetModels;
    }
    private func getFetchOption(type:QYPhotoLibarayAssertType) ->PHFetchOptions
    {
        
        let options:PHFetchOptions = PHFetchOptions();
        switch type {
        case .All:
            options.predicate = NSPredicate(
                format: "mediaType = %d or mediaType = %d",
                argumentArray: [PHAssetMediaType.image,PHAssetMediaType.video]
            );
        case.Photos:
        options.predicate = NSPredicate(format: "mediaType = %d", argumentArray: [PHAssetMediaType.image]);
        case .LivePhotoAndVideos:
            if #available(iOS 9.1, *)
            {
                 options.predicate = NSPredicate(format:"(mediaType = %d and mediaSubtype == %d) or mediaType = %d ", argumentArray: [PHAssetMediaType.image,PHAssetMediaSubtype.photoLive,PHAssetMediaType.video]);
            }
            else
            {
                // Fallback on earlier versions
                options.predicate = NSPredicate(format:" mediaType = %d", argumentArray: [PHAssetMediaType.video]);
            }
        case.Panoramas:
            options.predicate = NSPredicate(
                format: "mediaType = %d and mediaSubtype == %d",
                argumentArray: [PHAssetMediaType.image,PHAssetMediaSubtype.photoPanorama]
            );
        case .Video:
            options.predicate = NSPredicate(
                format: "mediaType = %d",
                argumentArray: [PHAssetMediaType.video]);
        case .LivePhoto:
            if #available(iOS 9.1, *)
            {
                options.predicate  = NSPredicate(format: "mediaType = %d and mediaSubtype == %d", argumentArray: [PHAssetMediaType.image,PHAssetMediaSubtype.photoLive]);
            }
            else
            {
                options.predicate = NSPredicate(format: "mediaType = %d", argumentArray: [PHAssetMediaType.image]);
            }
        }
        
        return options;
    }
    private func getAlubms()->Array<PHFetchResult<PHAssetCollection>>
    { 
//         智能相册
        let smartAlbums:PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil);
//        我的照片流 1.6.10重新加入..
        let  myPhotoStreamAlbum:PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype:.albumMyPhotoStream, options: nil);
        
        let importAlbum:PHFetchResult = PHAssetCollection.fetchAssetCollections(with:.album, subtype: .albumSyncedAlbum, options: nil);
//        let topLevelUserCollections:PHFetchResult = PHCollectionList.fetchTopLevelUserCollections(with: nil);
        return [smartAlbums ,myPhotoStreamAlbum,importAlbum];
    }
}
