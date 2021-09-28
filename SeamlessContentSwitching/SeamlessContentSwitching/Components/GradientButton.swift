//  MIT License
//
//  Copyright © 2021 Kinemaster corp.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// 
//
//
//  GradientButton.swift
//  SeamlessUI
//
//  Created by ETHAN2 on 2021/06/15.
//

import UIKit

class GradientButton: UIButton {
    public class var color1: UIColor {
        return UIColor(red: 88 / 255, green: 222 / 255, blue: 252 / 255, alpha: 1.0)
    }
    
    public class var color2: UIColor {
        return UIColor(red: 92 / 255, green: 130 / 255, blue: 253 / 255, alpha: 1.0)
    }
    
    public class var color3: UIColor {
        return UIColor(red: 118 / 255, green: 51 / 255, blue: 253 / 255, alpha: 1.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        self.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        setInsets(forContentPadding: .init(top: 0, left: 25, bottom: 0, right: 25), imageTitlePadding: 10)
    }
    
    private lazy var gradientLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.frame = self.bounds
        l.colors = [GradientButton.color1.cgColor,
                    GradientButton.color2.cgColor,
                    GradientButton.color3.cgColor]
        l.startPoint = CGPoint(x: 0, y: 0.5)
        l.endPoint = CGPoint(x: 1, y: 0.5)
        l.cornerRadius = 10
        layer.insertSublayer(l, at: 0)
        return l
    }()
}
