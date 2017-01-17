//
//  Z3DCircleAnimationView.swift
//  Z3DCircleAnimationView
//
//  Created by 新龙科技 on 2017/1/10.
//  Copyright © 2017年 新龙科技. All rights reserved.
//

import UIKit

class Z3DCircleAnimationView: UIView {
    typealias userClickCallBackBlock = (_ model:NSInteger)->Void
    //** 模型数据源(里面存储的是图片的URL) **//
    var Z3D_ImageDataSource : NSArray? {
        didSet{
            self.pageControl?.numberOfPages = (self.Z3D_ImageDataSource?.count)!
            self.pageControl?.center = CGPoint(x: self.frame.size.width-CGFloat( (self.Z3D_ImageDataSource?.count)!*10), y: (self.pageControl?.center.y)!)
            print(Z3D_ImageDataSource?.count as Any)
            self.show3DBannerView()
        }
    }
    /** 文字数据源 */
    var Z3D_TextDataSource : NSArray?{
        didSet{
            self.show3DLableView()
        }
    }
    /** 点击轮播图片的回调 */
    var userClickBlock : userClickCallBackBlock?
    /** 轮播时间 */
    var animationDurtion : CGFloat?{
        didSet {
            if animationDurtion! > CGFloat(0) {
                if (self.timer != nil) {
                    self.removeMyTimer()
                }
                self.timer = Timer.scheduledTimer(timeInterval: Double(animationDurtion!), target: self, selector: #selector((self.changeImageAction(sender:))), userInfo: nil, repeats: true)
            } else {
                self.removeMyTimer()
            }
        }
    }
    /** 轮播时间间隔 */
    var duration : CGFloat?
    /** 轮播动画的样式 */
    var animationType : Z3DAnimationTpye?
    /** 轮播动画向左方向 */
    var toLeftSubtype : Z3DDirectionSubtype?
    /** 轮播动画向右方向 */
    var toRightSubtype : Z3DDirectionSubtype?
    /** 定时器 **/
    var timer : Timer?
    //** 当前图片的下标 **//
    var currentIndex : Int? = 0
    //** 图片 **//
    lazy var imageView :UIImageView = {
        let image = UIImageView(frame: self.bounds)
        image.tag = 0
        image.isUserInteractionEnabled = true
        self.addSubview(image)
        return image
    }()
    //** 文字公告 **//
    lazy var lable : UILabel = {
        let label = UILabel(frame: CGRect(x: 5, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        label.font = UIFont.systemFont(ofSize: 17)
        label.tag = 0
        label.isUserInteractionEnabled = true
        self.addSubview(label)
        return label
    }()
    //声明页码器的属性
    lazy var pageControl : UIPageControl? = {
        let pageControl = UIPageControl(frame: CGRect(x: 0, y: self.frame.size.height-25, width: self.frame.size.width, height: 25))
        //设置当前页点的颜色
        pageControl.currentPageIndicatorTintColor = UIColor.red
        //设置其他页点的颜色
        pageControl.pageIndicatorTintColor = UIColor.white
        //关闭用户交互
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()
    //动画模式
    let animationModeArr = ["cube", "moveIn", "reveal", "fade","pageCurl", "pageUnCurl", "suckEffect", "rippleEffect", "oglFlip"]
    
    enum Z3DAnimationTpye:Int {
        case  Z3DAnimationTpyeCube,         //3D旋转式动画
        Z3DAnimationTpyeMoveIn,       //向左切入动画
        Z3DAnimationTpyeReveal,       //向左切出动画
        Z3DAnimationTpyeFade,         //溶解淡出动画
        Z3DAnimationTpyePageCurl,     //向左翻页动画
        Z3DAnimationTpyePageUnCurl,   //向右翻页动画
        Z3DAnimationTpyeSuckEffect,   //吸出消失动画
        Z3DAnimationTpyeRippleEffect, //波纹式动画
        Z3DAnimationTpyeOglFlip       //翻牌动画
    }
    enum Z3DDirectionSubtype:Int {
        case  Z3DDirectionSubtypeFromLeft,      //从左边
        Z3DDirectionSubtypeFromRight,     //从右边
        Z3DDirectionSubtypeFromTop,       //从顶部
        Z3DDirectionSubtypeFromBottom    //从底部
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder?=nil) {
        fatalError("init(coder:) has not been implemented")
    }
}
private extension Z3DCircleAnimationView {
    
    func show3DBannerView() -> Void {
        autoreleasepool{
            //创建视图并设置默认图片
            let imgString = self.Z3D_ImageDataSource?[0] as! String
            self.imageView.image = UIImage(named:imgString)
            self.imageView.alpha = 1
            //添加点击手势
            let singleTap = UITapGestureRecognizer.init(target: self, action: #selector((self.clickHandel(tap:))))
            self.imageView.addGestureRecognizer(singleTap)
            //添加向左滑动手势
            let leftSwipeGesture = UISwipeGestureRecognizer.init(target: self, action: #selector((self.leftSwipe(gesture:))))
            leftSwipeGesture.direction = .left
            self.addGestureRecognizer(leftSwipeGesture)
            //创建滑动的手势（向右滑动）
            let rightSwipeGesture = UISwipeGestureRecognizer.init(target: self, action: #selector((self.rightSwipe(gesture:))))
            rightSwipeGesture.direction = .right
            self.addGestureRecognizer(rightSwipeGesture)
             self.addSubview(self.pageControl!)
        }
    }
    func show3DLableView() -> Void {
        autoreleasepool{
            //创建视图并设置默认图片
            if ((self.Z3D_TextDataSource?.count) != nil)
            {
                self.lable.text = self.Z3D_TextDataSource?[0] as! String?
            }
            //添加点击手势
            let singleTap = UITapGestureRecognizer.init(target: self, action: #selector((self.clickHandel(tap:))))
            self.lable.addGestureRecognizer(singleTap)
        }
    }
    //MAKR:定时器滞空
    func removeMyTimer() -> Void {
        if (self.timer != nil) {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    @objc func changeImageAction(sender:Timer) -> Void {
        self.transitionAnimation(isNext: true, mode:(self.animationType?.rawValue)!)
    }
    func transitionAnimation(isNext:Bool,mode:Int) -> Void {
        autoreleasepool{
            // 动画方向
            let directionSubtype = ["fromLeft","fromRight","fromTop","fromBottom"]
            //1.创建转场动画对象
            let transition = CATransition()
            //2.设置动画类型,注意对于苹果官方没公开的动画类型只能使用字符串，并没有对应的常量定义
            //@"cube" @"moveIn" @"reveal" @"fade"(default) @"pageCurl" @"pageUnCurl" @"suckEffect" @"rippleEffect" @"oglFlip"
            transition.type = animationModeArr[mode]
            //设置子类型 （动画的方向）
            if (isNext) {
                transition.subtype = directionSubtype[(self.toLeftSubtype?.rawValue)!]
            }else{
                transition.subtype = directionSubtype[(self.toLeftSubtype?.rawValue)!]
            }
            //设置动画时间
            transition.duration = Double(self.duration!)
            if ((self.Z3D_ImageDataSource?.count) != nil) {
                //3.设置转场后的新视图添加转场动画
                self.imageView.image = UIImage(named:self.getImageName(isNext: isNext))
                //加载动画
                self.imageView.layer.add(transition, forKey: "KCTransitionAnimation")
            }
            if ((self.Z3D_TextDataSource?.count) != nil) {
                self.lable.text = self.getText(isNext: isNext)
                self.lable.textColor = UIColor.blue
                self.lable.layer.add(transition, forKey: "KCTransitionAnimation")
            }
        }
    }
    //MARK:点击手势
    @objc func clickHandel(tap:UITapGestureRecognizer) -> Void {
        self.userClickBlock!(imageView.tag)
    }
    //MARK:左滑手势
    @objc func leftSwipe(gesture:UISwipeGestureRecognizer) -> Void {
        self.transitionAnimation(isNext: true, mode: 4)
    }
    //MARK:右滑手势
    @objc func rightSwipe(gesture:UISwipeGestureRecognizer) -> Void {
        self.transitionAnimation(isNext: false, mode: 5)
    }
    //MARK:取得当前图片
    func getImageName(isNext:Bool) -> String {
        if (isNext) {
            currentIndex=(currentIndex!+1)%(self.Z3D_ImageDataSource?.count)!; //0，1，2，3，4，5，0，1
            print(currentIndex as Any)
            self.pageControl?.currentPage=currentIndex!;
        }else{
            currentIndex=(currentIndex!-1+(self.Z3D_ImageDataSource?.count)!)%Int((self.Z3D_ImageDataSource?.count)!)//0,5,4,3,2,1,5
            
            self.pageControl?.currentPage=currentIndex!
        }
        self.imageView.tag = currentIndex! //标记当前的tag值
        //返回获取的图片
        return self.Z3D_ImageDataSource![currentIndex!] as! String
    }
    //MARK:取得当前文字
    func getText(isNext:Bool) -> String {
        if (isNext) {
            currentIndex=(currentIndex!+1)%(self.Z3D_TextDataSource?.count)! //0，1，2，3，4，5，0，1
        }else{
            currentIndex=(currentIndex!-1+(self.Z3D_TextDataSource?.count)!)%Int((self.Z3D_TextDataSource?.count)!)//0,5,4,3,2,1,5
        }
        self.lable.tag = currentIndex! //标记当前的tag值
        //返回获取的图片
        return self.Z3D_TextDataSource![currentIndex!] as! String
    }
}
