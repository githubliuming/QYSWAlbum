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
    public var qy_width: CGFloat {
        get { return bounds.size.width }
        set(newValue) {
            var tmpFrame: CGRect = frame
            tmpFrame.size.width = newValue
            updateFrame(rect: tmpFrame)
        }
    }

    /// 获取、设置视图高度
    public var qy_height: CGFloat {
        get { return bounds.size.height }
        set(newValue) {
            var tmpFrame: CGRect = frame
            tmpFrame.size.height = newValue
            updateFrame(rect: tmpFrame)
        }
    }

    /// 获取、设置 视图左边x坐标
    public var qy_left: CGFloat {
        get { return frame.origin.x }
        set(newValue) {
            var tmpFrame: CGRect = frame
            tmpFrame.origin.x = newValue
            updateFrame(rect: tmpFrame)
        }
    }

    /// 获取、设置视图右边x的值
    public var qy_right: CGFloat {
        get { return (frame.origin.x + qy_width) }
        set(newValue) {
            qy_left = newValue - qy_width
        }
    }

    /// 获取、设置视图顶部的y值
    public var qy_top: CGFloat {
        get { return frame.origin.y }
        set(newValue) {
            var tmpRect: CGRect = frame
            tmpRect.origin.y = newValue
            updateFrame(rect: tmpRect)
        }
    }

    /// 获取、设置视图底部的 y值
    public var qy_bottom: CGFloat {
        get { return qy_top + qy_height }
        set(newValue) {
            qy_top = newValue - qy_height
        }
    }

    private func updateFrame(rect newReact: CGRect) {
        frame = newReact
    }

    /// 设置圆角
    ///
    /// - Parameters:
    ///   - conrners: 圆角的位置 ：.topLeft | .topRight
    ///   - size: 圆角大小
    public func qy_RounderCorners(_ conrners: UIRectCorner, radiusSize size: CGSize) {
        let maskPath: UIBezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: conrners, cornerRadii: size)
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
}
