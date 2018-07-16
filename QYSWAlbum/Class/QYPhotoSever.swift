//
//  QYPhotoSever.swift
//  QYSWAlbum
//
//  Created by liuming on 2018/3/12.
//  Copyright © 2018年 yoyo. All rights reserved.
//
/*
1、遍历相册中所有的元素。
2、遍历指定相册中的元素。
3、获取相册图片的原图,支持icloud下载
4、获取相册中的原始视频，支持将livephoto转换成视频
6、获取相册缩略图
 */
import UIKit
import Foundation
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
                     if obj.localizedTitle?.isEmpty == true {
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
            self.runOnMainThread {
                result(groups);
            }
        };
    }

    /// 遍历指定的相册
    ///
    /// - Parameters:
    ///   - collection: 相册对象
    ///   - option: 可选参数
    /// - Returns: 返回遍历集合
    open func fetchCollection(collection:PHAssetCollection?,option:PHFetchOptions?) -> Array<QYAsset>
    {
        guard let _:PHAssetCollection = collection else{
            print("collection 对象为空");
            return [];
        }
        var assetModels:[QYAsset] = Array<QYAsset>();
        let assets:PHFetchResult = PHAsset.fetchAssets(in: collection!, options: nil);
        if assets.count > 0
        {
            assets .enumerateObjects { (asset, idx, stop) in
                let assetModel:QYAsset  = QYAsset(asset: asset);
                assetModels.append(assetModel);
            };
        }
        return assetModels;
    }
    open func fetchCamerollCollection(type:QYPhotoLibarayAssertType,
                                      block:@escaping(_:Array<QYGroup>) ->Void) ->Void{

        self.photoQueue.addOperation{
         
            let camerollAlbum:PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil);
            
            var groups:[QYGroup] = Array<QYGroup>();
            camerollAlbum .enumerateObjects { (obj, idx, stop) in
                
                if obj.assetCollectionSubtype == .smartAlbumUserLibrary
                {
                    let option = self.getFetchOption(type: type);
                    let assetModel:[QYAsset] = self.fetchCollection(collection: obj, option: option);
                    let group:QYGroup = QYGroup.init(collection: obj, assetModels: assetModel);
                    groups.append(group);
                }
            };
            self.runOnMainThread {
                
                block(groups);
            }
        }
    }
    
    open func requestOriginImage(asset:QYAsset, completedHandler:QYPhotoSuccess?,
                                 progress:QYPhotoProgress?) ->PHImageRequestID{
        
        return requestOriginImage(option: nil, asset: asset, completedHandler: completedHandler, progress: progress);
    }
    open func requestOriginImage(option:PHImageRequestOptions?,
                                 asset:QYAsset,
                                 completedHandler:QYPhotoSuccess?,
                                 progress:QYPhotoProgress?)->PHImageRequestID{
        
        var tmpOption:PHImageRequestOptions? = PHImageRequestOptions.init();
        tmpOption?.deliveryMode = .highQualityFormat;
        tmpOption?.resizeMode = .exact;
        tmpOption?.isNetworkAccessAllowed = true;
        
        if let _ = option{
            tmpOption = option;
        }
        
        tmpOption?.progressHandler = {(pro,error,stop,info) in
            progress?(pro,error);
        };
        return PHCachingImageManager.default().requestImageData(for: asset.phAsset!, options: tmpOption, resultHandler: { (imageDate, dataUTI, orientation ,info) in
            
            let finished:Bool = self.getFinishState(info!);
            if finished == true{
                
                guard let completed:QYPhotoSuccess = completedHandler else {
                    
                    return ;
                }
                let image:UIImage = UIImage.init(data: imageDate!)!;
                self.runOnMainThread {
                
                    completed(image);
                };
            }
            
        });
    }
    
    open func requestThumbImage(asset:QYAsset,
                                size:CGSize,
                                completedHandler:QYPhotoSuccess?,progress:QYPhotoProgress?) ->PHImageRequestID{
    
        return requestThumImage(asset: asset,
                                option: nil,
                                size: size,
                                completedHandler: completedHandler,
                                progress: progress);
    }
    
    open func requestThumImage(asset:QYAsset,option:PHImageRequestOptions?,size:CGSize, completedHandler:QYPhotoSuccess?,progress:QYPhotoProgress?)->PHImageRequestID{
        
        var tmpOptions = defautRequestImageOption();
        if  let o:PHImageRequestOptions = option {
            tmpOptions = o;
        }
        tmpOptions.progressHandler = {(pro,error,stop,info) in
            progress?(pro,error);
        };
        
        return  PHCachingImageManager.default().requestImage(for: asset.phAsset!, targetSize: size, contentMode: .aspectFill, options: tmpOptions, resultHandler: { (image, info) in
            
            guard let img:UIImage = image else{
                
                print("error get thumbImage faild");
                return ;
            }
            
            guard let _:QYPhotoSuccess = completedHandler  else {
                
                print(" completedHandler is nil");
                return ;
            }
            completedHandler!(img);
        });
    }
}
extension QYPhotoSever
{
    /// 获取所有的相册
    ///
    /// - Returns: 相机集合
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
    
    private func defautRequestImageOption()->PHImageRequestOptions {
        
        let options:PHImageRequestOptions = PHImageRequestOptions.init();
        options.resizeMode = .fast;
        options.isNetworkAccessAllowed = true;
        options.isSynchronous = false;
        return options;
    }
    
    private func runOnMainThread(block:@escaping()->Void)->Void
    {
        if Thread.isMainThread {
            
            block();
        }
        else
        {
            DispatchQueue.main.async {
                block();
            }
        }
    }
    private func getFinishState(_ info:Dictionary<AnyHashable, Any>) -> Bool{
        
        var isCancel = false;
        var isError = false;
        var isDegraded = false;
        
        if let cancel:NSNumber = info[PHImageCancelledKey] as? NSNumber {
            isCancel = cancel.boolValue;
        }
        if let error:NSNumber =  info[PHImageErrorKey] as? NSNumber {
            
            isError = error.boolValue;
        }
        if let degraded:NSNumber = info[PHImageResultIsDegradedKey] as? NSNumber {
            
            isDegraded = degraded.boolValue;
        }
        
       return !isCancel && !isError && !isDegraded;
    
    }
}
