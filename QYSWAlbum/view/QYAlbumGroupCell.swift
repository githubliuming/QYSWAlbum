//
//  QYAlbumGroupCell.swift
//  QYSWAlbum
//
//  Created by liuming on 2018/7/16.
//  Copyright © 2018年 yoyo. All rights reserved.
//

import UIKit

class QYAlbumGroupCell: UITableViewCell {
    public var group: QYGroup?

    private let coverImage: UIImageView = UIImageView()
    private let titleLabel: UILabel = UILabel()
    private let countLabel: UILabel = UILabel()
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initSubViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }

    private func initSubViews() {
        coverImage.contentMode = .scaleAspectFill
        coverImage.clipsToBounds = true
        contentView.addSubview(coverImage)

        contentView.addSubview(titleLabel)
        titleLabel.font = UIFont.systemFont(ofSize: 17.0)
        titleLabel.textColor = UIColor.black

        contentView.addSubview(countLabel)
        countLabel.textColor = UIColor.black
        countLabel.font = UIFont.systemFont(ofSize: 14.0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let imageWidth: CGFloat = qy_height - 20.0
        coverImage.frame = CGRect(x: 10,
                                  y: (qy_height - imageWidth) / 2.0,
                                  width: imageWidth,
                                  height: imageWidth)
        titleLabel.frame = CGRect(x: coverImage.qy_right + 10.0,
                                  y: coverImage.qy_top + 5.0,
                                  width: 200.0,
                                  height: 20.0)
        countLabel.frame = CGRect(x: titleLabel.qy_left,
                                  y: coverImage.qy_bottom - 20.0 - 5.0,
                                  width: 200,
                                  height: 20.0)
    }

    public func updateContet(_ group: QYGroup?) {
        guard let tmpGroup: QYGroup = group else {
            coverImage.image = nil
            titleLabel.text = String.emptyString()
            countLabel.text = String.emptyString()
            return
        }
        self.group = group
        let asset: QYAsset = tmpGroup.assets.first!

        _ = QYPhotoSever.shareInstanced.requestThumbImage(asset: asset, size: CGSize(width: 240, height: 240), completedHandler: { image in
            self.coverImage.image = image
        }, progress: nil)
        titleLabel.text = group?.phCollection.localizedTitle
        countLabel.text = "\(String(describing: group!.assets.count)) 张图片"
    }
}
