//
//  YWBookListViewController.swift
//  YWPowerProject
//
//  Created by zhengfeng1 on 2017/6/8.
//  Copyright © 2017年 蒋正峰. All rights reserved.
//

import UIKit
@objc(YWBookListViewController)


open class YWBookListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    var listCollectionView : UICollectionView?
    var bookList = NSMutableArray()
    let width = UIScreen.main.bounds.size.width
    let height = UIScreen.main.bounds.size.height
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        initView()

        // Do any additional setup after loading the view.
    }
    
    func initView() {
        let layout = UICollectionViewLayout()
        listCollectionView = UICollectionView(frame: CGRect(x:0, y:0, width:width, height:height), collectionViewLayout: layout)
        listCollectionView!.register(YWBookListViewController.self, forCellWithReuseIdentifier: "YWBookListCell")
        listCollectionView?.delegate = self
        listCollectionView?.dataSource = self
        listCollectionView?.backgroundColor = UIColor.white
        
        self.view .addSubview(listCollectionView!)
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookList.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YWBookListCell", for: indexPath)
        let title = bookList[indexPath.row] as! String
        let label : UILabel? = UILabel.init(frame: cell.bounds)
        cell.addSubview(label!)
        label?.text = title
        print(title)
        return cell
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
