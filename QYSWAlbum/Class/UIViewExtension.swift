//
//  UIViewExtension.swift
//  QYSWAlbum
//
//  Created by liuming on 2018/7/16.
//  Copyright © 2018年 yoyo. All rights reserved.
//

import UIKit
extension UIView {
    
    /// 获取、设置视图宽度
    public var qy_width:CGFloat {
        
        get{ return self.bounds.size.width}
        set(newValue){
            var tmpFrame:CGRect = self.frame;
            tmpFrame.size.width = newValue;
            updateFrame(rect: tmpFrame);
        }
    }
    /// 获取、设置视图高度
    public var qy_height:CGFloat {
        get{return self.bounds.size.height}
        set(newValue){
            var tmpFrame:CGRect = self.frame;
            tmpFrame.size.height = newValue;
            updateFrame(rect: tmpFrame);
        }
    }
    
    /// 获取、设置 视图左边x坐标
    public var qy_left:CGFloat{
        
        get{ return self.frame.origin.x}
        set(newValue) {
            var tmpFrame:CGRect = self.frame;
            tmpFrame.origin.x = newValue;
            updateFrame(rect: tmpFrame);
        }
    }
    
    /// 获取、设置视图右边x的值
    public var qy_right:CGFloat{
        get { return (self.frame.origin.x + self.qy_width)}
        set(newValue){
            self.qy_left = newValue - self.qy_width;
        }
    }
    
    /// 获取、设置视图顶部的y值
    public var qy_top:CGFloat{
        
        get{return self.frame.origin.y}
        set(newValue){
            var tmpRect:CGRect = self.frame;
            tmpRect.origin.y = newValue;
            updateFrame(rect: tmpRect);
        }
    }
    
    /// 获取、设置视图底部的 y值
    public var qy_bottom:CGFloat{
        
        get{return self.qy_top + self.qy_height}
        set(newValue){
            self.qy_top = newValue - self.qy_height;
        }
    }
    private func updateFrame(rect newReact:CGRect){
        
        self.frame = newReact;
    }
    
    
    /// 设置圆角
    ///
    /// - Parameters:
    ///   - conrners: 圆角的位置 ：.topLeft | .topRight
    ///   - size: 圆角大小
    public func qy_RounderCorners(_ conrners:UIRectCorner,radiusSize size:CGSize){
        
        let maskPath : UIBezierPath = UIBezierPath.init(roundedRect: self.bounds, byRoundingCorners: conrners, cornerRadii: size);
        let maskLayer:CAShapeLayer = CAShapeLayer.init();
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.cgPath;
        self.layer.mask = maskLayer;
    }
}


