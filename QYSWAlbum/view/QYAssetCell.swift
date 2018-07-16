//
//  QYAssetCell.swift
//  QYSWAlbum
//
//  Created by liuming on 2018/7/16.
//  Copyright © 2018年 yoyo. All rights reserved.
//

import UIKit

class QYAssetCell: UICollectionViewCell {
    
    let thumbView:UIImageView = UIImageView.init();
    let videoLabel:UILabel = UILabel.init();
    
    var asset:QYAsset?;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        initSubViews();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        fatalError("init(coder:) has not been implemented")
        
    }
    
    private func initSubViews() {
        thumbView.contentMode = .scaleAspectFill;
        thumbView.clipsToBounds = true;
        self.contentView.addSubview(thumbView)
        
        self.contentView.addSubview(videoLabel);
        videoLabel.textAlignment = .center;
        videoLabel.text = "video";
        videoLabel.font = UIFont.systemFont(ofSize: 13);
        videoLabel.textColor = UIColor.lightText;
        videoLabel.backgroundColor = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3);
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        thumbView.frame = CGRect.init(x: 0, y: 0, width: self.qy_width, height: self.qy_height);
        videoLabel.frame = CGRect.init(x: thumbView.qy_width - 40, y: thumbView.qy_bottom - 20, width: 40, height: 20);
    }
    
    open func updateContent(_ asset:QYAsset?){
        guard let tmpAsset:QYAsset = asset else {
            
            print("asset is nil ");
            thumbView.image = nil;
            videoLabel.isHidden = true;
            return ;
        }
        self.asset = asset;
      let _ =  QYPhotoSever.shareInstanced.requestThumbImage(asset: tmpAsset,
                                                             size: CGSize.init(width: 240.0, height: 240.0),
                                                             completedHandler: { (image) in
            self.thumbView.image  = image;
        },
                                                             progress: nil);
        
        videoLabel.isHidden = !(tmpAsset.medaiType == .Video || tmpAsset.medaiType == .HighFrameRate);
        
    }
}
