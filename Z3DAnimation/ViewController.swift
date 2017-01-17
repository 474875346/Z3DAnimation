//
//  ViewController.swift
//  Z3DAnimation
//
//  Created by 新龙科技 on 2017/1/17.
//  Copyright © 2017年 新龙科技. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.brown
        let imageArr = ["11.jpg", "22.jpg","33.jpg", "44.jpg","55.jpg","66.jpg","77.jpg"]
        let circleView = Z3DCircleAnimationView.init(frame: CGRect(x: 20, y: 20, width: view.frame.size.width-40, height:200 ))
        circleView.animationDurtion = 3
        circleView.duration = 1.2
        circleView.animationType = Z3DCircleAnimationView.Z3DAnimationTpye(rawValue: 3)
        circleView.toLeftSubtype = Z3DCircleAnimationView.Z3DDirectionSubtype(rawValue: 2)
        circleView.toRightSubtype = Z3DCircleAnimationView.Z3DDirectionSubtype(rawValue: 1)
        circleView.Z3D_ImageDataSource = imageArr as NSArray
        self.view.addSubview(circleView)
        circleView.userClickBlock = {
            print($0)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

