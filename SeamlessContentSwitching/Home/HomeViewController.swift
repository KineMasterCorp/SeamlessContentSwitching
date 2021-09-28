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
//  InitialViewController.swift
//  SeamlessUI
//
//  Created by ETHAN2 on 2021/05/28.
//

import UIKit

class HomeViewController: UIViewController {
    
    private lazy var sequentialBackgroundView: SequentialBackgroundView = {
        let view = SequentialBackgroundView(frame: view.frame)
        return view
    }()
    
    private lazy var seamlessButton: GradientButton = {
        let button = GradientButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "icSeamless")
        button.setImage(image, for: .normal)
        button.addTarget(target, action: #selector(self.seamlessButtonTapped), for: .touchUpInside)
        button.setTitle("프로젝트 받기", for: .normal)
        return button
    } ()
    
    public var interactor: HomeInteractor?
    
    override func viewDidLoad() {
        setupSubviews()
    }
    
    private func setupSubviews() {
        view.addSubview(sequentialBackgroundView)
        view.addSubview(seamlessButton)
        
        NSLayoutConstraint.activate([
            seamlessButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            seamlessButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            seamlessButton.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    @objc private func seamlessButtonTapped() {
        interactor?.dispatch(.seamless)
    }
    
    func update(with state: Home.ViewState) {
        sequentialBackgroundView.setAnimatingState(state.animateBackground)
    }
}
