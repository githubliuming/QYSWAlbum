//
//  QYPreviewVC.swift
//  QYSWAlbum
//
//  Created by liuming on 2018/7/16.
//  Copyright © 2018年 yoyo. All rights reserved.
//

import UIKit

class QYPreviewVC: UIViewController {

    var preImageView: UIImageView = UIImageView.init();
    public var asset:QYAsset?;
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let ast:QYAsset = asset else {
            print(" asset is nil");
            return ;
        }
        preImageView.frame = self.view.bounds;
        self.view.addSubview(preImageView);
        
      let _ = QYPhotoSever.shareInstanced.requestOriginImage(option: nil,
                                                             asset: ast,
                                                             completedHandler: { (image) in
    
                                self.preImageView.image = image!;
        }, progress: nil);
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
