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
//  ImageQueueProvider.swift
//  SeamlessUI
//
//  Created by ETHAN2 on 2021/06/15.
//

import Foundation

class ImageQueueProvider {
    private var backgroundIndex: Int = 0
    private let backgroundImages: [String] = {[
        "bg_home_01",
        "bg_home_02",
        "bg_home_03",
        "bg_home_04",
        "bg_home_05",
        "bg_home_06",
        "bg_home_07",
    ]}()
    
    private var backgroundUIImages = [UIImage]()
    
    init() {
        for image in backgroundImages {
            backgroundUIImages.append(UIImage(named: image)!)
        }
    }
    
    func image() -> UIImage {
        return backgroundUIImages[backgroundIndex]
    }
    
    func nextImage() -> UIImage {
        backgroundIndex += 1
        let index = backgroundIndex % 7
        let image = backgroundUIImages[index]
        
        if 0 < backgroundIndex, 0 == (backgroundIndex % 7) {
            backgroundIndex = 0
        }
                
        return image
    }
}
