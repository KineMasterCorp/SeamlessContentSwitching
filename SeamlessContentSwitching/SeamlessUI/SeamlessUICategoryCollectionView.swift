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
//  SeamlessUICategoryCollectionView.swift
//  SeamlessUI
//
//  Created by ETHAN2 on 2021/06/16.
//

import UIKit

class SeamlessUICategoryCollectionView: UIView {
    private var cellModels: [CategoryCellModel]
    private weak var delegate: SeamlessUICategoryDelegate?
    private var selectedIndex: Int = -1
    
    private lazy var categoryLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: categoryLayout)
        view.register(SeamlessUICategoryCell.self, forCellWithReuseIdentifier: SeamlessUICategoryCell.reuseIdentifier)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = SeamlessUI.backgroundColor
        return view
    }()
    
    init(cellModels: [CategoryCellModel], delegate: SeamlessUICategoryDelegate?) {
        self.cellModels = cellModels
        self.delegate = delegate
        
        super.init(frame: .zero)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        
        selectedIndex = self.delegate?.initialSelectedIndex() ?? 0
        
        addSubview(collectionView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
                
        let safeLayoutGuide = safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
    
    private var selectedCell: SeamlessUICategoryCell? {
        didSet {
            if let cell = oldValue, cell != selectedCell {
                cell.backgroundColor = SeamlessUI.Category.defaultColor
                cell.categoryLabel.textColor = .white
                cell.categoryLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            }
        }
        
        willSet {
            if let cell = newValue, cell != selectedCell {
                cell.backgroundColor = SeamlessUI.Category.selectedColor
                cell.categoryLabel.textColor = .black
                cell.categoryLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
                delegate?.select(category: cellModels[selectedIndex].category)
            }
        }
    }
    public func update(with updatedViewModels: [CategoryCellModel]) {
        let lastInArray = self.cellModels.count
        let newItems = updatedViewModels.filter { !self.cellModels.contains($0) }
        self.cellModels.append(contentsOf: newItems)
        let newLastInArray = self.cellModels.count
        
        let indexPaths = Array(lastInArray..<newLastInArray).map{IndexPath(item: $0, section: 0)}
        
        self.collectionView.insertItems(at: indexPaths)
    }
}

extension SeamlessUICategoryCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SeamlessUICategoryCell.reuseIdentifier, for: indexPath) as! SeamlessUICategoryCell
        cell.configure(name: cellModels[indexPath.item].category)
        
        if selectedCell == nil, indexPath.item == selectedIndex {
            selectedCell = cell
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        selectedCell = collectionView.cellForItem(at:indexPath) as? SeamlessUICategoryCell
    }
}

extension SeamlessUICategoryCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return SeamlessUICategoryCell.fittingSize(name: cellModels[indexPath.item].category)
    }
}
