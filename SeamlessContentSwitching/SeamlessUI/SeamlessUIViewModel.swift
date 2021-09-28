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
//  SeamlessUIViewModel.swift
//  SeamlessUI
//
//  Created by ETHAN2 on 2021/06/16.
//

import Foundation
import AVFoundation

class SeamlessUIViewModel {
    let defaultInitialCategoryIndex: Int = 0
    
    @BindableObject private(set) var headerViewModel: SeamlessHeaderViewModel
    @BindableObject private(set) var loadImageViewIfNeeded: Bool = false
    @BindableObject private(set) var updateImageViewIfNeeded: Bool = false
    
    private(set) var sources = [SeamlessDataInfo]()
    private(set) var latestFetchRequest: SeamlessDataRequest
    private(set) var categoryRequest: SeamlessDataRequest?
    private(set) var imageCollectionViewModel: SeamlessImageCollectionViewModel
    
    private var dummyDataFetcher = DummySeamlessDataFetcher()
    private var isLoading: Bool = false
    
    init (fetchRequest: SeamlessDataRequest = .init(target: "전체", type: .category)) {
        self.latestFetchRequest = fetchRequest
        
        if fetchRequest.type == .category { categoryRequest = fetchRequest }
        
        headerViewModel = SeamlessHeaderViewModel(cellModels: [CategoryCellModel]())
        imageCollectionViewModel = SeamlessImageCollectionViewModel(cellModels: [SeamlessImageCellModel]())
    }
    
    private func updateCategoryViewModel() {
        let categories = sources.map { video in video.category }.uniqued()
        let headerCategories = headerViewModel.cellModels.map { cellModel in cellModel.category }
        
        let newCategories = categories.filter { !headerCategories.contains($0) }.map {
            CategoryCellModel(category: $0)
        }
        
        if !newCategories.isEmpty {
            headerViewModel.cellModels.append(contentsOf: newCategories)
        }        
    }
    
    private func updateImageViewModel(sources: [SeamlessDataInfo]) {
        imageCollectionViewModel = SeamlessImageCollectionViewModel(cellModels: sources.map {
            SeamlessImageCellModel(title: $0.title, url: $0.poster)
        })
    }
    
    internal func fetch(with request: SeamlessDataRequest) {
        latestFetchRequest = request
        
        sources = DummySeamlessDataFetcher.fetch(with: latestFetchRequest)
        
        updateImageViewModel(sources: sources)
        loadImageViewIfNeeded.signal()
        
        if latestFetchRequest.type == .category, headerViewModel.selectedCategory != latestFetchRequest.target {
            headerViewModel.selectedCategory = latestFetchRequest.target
            
            updateCategoryViewModel()
            
            categoryRequest = request
        }
    }
       
    internal func fetchNext() {
        if !self.isLoading {
            self.isLoading = true
            DispatchQueue.global(qos: .userInteractive).async {
                let appendVideos = DummySeamlessDataFetcher.fetch(with: self.latestFetchRequest, fetchNext: true).filter {
                    !self.sources.contains($0)
                }

                if 0 < appendVideos.count {
                    self.sources.append(contentsOf: appendVideos)
                    
                    self.updateImageViewModel(sources: self.sources)
                    self.updateCategoryViewModel()
                }
                
                self.isLoading = false
                self.updateImageViewIfNeeded.signal()
            }
        }
    }
}
