//
//  GroupListViewVC.swift
//  QYSWAlbum
//
//  Created by liuming on 2018/7/16.
//  Copyright © 2018年 yoyo. All rights reserved.
//

import UIKit

class GroupListViewVC: UIViewController {
    
    private var groupArray: Array<QYGroup>? = Array<QYGroup>.init()
    
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.register(QYAlbumGroupCell.self, forCellReuseIdentifier: "cellId")
        tableView.rowHeight = 80.0
        tableView.tableFooterView = UIView()

        QYPhotoSever.shareInstanced.fetchAlbum(type: .All) { groups in
            self.groupArray = groups
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension GroupListViewVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc: ViewController = ViewController()
        let group: QYGroup = groupArray![indexPath.row]
        vc.albumArray = group.assets
        vc.title = group.phCollection.localizedTitle
        navigationController?.pushViewController(vc, animated: true)
    }

    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        guard let array: Array<QYGroup> = groupArray else {
            return 0
        }
        return array.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: QYAlbumGroupCell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! QYAlbumGroupCell
        cell.updateContet(groupArray?[indexPath.row])
        return cell
    }
}
