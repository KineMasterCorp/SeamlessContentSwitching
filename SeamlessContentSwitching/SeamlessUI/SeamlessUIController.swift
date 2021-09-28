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
//  SeamlessUIController.swift
//  SeamlessUI
//
//  Created by ETHAN2 on 2021/05/26.
//

import UIKit

class SeamlessUIController: UIViewController {
    private var layoutConstraints: [NSLayoutConstraint] = .init()
    
    private var viewModel: SeamlessUIViewModel
    private var videoCache = VideoCache(capacity: 20)
    
    public var onDismiss: (() -> Void)?
    
    init(viewModel: SeamlessUIViewModel, onDismiss: (() -> Void)?) {
        self.viewModel = viewModel
        self.onDismiss = onDismiss
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var headerView: SeamlessUIHeaderStackView = {
        let view = SeamlessUIHeaderStackView(viewModel: viewModel.headerViewModel, delegate: self)
        view.translatesAutoresizingMaskIntoConstraints = false        
        return view
    } ()
    
    private lazy var imageCollectionView: SeamlessUIImageCollectionView = {
        let view = SeamlessUIImageCollectionView(viewModel: viewModel.imageCollectionViewModel, delegate: self)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleView: UILabel = {
        let title = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 52))
        title.textColor = .white
        title.textAlignment = .center
        title.text = "#" + viewModel.latestFetchRequest.target
        title.font = UIFont.systemFont(ofSize: 17)
        return title
    } ()
    
    func setupViews() {
        view.addSubview(imageCollectionView)
        view.backgroundColor = SeamlessUI.backgroundColor
        
        let safeLayoutGuide = view.safeAreaLayoutGuide
        var collectionViewTopAnchor = safeLayoutGuide.topAnchor
        
        if viewModel.latestFetchRequest.type == .category {
            view.addSubview(headerView)
            
            layoutConstraints.append(
                contentsOf: [headerView.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor),
                             headerView.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor),
                             headerView.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor),
                             headerView.heightAnchor.constraint(equalToConstant: 52)])
            
            collectionViewTopAnchor = headerView.bottomAnchor
        }
        
        layoutConstraints.append(
            contentsOf: [imageCollectionView.topAnchor.constraint(equalTo: collectionViewTopAnchor),
                         imageCollectionView.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor),
                         imageCollectionView.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor),
                         imageCollectionView.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor)])
        
        NSLayoutConstraint.activate(layoutConstraints)
    }
    
    func setupNavigationBar() {
        navigationItem.titleView = titleView
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.topItem?.title = ""
    }
    
    func setupBinder() {
        viewModel.$loadImageViewIfNeeded.bind = { [weak self] _ in
            guard let self = self else { return }
            self.imageCollectionView.reload(with: self.viewModel.imageCollectionViewModel)
        }
        
        viewModel.$updateImageViewIfNeeded.bind = { [weak self] _ in
            guard let self = self else { return }
            self.imageCollectionView.update(with: self.viewModel.imageCollectionViewModel)
        }
        
        viewModel.$headerViewModel.bind = { [weak self] headerViewModel in
            self?.headerView.update(with: headerViewModel)
        }
        
        viewModel.headerViewModel.$selectedCategory.bind = { [weak self] _ in
            guard let self = self else { return }
            self.imageCollectionView.setContentOffsetToZero()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupViews()
        setupBinder()
        setupNavigationBar()
        
        if viewModel.latestFetchRequest.type == .tag {
            viewModel.fetch(with: viewModel.latestFetchRequest)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if nil != viewModel.categoryRequest {
            navigationController?.isNavigationBarHidden = true
        }
    }
}

extension SeamlessUIController: SeamlessUIHeaderStackViewDelegate {
    func initialSelectedIndex() -> Int {
        viewModel.defaultInitialCategoryIndex
    }
    
    func select(category: String) -> Void {
        viewModel.fetch(with: SeamlessDataRequest(target: category, type: .category))
    }
    
    func search(with text: String) -> Void {
        viewModel.fetch(with: SeamlessDataRequest(target: text, type: .tag))
    }
    
    func closeButtonTapped() {
        onDismiss?()
    }
    
    func searchButtonTapped() {
        viewModel.fetch(with: SeamlessDataRequest(target: "", type: .tag))
    }
    
    func searchCancelButtonTapped() {
        viewModel.fetch(with: viewModel.categoryRequest!)
    }
}

extension SeamlessUIController: SeamlessInfoDelegate {
    func pullUpToRefresh() {
        viewModel.fetchNext()
    }
    
    func select(at index: Int) -> Void {
        guard viewModel.sources.indices.contains(index) else {
            NSLog("SeamlessInfoDelegate.select: invalid index! \(index). video count: \(viewModel.sources.count)")
            return
        }
        
        let controller = SeamlessViewController(videoManager: VideoCollectionViewModel(sources: viewModel.sources, start: index, videoCache: videoCache))
        
        let interactor = SeamlessInteractorImpl(presenter: SeamlessPresenter(view: controller),
                                            navigator: SeamlessNavigatorImpl(viewController: controller))
        controller.interactor = interactor
                
        navigationController?.pushViewController(controller, animated: true)
    }
}
