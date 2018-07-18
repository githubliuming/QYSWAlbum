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
   public static let shareInstanced:QYPhotoSever = QYPhotoSever.init();
   private override init()
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
    
    /// 遍历相机胶卷中的数据
    ///
    /// - Parameters:
    ///   - type: 获取的资源类型
    ///   - block: 完成回调
    open func fetchCamerollCollection(type:QYPhotoLibarayAssertType,
                                      block:@escaping(_:Array<QYGroup>) ->Void) ->Void{

        self.photoQueue.addOperation{
         
            let camerollAlbum:PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: self.getFetchOption(type: type));
            
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
    
    /// 获取 资源原图
    ///
    /// - Parameters:
    ///   - asset: 相册资源
    ///   - completedHandler: 完成回调
    ///   - progress: 进度回调(从icloud云端下载)
    /// - Returns: 当前资源请求的 requestID;
    open func requestOriginImage(asset:QYAsset, completedHandler:QYPhotoSuccess?,
                                 progress:QYPhotoProgress?) ->PHImageRequestID{
        
        let options:PHImageRequestOptions? = PHImageRequestOptions.init();
        options?.deliveryMode = .highQualityFormat;
        options?.resizeMode = .exact;
        options?.isNetworkAccessAllowed = true;
        
        options?.progressHandler = {(pro,error,stop,info) in
            progress?(pro,error);
        };
        
        return requestOriginImage(option: options, asset: asset, completedHandler: completedHandler, progress: progress);
    }
    
    /// 获取 资源原图
    ///
    /// - Parameters:
    ///   - option: 请求原图的配置选项
    ///   - asset: 相册资源
    ///   - completedHandler: 完成回调
    ///   - progress: 进度回调 (icloud云下载)
    /// - Returns: 当前资源请求的 requestID
    open func requestOriginImage(option:PHImageRequestOptions?,
                                 asset:QYAsset,
                                 completedHandler:QYPhotoSuccess?,
                                 progress:QYPhotoProgress?)->PHImageRequestID{
        

        return PHCachingImageManager.default().requestImageData(for: asset.phAsset!, options: option, resultHandler: { (imageDate, dataUTI, orientation ,info) in
            
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
    
    /// 获取资源缩略图大小
    ///
    /// - Parameters:
    ///   - asset: 相册资源
    ///   - size: 指定缩略图 大小
    ///   - completedHandler: 完成回调
    ///   - progress: 进度条回调
    /// - Returns: 当前资源请求的 requestID;
    open func requestThumbImage(asset:QYAsset,
                                size:CGSize,
                                completedHandler:QYPhotoSuccess?,progress:QYPhotoProgress?) ->PHImageRequestID{
    
        return requestThumImage(asset: asset,
                                option: nil,
                                size: size,
                                completedHandler: completedHandler,
                                progress: progress);
    }
    
    /// 获取资源的缩略图
    ///
    /// - Parameters:
    ///   - asset: 相册资源
    ///   - option: 请求缩略图的配置选项
    ///   - size: 指定缩略图大小
    ///   - completedHandler: 完成回调
    ///   - progress: 进度回调
    /// - Returns: 当前资源请求的 requestID;
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
    
      //MARK:- 视频
    
    /// 获取视频资源
    ///
    /// - Parameters:
    ///   - asset: 相册资源
    ///   - success: 导出视频成功回调
    ///   - failure: 导出失败回调
    ///   - progress: 进度回调
    /// - Returns: 前资源请求的 requestID
    open func requestVideo(_ asset:QYAsset,success:QYVideoSucces?,failure:QYPhotoError?,progress:QYPhotoProgress?) ->PHLivePhotoRequestID {
        
        let videoOptions:PHVideoRequestOptions = PHVideoRequestOptions.init();
        videoOptions.isNetworkAccessAllowed = true;
        videoOptions.deliveryMode = .mediumQualityFormat;
        videoOptions.progressHandler = {(prog,error,stop,info) in
            self.runOnMainThread {
                progress?(prog,error);
            }
        };
        return self.requestVidoe(asset, options: videoOptions, finish: { (url, error) in
           
            guard let outPutUrl:URL = url as URL! else {
                self.runOnMainThread {
                    failure?(error);
                }
                return ;
            }
            self.runOnMainThread {
                success?(outPutUrl);
            }
        });
    }
    
    /// 获取视频资源
    ///
    /// - Parameters:
    ///   - asset:   相册资源
    ///   - options: 请求配置选项
    ///   - finish: 完成回调
    /// - Returns: 前资源请求的 requestID
    private func requestVidoe(_ asset:QYAsset,
                              options:PHVideoRequestOptions,
                              finish:@escaping(_ url:URL?,_ error:Error?)->Void)
        ->PHImageRequestID{
    
            let imageManager:PHImageManager = PHImageManager.default();
            let imageRequestId = imageManager.requestAVAsset(forVideo: asset.phAsset!, options: options) { (asset, audioMix, info) in
                
                if let icloudNum:NSNumber = info?[PHImageCancelledKey] as? NSNumber {
                    
                    if icloudNum.boolValue == true {
                        print("PHImageCancelledKey 对应的值为真时代表用户手动取消云端下载");
                        return;
                    }
                }
                switch asset{
                case let urlAsset  as AVURLAsset:
                    print("正常视频");
                    self.runOnMainThread {
                        let url:URL = urlAsset.url;
                        finish(url,nil);
                    }
                case let compositon as AVComposition:
                    print("慢动作视频");
                    let fileName = "mergeSlowMoVideo_"+"\(Int64(Date.init().timeIntervalSince1970))" + ".mov";
                    
                    let filePath:String = NSHomeDirectory()+"/Documents/"+fileName;
                    self.exportVideo(compositon, fileUrl: URL.init(string: filePath)!, completion: { (outputPath, error) in
                        self.runOnMainThread {
                            finish(outputPath,error);
                        }
                        
                    });
                    
                default:print("未知视频资源");
                    
                }
            }
            return imageRequestId;
    }
    
    
    /// 保存图片到 系统相册， gif使用该api只会保存一张静止的图片
    ///
    /// - Parameters:
    ///   - image: 图片对象
    ///   - completion: 完成回调
    open func saveImage(_ image:UIImage,completion:((_ result:Bool,_ model:QYAsset?) -> Void)?) ->Void{
        self.saveImage(image, completion: completion);
    }
    //MARK: - 保存图片、视频
    
    /// 保存图片到系统相册 gif使用该api只会保存一张静止的图片
    ///
    /// - Parameters:
    ///   - image: 图片对象
    ///   - customName: 自定义相册
    ///   - completion: 完成回调
    open func saveImage(_ image:UIImage,
                        customName:String?,
                        completion:((_ result:Bool,_ model:QYAsset?) -> Void)?)->Void{
        
        let request:PHAssetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image);
        self.saveAssetToAlbum(customAlbumName: customName, request: request, completion: completion);
    }
    
    
    /// 保存图片到相册，该api可以保存gif
    ///
    /// - Parameters:
    ///   - imagePath: 图片、gif路径
    ///   - customAlbumName: 自定义相册
    ///   - completion: 完成回调
    open func saveImage(_ imagePath:String,customAlbumName:String?,completion:((_ result:Bool,_ model:QYAsset?) -> Void)?)->Void{
        
           let request:PHAssetChangeRequest? = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL:URL.init(fileURLWithPath: imagePath));
        
        guard let rq = request else {
            self.runOnMainThread {
                print("error PHAssetChangeRequest init failure");
                if completion != nil {
                    completion!(false,nil);
                }
            }
            return ;
        }
        self.saveAssetToAlbum(customAlbumName: customAlbumName, request: rq, completion: completion);
    }
    //MARK : - 保存视频
    
    /// 保存视频到相册
    ///
    /// - Parameters:
    ///   - videoPath: 视频路径
    ///   - customAlbumName: 自定义相册
    ///   - completion: 完成回调
    open func saveVideo(_ videoPath:String,customAlbumName:String?,completion:((_ result:Bool,_ model:QYAsset?) -> Void)?)
    {
         let request:PHAssetChangeRequest? = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL.init(fileURLWithPath: videoPath));
        guard let rq = request else {
            self.runOnMainThread {
                print("error PHAssetChangeRequest init failure");
                if completion != nil {
                    completion!(false,nil);
                }
            }
            return ;
        }
        self.saveAssetToAlbum(customAlbumName: customAlbumName, request: rq, completion: completion);
        
    }
    
    //MARK: - 存相册公用模块
    private func saveAssetToAlbum(customAlbumName:String?,
                                  request:PHAssetChangeRequest,
                                  completion:((_ result:Bool,_ model:QYAsset?) -> Void)?) -> Void{
        
        func finishHandler(_ result:Bool = false,asset ast:PHAsset? = nil) ->Void{
            self.runOnMainThread {
                if let _ = completion {
                    let assetModel:QYAsset? = QYAsset.init(asset: ast!);
                    completion!(result,assetModel);
                }
            }
        }
        
        let status:PHAuthorizationStatus = QYPhotoSever.albumPermissonStatues();
        if status == .denied || status == .restricted {
            //用户拒绝权限
            finishHandler();
        } else {
            
            self.saveAssetToAlbum(customName: customAlbumName,
                                  willPerformChange: { () -> PHAssetChangeRequest in
                                    
                                    return request;
            },
                                  completion: finishHandler);
        }
        
    }
    private func saveAssetToAlbum(customName:String?,
                                  willPerformChange:@escaping ()->PHAssetChangeRequest,
                                  completion:@escaping (_ result:Bool,_ model:PHAsset?) -> Void)->Void{

        func finishHandler(_ result:Bool = false,asset ast:PHAsset? = nil) ->Void{
            completion(result,ast);
        }
        var placeholderAsset:PHObjectPlaceholder? = nil;
         let photolibrary:PHPhotoLibrary = PHPhotoLibrary.shared();
        photolibrary.performChanges({
            let changeRequest:PHAssetChangeRequest = willPerformChange();
            placeholderAsset  = changeRequest.placeholderForCreatedAsset
            
        }, completionHandler: { (succ,Error) in
            
            if succ == false {
                finishHandler();
                return ;
            }
            let asset :PHAsset? = self.getAsset(identifier: (placeholderAsset?.localIdentifier)!);
            guard customName != nil else {
                finishHandler(succ,asset: asset);
                return ;
            }
            //移动到自定义相册中
            let desCollection:PHAssetCollection? = self.getDestinationColletion(customName);
            if let desc = desCollection
            {
                PHPhotoLibrary.shared().performChanges({
                    
                    let changeRequest:PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest.init(for: desc)!;
                    changeRequest.addAssets(asset as! NSFastEnumeration);
                }, completionHandler: { (succ:Bool, error:Error?) in
                    finishHandler(succ,asset: asset);
                })
            } else {
                finishHandler();
            }
        })
        
    }
    
    private func getAsset(identifier id:String) ->PHAsset?{
        
        let result :PHFetchResult = PHAsset.fetchAssets(withBurstIdentifier: id, options: nil);
        if result.count > 0 {
            return result.firstObject;
        }
        return nil;
    }
    
    private func getDestinationColletion(_ collectionName:String?) -> PHAssetCollection?{
        
        guard collectionName != nil else {
            
            return nil;
        }
        //查找自定义相册
        let colletionResult:PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil);
        for i in 0..<colletionResult.count {
            let collection = colletionResult.object(at: i);
            if collection.localizedTitle != nil {
                if collection.localizedTitle! == collectionName! {
                    return collection;
                }
            }
        }
        //未找到相册 --> 新建立自定义相册
        var collectionID:String = String();
        do {
          try PHPhotoLibrary.shared().performChangesAndWait {
                let placeholder:PHObjectPlaceholder =   PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: collectionName!).placeholderForCreatedAssetCollection;
                collectionID = placeholder.localIdentifier;
            }
            return PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [collectionID], options: nil).lastObject
        } catch let error {
            print("error \(error) ")
        }
        return nil;
    }
    
    //MARK: - 删除相册元素
    
    /// 删除相册中的元素
    ///
    /// - Parameters:
    ///   - asset: 相册资源
    ///   - completion: 完成回调
    open func deleMedailWithAsset(_ asset:QYAsset,completion:QYDeleteAssetCompletionBlock?) -> Void{
        
        self.deleMedailWithAsset(asset, customAlbumName: nil, completion: completion);
    }
    
    /// 删除相册元素
    ///
    /// - Parameters:
    ///   - asset: 相册资源
    ///   - customAlbumName: 自定义的相册名
    ///   - completion: 完成回调
    open func deleMedailWithAsset(_ asset:QYAsset,
                                  customAlbumName:String?,
                                  completion:QYDeleteAssetCompletionBlock?) -> Void{
        
        func finishHanderl(success:Bool = false,error:Error? = nil) -> Void{
            guard let cmp = completion else {
                return ;
            }
            cmp(success,error);
        }
        let photoLibrary:PHPhotoLibrary = PHPhotoLibrary.shared();
        photoLibrary .performChanges({
            PHAssetChangeRequest.deleteAssets(asset.phAsset as! NSFastEnumeration);
        }, completionHandler: {(succ,error) in
            
            if succ == true{
                
                if customAlbumName != nil {
                    let desCollection = self.getDestinationColletion(customAlbumName);
                    if desCollection != nil {
                        photoLibrary.performChanges({
                            let request:PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest.init(for: desCollection!)!;
                            request.removeAssets(asset.phAsset as! NSFastEnumeration)
                            
                        }, completionHandler: { (succ, error) in
                            finishHanderl(success: succ,error: error);
                        })
                    } else {
                        finishHanderl();
                    }
                    
                } else {
                    finishHanderl(success: succ,error: error);
                }
            } else {
                finishHanderl();
            }
        });
    }
    
    
    //MARK: -取消云端下载
    
    /// 取消云端下载
    ///
    /// - Parameter requsetId: 取消下载的 requestId
    open func cancelRequest( requsetId:PHImageRequestID?){
        
        guard let rqId = requsetId else {
            print("requestId is nil");
            return;
        }
        PHCachingImageManager.default().cancelImageRequest(rqId);
    }
}
//MARK: - extension模块
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
                argumentArray: [PHAssetMediaType.image.rawValue,PHAssetMediaType.video.rawValue]
            );
        case.Photos:
            options.predicate = NSPredicate(format: "mediaType = %d", argumentArray: [PHAssetMediaType.image]);
        case .LivePhotoAndVideos:
            if #available(iOS 9.1, *)
            {
                options.predicate = NSPredicate(format:"(mediaType = %d and mediaSubtype == %d) or mediaType = %d ", argumentArray: [PHAssetMediaType.image.rawValue,PHAssetMediaSubtype.photoLive.rawValue,PHAssetMediaType.video.rawValue]);
            }
            else
            {
                // Fallback on earlier versions
                options.predicate = NSPredicate(format:" mediaType = %d", argumentArray: [PHAssetMediaType.video.rawValue]);
            }
        case.Panoramas:
            options.predicate = NSPredicate(
                format: "mediaType = %d and mediaSubtype == %d",
                argumentArray: [PHAssetMediaType.image,PHAssetMediaSubtype.photoPanorama.rawValue]
            );
        case .Video:
            options.predicate = NSPredicate(
                format: "mediaType = %d",
                argumentArray: [PHAssetMediaType.video.rawValue]);
        case .LivePhoto:
            if #available(iOS 9.1, *)
            {
                options.predicate  = NSPredicate(format: "mediaType = %d and mediaSubtype == %d", argumentArray: [PHAssetMediaType.image,PHAssetMediaSubtype.photoLive.rawValue]);
            }
            else
            {
                options.predicate = NSPredicate(format: "mediaType = %d", argumentArray: [PHAssetMediaType.image.rawValue]);
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
    
    /// 导出慢动作视频
    ///
    /// - Parameters:
    ///   - compostion: 慢动作视频的AVAsset
    ///   - fileUrl: 导出文件路径
    ///   - completion: 完成回调
    private func exportVideo(_ compostion:AVAsset,fileUrl:URL, completion:@escaping(_ url:URL?,_ error:Error?) -> Void) ->Void{
        
        let exportSession:AVAssetExportSession = AVAssetExportSession.init(asset: compostion, presetName: AVAssetExportPresetHighestQuality)!;
        exportSession.outputURL = fileUrl;
        exportSession.outputFileType = AVFileType.mov;
        exportSession.shouldOptimizeForNetworkUse = true;
        exportSession .exportAsynchronously {
          
            if exportSession.status == AVAssetExportSessionStatus.completed {
                let outUlr:URL? = exportSession.outputURL;
                completion(outUlr,nil);
            } else {
                completion(nil,exportSession.error);
            }
        };
        
    }
    private func getSaveToAblumHandler(completion:((_ result:Bool,_ model:QYAsset?) -> Void)?) -> (_ result:Bool ,_ ast:PHAsset? ) ->Void {
        func finishHandler(_ result:Bool = false,asset ast:PHAsset? = nil) ->Void{
            self.runOnMainThread {
                if let _ = completion {
                    let assetModel:QYAsset? = QYAsset.init(asset: ast!);
                    completion!(result,assetModel);
                }
            }
        }
        return finishHandler;
    }
}
