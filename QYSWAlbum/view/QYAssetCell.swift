//
//  QYAssetCell.swift
//  QYSWAlbum
//
//  Created by liuming on 2018/7/16.
//  Copyright © 2018年 yoyo. All rights reserved.
//

import UIKit

class QYAssetCell: UICollectionViewCell {
    let thumbView: UIImageView = UIImageView()
    let videoLabel: UILabel = UILabel()

    var asset: QYAsset?

    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }

    private func initSubViews() {
        thumbView.contentMode = .scaleAspectFill
        thumbView.clipsToBounds = true
        contentView.addSubview(thumbView)

        contentView.addSubview(videoLabel)
        videoLabel.textAlignment = .center
        videoLabel.text = "video"
        videoLabel.font = UIFont.systemFont(ofSize: 13)
        videoLabel.textColor = UIColor.lightText
        videoLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        thumbView.frame = CGRect(x: 0, y: 0, width: qy_width, height: qy_height)
        videoLabel.frame = CGRect(x: thumbView.qy_width - 40, y: thumbView.qy_bottom - 20, width: 40, height: 20)
    }

    open func updateContent(_ asset: QYAsset?) {
        guard let tmpAsset: QYAsset = asset else {
            print("asset is nil ")
            thumbView.image = nil
            videoLabel.isHidden = true
            return
        }
        self.asset = asset
        _ = QYPhotoSever.shareInstanced.requestThumbImage(asset: tmpAsset,
                                                          size: CGSize(width: 240.0, height: 240.0),
                                                          completedHandler: { image in
                                                              self.thumbView.image = image
                                                          })

        videoLabel.isHidden = !(tmpAsset.medaiType == .Video ||
            tmpAsset.medaiType == .HighFrameRate)
    }
}
