//
//  ViewController.swift
//  QYSWAlbum
//
//  Created by liuming on 2018/3/12.
//  Copyright © 2018年 yoyo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private var collectionView: UICollectionView?
    private let leftAndRigghtMargin: CGFloat = 0.0

    public var albumArray: Array<QYAsset>?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.white
        let layoutView: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layoutView)
        collectionView?.backgroundColor = UIColor.white
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.register(QYAssetCell.self, forCellWithReuseIdentifier: "cellID")

        view.addSubview(collectionView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        guard let array: Array<QYAsset> = albumArray else {
            return 0
        }
        return array.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: QYAssetCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellID", for: indexPath) as! QYAssetCell
        cell.updateContent(albumArray?[indexPath.row])
        return cell
    }

    public func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //
        print("点击 单元格 section = \(indexPath.section) row = \(indexPath.row)")

        let vc: QYPreviewVC = QYPreviewVC()
        vc.title = "预览"
        vc.asset = albumArray?[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let albumWidth: CGFloat = ((view.bounds.width - leftAndRigghtMargin * 2.0) - 5.0 * 2.0) / 3.0
        return CGSize(width: albumWidth, height: albumWidth)
    }

    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0,
                            left: leftAndRigghtMargin,
                            bottom: 0,
                            right: leftAndRigghtMargin
        )
    }

    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return 5.0
    }

    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return 0
    }

    public func collectionview(_: UICollectionView, layout _: UICollectionViewLayout, maxLineSpacingForSectionAt _: Int) -> CGFloat {
        return 5.0
    }

    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, maxInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return 0
    }
}
