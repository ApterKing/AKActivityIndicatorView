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
            _indicatorLayer.highlightColor = color
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
    
    deinit {
        _displayLink.invalidate()
        _displayLink = nil
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
    private var _displayLink: CADisplayLink!
}

extension AKActivityIndicatorView {
    
    private func _initUI() {
        backgroundColor = UIColor.clear
        
        let outterRadius = _preIndicatorLayer.outterRadius
        let originCenter = center
        self.frame = CGRect(x: 0, y: 0, width: 2 * outterRadius, height: 2 * outterRadius)
        self.center = originCenter
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(arcCenter: CGPoint(x: outterRadius, y: outterRadius), radius: outterRadius, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi / 2 * 3, clockwise: true).cgPath
        maskLayer.lineWidth = outterRadius * 2
        maskLayer.strokeColor = UIColor.red.cgColor
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeEnd = 0.75
        layer.mask = maskLayer
        strokeEnd = 0.0

        _preIndicatorLayer.frame = bounds
        layer.addSublayer(_preIndicatorLayer)
        _preIndicatorLayer.setNeedsDisplay()
        
        _indicatorLayer.isHidden = true
        _indicatorLayer.frame = _preIndicatorLayer.frame
        _indicatorLayer.color = color.withAlphaComponent(0.5)
        _indicatorLayer.hightAlphaGradient = 0.1
        _indicatorLayer.highlightRange = 9..<12
        _indicatorLayer.highlightColor = color
        layer.insertSublayer(_indicatorLayer, below: _preIndicatorLayer)
        _indicatorLayer.setNeedsDisplay()
        
        _displayLink = CADisplayLink(target: self, selector: #selector(_redrawAction))
        _displayLink.add(to: RunLoop.current, forMode: .defaultRunLoopMode)
        _displayLink.preferredFramesPerSecond = 20
        _displayLink.isPaused = true
    }
    
    @objc func _redrawAction() {
        let range = _indicatorLayer.highlightRange
        _indicatorLayer.highlightRange = (range.lowerBound + 1)..<(range.upperBound + 1)
        _indicatorLayer.setNeedsDisplay()
    }
}

extension AKActivityIndicatorView {
    func startAnimation() {
        guard _isAnimating == false else { return }
        _isAnimating = true
        _preIndicatorLayer.isHidden = true
        _indicatorLayer.isHidden = false
        
        _displayLink.isPaused = false
    }
    
    func stopAnimation() {
        _displayLink.isPaused = true

        _preIndicatorLayer.isHidden = false
        _indicatorLayer.isHidden = true
        _indicatorLayer.highlightRange = 9..<12
        _indicatorLayer.setNeedsDisplay()
        _isAnimating = false
    }
}

extension AKActivityIndicatorView {

    class AKIndicatorLayer: CALayer {
        
        fileprivate let outterRadius: CGFloat = 14
        fileprivate let innerRadius: CGFloat = 7
        fileprivate let lineWidth: CGFloat = 2.5

        var highlightRange = 0..<0 {
            didSet{
                displayIfNeeded()
            }
        }
        var highlightColor = UIColor.white {
            didSet {
                displayIfNeeded()
            }
        }
        var hightAlphaGradient: CGFloat = 0.0 {
            didSet {
                displayIfNeeded()
            }
        }
        
        var color: UIColor = UIColor.white {
            didSet {
                displayIfNeeded()
            }
        }
        

        override func draw(in ctx: CGContext) {
            ctx.setFillColor(UIColor.clear.cgColor)
            ctx.setLineWidth(lineWidth)
            ctx.setLineCap(CGLineCap.round)
            for i in 0..<12 {
                let x = cos(CGFloat.pi / 2.0 - CGFloat(i) * 30.0 * CGFloat.pi / 180.0)
                let y = sin(CGFloat.pi / 2.0 - CGFloat(i) * 30.0 * CGFloat.pi / 180.0)
                
                let realOutterRadius = outterRadius - lineWidth / 2.0
                let from = CGPoint(x: realOutterRadius + x * realOutterRadius + lineWidth / 2.0, y: realOutterRadius - y * realOutterRadius + lineWidth / 2.0)
                let to = CGPoint(x: realOutterRadius + x * innerRadius + lineWidth / 2.0, y: realOutterRadius - y * innerRadius + lineWidth / 2.0)
                ctx.setAllowsAntialiasing(true)
                ctx.saveGState()
                var alphaColor = color
                for (index, highlight) in highlightRange.enumerated().reversed() {
                    if highlight % 12 == i {
                        alphaColor = highlightColor.withAlphaComponent(1 - CGFloat(index) * hightAlphaGradient)
                        break
                    }
                }
                ctx.setStrokeColor(alphaColor.cgColor)
                ctx.move(to: from)
                ctx.addLine(to: to)
                ctx.strokePath()
                ctx.closePath()
                ctx.restoreGState()
            }
        }
        
    }
    
}
