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
//  SequentialBackgroundView.swift
//  SeamlessUI
//
//  Created by ETHAN2 on 2021/06/15.
//

import UIKit

class SequentialBackgroundView: UIView {
    private let imageQueueProvider = ImageQueueProvider()
    
    private var backgroundView: UIImageView!
    private var reservedBackgroundView: UIImageView!
    
    private var animator: UIViewPropertyAnimator?
    private var backgroundPosOffset: CGFloat = 50
    private var backgroundFlowDuration: TimeInterval = 10
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        reservedBackgroundView = UIImageView(frame: frame)
        addSubview(reservedBackgroundView)
        sendSubviewToBack(reservedBackgroundView)
        
        backgroundView = UIImageView(frame: frame)
        addSubview(backgroundView)
        sendSubviewToBack(backgroundView)
        
        backgroundView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        reservedBackgroundView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        
        setBackgroundImages()
        setBackgroundAnimations(duration: backgroundFlowDuration)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        animator?.stopAnimation(true)
    }
    
    func setAnimatingState(_ animate: Bool) {
        
        if animate {
            setBackgroundAnimations(duration: backgroundFlowDuration)
        } else {
            animator?.stopAnimation(true)
            animator?.finishAnimation(at: .current)
        }
    }
        
    private func setBackgroundImages() {
        backgroundView.image = imageQueueProvider.image()
        reservedBackgroundView.image = imageQueueProvider.nextImage()
    }
    
    private func setBackgroundAnimations(duration speed: TimeInterval) {
        animator = UIViewPropertyAnimator(duration: speed, curve: .linear)
        reservedBackgroundView.alpha = 0.1
        
        animator?.addAnimations {
            self.backgroundView.center.x = self.center.x + self.backgroundPosOffset
            self.backgroundView.center.y = self.center.y + self.backgroundPosOffset
            self.backgroundView.alpha = 0.1
            
            self.reservedBackgroundView.center.x = self.center.x + self.backgroundPosOffset
            self.reservedBackgroundView.center.y = self.center.y + self.backgroundPosOffset
            self.reservedBackgroundView.alpha = 1
        }
                
        animator?.addCompletion { position in
            if position == .end {
                self.backgroundView.alpha = 1
                self.backgroundView.center.x = self.center.x + self.backgroundPosOffset
                self.backgroundView.center.y = self.center.y + self.backgroundPosOffset
                
                self.reservedBackgroundView.center.x = self.center.x + self.backgroundPosOffset
                self.reservedBackgroundView.center.y = self.center.y + self.backgroundPosOffset
                
                self.backgroundPosOffset *= -1
                
                self.setBackgroundImages()
                self.setBackgroundAnimations(duration: speed)
            }
        }
        
        animator?.startAnimation()
    }
}
