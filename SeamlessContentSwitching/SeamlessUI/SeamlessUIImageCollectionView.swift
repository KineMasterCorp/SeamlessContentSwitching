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
//  SeamlessUIImageCollectionView.swift
//  SeamlessUI
//
//  Created by ETHAN2 on 2021/05/24.
//

import UIKit

class SeamlessUIImageCollectionView: UIView {
    public weak var seamlessInfoDelegate: SeamlessInfoDelegate?
        
    private var viewModel: SeamlessImageCollectionViewModel
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: WaterfallLayout())
        view.register(SeamlessUIImageCell.self, forCellWithReuseIdentifier: SeamlessUIImageCell.reuseIdentifier)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = SeamlessUI.backgroundColor
        
        return view
    }()
    
    init(viewModel: SeamlessImageCollectionViewModel, delegate: SeamlessInfoDelegate?) {
        self.viewModel = viewModel
        self.seamlessInfoDelegate = delegate
        
        super.init(frame: .zero)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.alwaysBounceVertical = true
        if let layout = collectionView.collectionViewLayout as? WaterfallLayout {
            layout.delegate = self
        }
        
        addSubview(collectionView)
        
        setupRefreshControl()
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        refreshControl.triggerVerticalOffset = 20
        refreshControl.addTarget(self, action: #selector(paginateMore), for: .valueChanged)
        refreshControl.tintColor = .systemPink
        self.collectionView.bottomRefreshControl = refreshControl
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),            
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    @objc func paginateMore() {
        seamlessInfoDelegate?.pullUpToRefresh()
    }
    
    func setContentOffsetToZero() {
        collectionView.setContentOffset(.zero, animated: false)
    }
    
    func reload(with viewModel: SeamlessImageCollectionViewModel) {
        self.viewModel = viewModel
        collectionView.reloadData()
    }
    
    func update(with updatedViewModel: SeamlessImageCollectionViewModel) {
        let lastInArray = viewModel.cellModels.count
        
        let newCells = updatedViewModel.cellModels.filter { newCell in
            !viewModel.cellModels.contains(where: { originCell in
                originCell.url == newCell.url
            })
        }
        
        viewModel.cellModels.append(contentsOf: newCells)
        
        let newLastInArray = viewModel.cellModels.count        
        let indexPaths = Array(lastInArray..<newLastInArray).map{IndexPath(item: $0, section: 0)}
        
        collectionView.insertItems(at: indexPaths)
        collectionView.bottomRefreshControl?.adjustBottomInset = true
        collectionView.bottomRefreshControl?.endRefreshing()
    }
}

protocol SeamlessInfoDelegate: AnyObject {
    func select(at index: Int) -> Void
    func pullUpToRefresh() -> Void
}

extension SeamlessUIImageCollectionView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cellCount
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        seamlessInfoDelegate?.select(at: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SeamlessUIImageCell.reuseIdentifier, for: indexPath)
        if viewModel.cellCount > indexPath.item, let seamlessCell = cell as? SeamlessUIImageCell {
            let cellModel = viewModel.cellModel(for: indexPath)
            seamlessCell.configure(with: cellModel)
        }
        
        return cell
    }
}

extension SeamlessUIImageCollectionView: WaterfallLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        return viewModel.cellModel(for: indexPath).height
    }
}
