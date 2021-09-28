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
//  C.swift
//  SeamlessUI
//
//  Created by ETHAN2 on 2021/06/30.
//

import UIKit

struct SeamlessUI {
    static let backgroundColor = UIColor(red: CGFloat(31.0/255),
                                         green: CGFloat(33.0/255),
                                         blue: CGFloat(38.0/255.0),
                                         alpha: 1)
}

extension SeamlessUI {
    struct Category {
        static let selectedColor = UIColor.hexStringToUIColor(hex: "#ff5b5b")
        static let defaultColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.05)
    }
}
