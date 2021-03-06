//
//  LineGraphView.swift
//  LineGraphView
//
//  Created by 土橋正晴 on 2019/07/18.
//  Copyright © 2019 m.dobashi. All rights reserved.
//

import Foundation
import UIKit

public class LineGraphView: UIView {

    /// 罫線に表示するラベルの非表示
    public var isHideRuledLineLabel: Bool = false
    public let scrollView: UIScrollView = UIScrollView()
    
    public let lineLayer:CAShapeLayer = CAShapeLayer()
    /// グラフに表示する値を格納する配列
    public var valueCount: [Int]?
    
    public var fromToValue: FromToValue?
    
    public var lineOptions: LineOptions?

    public var lineAnimationOptions: LineAnimationOptions?
    
    public var valueLabelOption: ValueLabelOption?
    /// グラフを表示するViewの高さ
    public var graphHeight: CGFloat = 0
    
    /// 棒グラフの横の余白
    public var horizontalMargin:CGFloat = 20
    
    /// 値を表示する
    public var valueLabel:UILabel {
        let label: UILabel = UILabel()
        label.backgroundColor = valueLabelOption?.labelBackgroundColor
        label.textColor = valueLabelOption?.labelTextColor
        label.font = valueLabelOption?.labelFont
        label.textAlignment = valueLabelOption!.labelTextAlignment
        label.isHidden = valueLabelOption!.isHideLabel
        
        return label
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    public convenience init(graphHeight height: CGFloat,
                            values: [Int],
                            fromToValue: FromToValue = .init(),
                            lineOptions: LineOptions = .init(),
                            lineAnimationOptions:LineAnimationOptions = .init(),
                            valueLabelOption: ValueLabelOption = .init()
                            ) {
        self.init()
        graphHeight = height
        valueCount = values
        self.fromToValue = fromToValue
        self.lineOptions = lineOptions
        self.lineAnimationOptions = lineAnimationOptions
        self.valueLabelOption = valueLabelOption
        
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// 棒グラフの描画
    /// isAnimeがtrueならアニメーションを流す
    /// falseなら描画のみ
    public func setLineGraph(){
        guard let _valueCount:[Int] = valueCount else {
            #if DEBUG
            print("valueCount is nil")
            #endif
            return
        }
        
        scrollView.contentSize.width = horizontalMargin * CGFloat(_valueCount.count + 1)
        scrollView.layer.addSublayer(lineLayer)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 15, y: graphHeight - positioningY(value: CGFloat(_valueCount[0]))))
        
        /* 一つ目の値を表示するラベルを生成 */
        let firstLabel: UILabel = {
            let label:UILabel = valueLabel
            label.frame = CGRect(x: 15, y: graphHeight - positioningY(value: CGFloat(_valueCount[0])), width: 0, height: 0)
            label.text = "\(_valueCount[0])"
            label.sizeToFit()
            
            return label
        }()
        scrollView.addSubview(firstLabel)
        
        for i in 1..<_valueCount.count {
            path.addLine(to: CGPoint(x: horizontalMargin * CGFloat(i + 1), y: graphHeight - positioningY(value: CGFloat(_valueCount[i]))))
            
            let label: UILabel = {
                let label:UILabel = valueLabel
                label.frame = CGRect(x: horizontalMargin * CGFloat(i + 1), y: graphHeight - positioningY(value: CGFloat(_valueCount[i])), width: 0, height: 0)
                label.text = "\(_valueCount[i])"
                label.sizeToFit()
                
                return label
            }()
            scrollView.addSubview(label)
        }
        
        lineLayer.path = path.cgPath
        lineLayer.lineWidth = lineOptions!.strokeWidth
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.strokeColor = lineOptions?.strokeColor.cgColor
        
        if lineAnimationOptions?.isAnime == true {
            let anime = lineAnimation()
            lineLayer.add(anime, forKey: nil)
            
        }
    }
    
    
    
    /// アニメーションの設定
    public func lineAnimation() -> CABasicAnimation {
        let anime = CABasicAnimation(keyPath:"strokeEnd")
        anime.fromValue = fromToValue?.fromValue
        anime.toValue = fromToValue?.toValue
        anime.timingFunction = lineAnimationOptions?.timingFunction
        anime.duration = lineAnimationOptions!.duration
        anime.fillMode = .forwards
        
        return anime
    }
    
