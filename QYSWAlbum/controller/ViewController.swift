//
//  ViewController.swift
//  QYSWAlbum
//
//  Created by liuming on 2018/3/12.
//  Copyright © 2018年 yoyo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var collectionView:UICollectionView?;
    private let leftAndRigghtMargin:CGFloat = 0.0;
    
    public var albumArray:Array<QYAsset>?;
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.white;
        let layoutView:UICollectionViewFlowLayout = UICollectionViewFlowLayout.init();
        collectionView = UICollectionView.init(frame: self.view.bounds, collectionViewLayout: layoutView);
        collectionView?.backgroundColor = UIColor.white;
        collectionView?.delegate = self;
        collectionView?.dataSource = self;
        collectionView?.register(QYAssetCell.self, forCellWithReuseIdentifier: "cellID");
        
        self.view.addSubview(collectionView!);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController:UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{

    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        guard let array:Array<QYAsset> = albumArray else {

            return 0;
        }
        return array.count;
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:QYAssetCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellID", for: indexPath) as! QYAssetCell;
        cell.updateContent(self.albumArray?[indexPath.row]);
        return cell;
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int{
    
        return 1;
    }
     public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        
        //
        print("点击 单元格 section = \(indexPath.section) row = \(indexPath.row)");
        
        let vc:QYPreviewVC = QYPreviewVC.init();
        vc.title = "预览";
        vc.asset = albumArray?[indexPath.row];
        self.navigationController?.pushViewController(vc, animated: true);
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let albumWidth:CGFloat =  ((self.view.bounds.width - leftAndRigghtMargin * 2.0) - 5.0 * 2.0)/3.0;
        return CGSize.init(width: albumWidth, height: albumWidth);
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets.init(top: 0,
                                 left: leftAndRigghtMargin,
                                 bottom: 0,
                                 right: leftAndRigghtMargin
                                );
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 5.0;
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0;
    }
    
    public func collectionview(_ collectionview:UICollectionView,layout collectionViewLayout:UICollectionViewLayout, maxLineSpacingForSectionAt section: Int)->CGFloat{
        
        return 5.0;
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, maxInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0;
    }
    
}

