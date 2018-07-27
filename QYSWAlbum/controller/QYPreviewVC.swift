//
//  QYPreviewVC.swift
//  QYSWAlbum
//
//  Created by liuming on 2018/7/16.
//  Copyright © 2018年 yoyo. All rights reserved.
//

import UIKit

class QYPreviewVC: UIViewController {
    var preImageView: UIImageView = UIImageView()
    public var asset: QYAsset?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let ast: QYAsset = asset else {
            print(" asset is nil")
            return
        }
        view.backgroundColor = UIColor.white
        view.clipsToBounds = true
        preImageView.frame = view.bounds
        preImageView.contentMode = .scaleAspectFit
        view.addSubview(preImageView)

        _ = QYPhotoSever.shareInstanced.requestOriginImage(option: nil,
                                                           asset: ast,
                                                           completedHandler: { image in

                                                               self.preImageView.image = image!
        }, progress: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