    /// 罫線を作る
    ///
    /// - Parameter lineWidth: 罫線の長さ
    public func ruledLine(lineWidth: CGFloat){
        let ruledLineLayer:CAShapeLayer = CAShapeLayer()
        
        guard let _valueCount:[Int] = valueCount else {
            #if DEBUG
            print("valueCount is nil")
            #endif
            return
        }
        
        scrollView.contentSize.width = horizontalMargin * CGFloat(_valueCount.count + 1)
        layer.addSublayer(ruledLineLayer)
        
        let maxValue:Double = Double((_valueCount.max())!)
        var maxValues: [Int] = [Int]()
        for i in 1..<6 {
            maxValues.append(Int(maxValue * (0.2 * Double(i))))
            
        }
        maxValues.reverse()
        let path = UIBezierPath()
        let xPosition: CGFloat = isHideRuledLineLabel == false ? 25 : 0
        for i in 1..<5 {
            path.move(to: CGPoint(x: xPosition, y: graphHeight * (0.2 * CGFloat(i)) - 20))
            path.addLine(to: CGPoint(x: lineWidth, y: graphHeight * (0.2 * CGFloat(i)) - 20))
            
            let label: UILabel = {
                let label:UILabel = valueLabel
                label.frame = CGRect(x: 5, y: graphHeight * (0.2 * CGFloat(i)) - 20, width: 0, height: 0)
                label.text = "\(maxValues[i])"
                label.sizeToFit()
                label.isHidden = isHideRuledLineLabel
                
                return label
            }()
            self.addSubview(label)
        }
        
        ruledLineLayer.path = path.cgPath
        ruledLineLayer.lineWidth = 0.5
        ruledLineLayer.fillColor = UIColor.clear.cgColor
        ruledLineLayer.strokeColor = UIColor.black.cgColor
    }
    
    
    
    
    /// グラフの線のY軸を返す
    public func positioningY(value: CGFloat) -> CGFloat {
        /// valueCountの最大値を取得
        let maxValue:Int = (valueCount?.max())!
        let height:CGFloat = (graphHeight * (value / CGFloat(maxValue))) + 20
        if graphHeight >= height {
            return height
        } else {
            return graphHeight
        }
    }
    
    
    
    
    // MARK: struct
    
    
    public struct FromToValue {
        /// 初期位置
        public var fromValue: Any? = 0.0
        /// アニメーションの終了時の位置
        public var toValue: Any? = 1.0
        
        public init(fromValue: Any? = 0.0, toValue: Any? = 1.0) {
            self.fromValue = fromValue
            self.toValue = toValue
        }
    }
    
    
    
    public struct LineOptions {
        /// 線の太さ
        public var strokeWidth: CGFloat = 1
        /// 線の色
        public var strokeColor: UIColor = UIColor.black
        
        public init(strokeWidth: CGFloat = 1, strokeColor: UIColor = UIColor.black) {
            self.strokeWidth = strokeWidth
            self.strokeColor = strokeColor
        }
        
    }
    
    
    public struct LineAnimationOptions {
        /// アニメーションの表示の有無 デフォルト:true
        public var isAnime: Bool = true
        /// アニメーションの速度
        public var duration: CFTimeInterval = 1
        /// デフォルト:.linear
        public var timingFunction:CAMediaTimingFunction? = .init(name: .linear)
        
        public init(isAnime: Bool = true, duration: CFTimeInterval = 1, timingFunction:CAMediaTimingFunction? = .init(name: .linear)) {
            self.isAnime = isAnime
            self.duration = duration
            self.timingFunction = timingFunction
        }
    }
    
    
    
    public struct ValueLabelOption {
        public var labelBackgroundColor:UIColor = .white
        public var labelFont: UIFont?
        public var labelTextColor: UIColor = .black
        /// デフォルト:.right
        public var labelTextAlignment:NSTextAlignment = .right
        /// ラベルの非表示 デフォルト:false
        public var isHideLabel:Bool = false
        
        
        public init(labelFont: UIFont? = UIFont.systemFont(ofSize: 12), labelTextColor: UIColor = .black, labelBackgroundColor:UIColor = .white, isHideLabel:Bool = false) {
            self.labelTextColor = labelTextColor
            self.labelBackgroundColor = labelBackgroundColor
            self.isHideLabel = isHideLabel
            self.labelFont = labelFont
            
        }
    }
    
}
