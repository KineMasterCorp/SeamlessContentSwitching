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
//  SeamlessUICategoryCell.swift
//  SeamlessUI
//
//  Created by ETHAN2 on 2021/06/09.
//

import UIKit

final class SeamlessUICategoryCell: UICollectionViewCell {
    public static let reuseIdentifier = "SeamlessUICategoryCell"
    
    static func fittingSize(name: String?) -> CGSize {
        let cell = SeamlessUICategoryCell()
        cell.configure(name: name)
        
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.text = name
        label.sizeToFit()
        
        let size = label.frame.size
        
        return CGSize(width: size.width + 40, height: size.height + 16)
    }
        
    var categoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .white
        return label
    } ()
    
    private var layoutConstraints: [NSLayoutConstraint]
    
    override init(frame: CGRect) {
        layoutConstraints = .init()
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    private func setupView() {
        backgroundColor = .init(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.05)
        
        addSubview(categoryLabel)
        
        layoutConstraints.append(
            contentsOf: [categoryLabel.topAnchor.constraint(equalTo: topAnchor),
                         categoryLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                         categoryLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                         categoryLabel.bottomAnchor.constraint(equalTo: bottomAnchor)])
        
        NSLayoutConstraint.activate(layoutConstraints)
    }
    
    func configure(name: String?) {
        categoryLabel.text = name
    }
}
