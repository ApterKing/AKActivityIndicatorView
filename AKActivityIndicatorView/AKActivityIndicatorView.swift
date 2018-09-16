//
//  AKActivityIndicatorView.swift
//  AKActivityIndicatorView
//
//  Created by wangcong on 2018/9/16.
//  Copyright © 2018年 wangcong. All rights reserved.
//

import UIKit

/// MARK: 仿原生的UIActivityIndicatorView，增加预刷新进度，通过strokeEnd来控制
class AKActivityIndicatorView: UIView {
    var isAnimating: Bool {
        get {
            return _isAnimating
        }
    }
    var color: UIColor = UIColor.white {
        didSet {
            _preIndicatorLayer.color = color
            _indicatorLayer.color = color
            guard let maskLayer = layer.mask as? CAShapeLayer else { return }
            maskLayer.strokeColor = color.cgColor
        }
    }
    var strokeStart: CGFloat = 0.0 {
        didSet {
            guard let maskLayer = layer.mask as? CAShapeLayer else { return }
            maskLayer.strokeStart = strokeStart
        }
    }
    var strokeEnd: CGFloat = 1.0 {
        didSet {
            guard let maskLayer = layer.mask as? CAShapeLayer else { return }
            maskLayer.strokeEnd = strokeEnd
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        _initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        _initUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = bounds.size.width
        let height = bounds.size.height
        _preIndicatorLayer.position = CGPoint(x: width / 2.0, y: height / 2.0)
        _indicatorLayer.position = _preIndicatorLayer.position
    }
    
    /// 私有属性
    private let _preIndicatorLayer = AKIndicatorLayer()
    private let _indicatorLayer = AKIndicatorLayer()
    private var _isAnimating = false
}

extension AKActivityIndicatorView {
    
    private func _initUI() {
        backgroundColor = UIColor.clear
        
        let outterRadius = _preIndicatorLayer.outterRadius
        let lineWidth = _preIndicatorLayer.lineWidth
        
        let originCenter = center
        self.frame = CGRect(x: 0, y: 0, width: 2 * outterRadius + lineWidth, height: 2 * outterRadius + lineWidth)
        self.center = originCenter

        _preIndicatorLayer.frame = bounds //CGRect(x: 0, y: 0, width: 2 * outterRadius + lineWidth, height: 2 * outterRadius + lineWidth)
        layer.addSublayer(_preIndicatorLayer)
        _preIndicatorLayer.setNeedsDisplay()
        
        _indicatorLayer.isHidden = true
        _indicatorLayer.frame = _preIndicatorLayer.frame
        _indicatorLayer.alphaGradient = 0.05
        layer.insertSublayer(_indicatorLayer, below: _preIndicatorLayer)
        _indicatorLayer.setNeedsDisplay()
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(arcCenter: CGPoint(x: outterRadius + lineWidth / 2.0, y: outterRadius + lineWidth / 2.0), radius: outterRadius + lineWidth / 2.0, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi / 2 * 3, clockwise: true).cgPath
        maskLayer.lineWidth = outterRadius * 2 + lineWidth
        maskLayer.strokeColor = UIColor.red.cgColor
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeEnd = 0.75
        layer.addSublayer(maskLayer)
        layer.mask = maskLayer
        strokeEnd = 0.0
    }
    
}

extension AKActivityIndicatorView {
    func startAnimation() {
        guard _isAnimating == false else { return }
        _isAnimating = true
        _preIndicatorLayer.isHidden = true
        _indicatorLayer.isHidden = false

        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.duration = 0.75
        animation.toValue = Float.pi * 2
        animation.repeatCount = MAXFLOAT
        _indicatorLayer.add(animation, forKey: "rotation")
    }
    
    func stopAnimation() {
        _indicatorLayer.removeAllAnimations()
        _preIndicatorLayer.isHidden = false
        _indicatorLayer.isHidden = true
        _isAnimating = false
    }
}

extension AKActivityIndicatorView {

    class AKIndicatorLayer: CALayer {
        
        fileprivate let outterRadius: CGFloat = 15
        fileprivate let innerRadius: CGFloat = 8
        fileprivate let lineWidth: CGFloat = 2.5
        
        /// 线条颜色
        var color: UIColor = UIColor.white {
            didSet {
                self.displayIfNeeded()
            }
        }
        
        /// 线条梯度
        var alphaGradient: CGFloat = 0.0 {
            didSet {
                self.displayIfNeeded()
            }
        }
        
        override func draw(in ctx: CGContext) {
            ctx.setFillColor(UIColor.clear.cgColor)
            ctx.setLineWidth(lineWidth)
            ctx.setLineCap(CGLineCap.round)
            for i in 0..<12 {
                let x = cos(CGFloat.pi / 2.0 - CGFloat(i) * 30.0 * CGFloat.pi / 180.0)
                let y = sin(CGFloat.pi / 2.0 - CGFloat(i) * 30.0 * CGFloat.pi / 180.0)
                let from = CGPoint(x: outterRadius + x * outterRadius + lineWidth / 2.0, y: outterRadius - y * outterRadius + lineWidth / 2.0)
                let to = CGPoint(x: outterRadius + x * innerRadius + lineWidth / 2.0, y: outterRadius - y * innerRadius + lineWidth / 2.0)
                ctx.saveGState()
                ctx.setStrokeColor(color.withAlphaComponent(0.8 -  (12.0 - CGFloat(i)) * alphaGradient).cgColor)
                ctx.move(to: from)
                ctx.addLine(to: to)
                ctx.strokePath()
                ctx.restoreGState()
            }
        }
        
    }
    
}
