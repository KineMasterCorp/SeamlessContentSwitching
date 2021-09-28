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
//  SeamlessDataInfo.swift
//  SeamlessSwitching
//
//  Created by JT3 on 2021/05/28.
//

import AVFoundation

class DummySeamlessDataFetcher {
    static func fetch(with request: SeamlessDataRequest, fetchNext: Bool = false) -> [SeamlessDataInfo] {
        DummySeamlessDataSource.fetch(with: request, fetchNext: fetchNext)
    }
}

class DummySeamlessDataSource {
    static private let FETCH_NUMS_AT_TIME = 15
    
    static private var sources = DummySeamlessDataSource.allSources()
    static private var fetchNumHistory: [String:Int] = .init()
    
    static func fetch(with request: SeamlessDataRequest, fetchNext: Bool) -> [SeamlessDataInfo] {
        let from = fetchNext ? fetchNumHistory[request.target] ?? 0 : 0
        let limit = from + FETCH_NUMS_AT_TIME
        var filteredSources = [SeamlessDataInfo]()
        
        switch request.type {
        case .category:
            filteredSources.append(contentsOf: sources.filter {
                request.target == "전체" || $0.category == request.target
            }[safe: from..<limit])
        case .tag:
            filteredSources.append(contentsOf: sources.filter {
                $0.tags.contains(request.target)
            }[safe: from..<limit])
        }
        
        fetchNumHistory[request.target] = from + filteredSources.count
        
        NSLog("fetched from: \(from) until \(from + filteredSources.count), fetchNext: \(fetchNext)")
        
        return filteredSources
    }
        
    // You can put your contents here.
    static func allSources() -> [SeamlessDataInfo] {
        return [
            SeamlessDataInfo(title: "화려한 댄스 타임", tags: ["인스타그램", "틱톡"], videoURL: URL(string:"https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!,
                          poster: "https://storage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg",
                          category: "예능"),
            SeamlessDataInfo(title: "다이나믹 오프너 인트로", tags: ["유튜브", "다이나믹", "오프너"], videoURL: URL(string:"https://storage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!,
                          poster: "https://storage.googleapis.com/gtv-videos-bucket/sample/images/ElephantsDream.jpg",
                          category: "인트로"),
            SeamlessDataInfo(title: "나의 데일리 브이로그", tags: ["유튜브", "데일리", "브이로그"], videoURL: URL(string:"https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!,
                          poster: "https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerBlazes.jpg",
                          category: "브이로그"),
            SeamlessDataInfo(title: "파이어 타이틀 인트로", tags: ["유튜브", "파이어", "인트로", "불"], videoURL: URL(string:"https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4")!,
                          poster: "https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerEscapes.jpg",
                          category: "인트로"),
            SeamlessDataInfo(title: "폭발 텍스트 인트로", tags: ["폭발", "인트로", "유튜브"], videoURL: URL(string:"https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!,
                          poster: "https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerFun.jpg",
                          category: "인트로"),
            SeamlessDataInfo(title: "베스트 포토", tags: ["인스타그램", "릴스", "포토"], videoURL: URL(string:"https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4")!,
                          poster: "https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerJoyrides.jpg",
                          category: "비트"),
            SeamlessDataInfo(title: "시네마틱 필름", tags: ["유튜브", "인트로", "브이로그"], videoURL: URL(string:"https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4")!,
                          poster: "https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerMeltdowns.jpg",
                          category: "브이로그"),
            SeamlessDataInfo(title: "구독 인트로", tags: ["유튜브", "구독", "인트로"], videoURL: URL(string:"https://storage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4")!,
                          poster: "https://storage.googleapis.com/gtv-videos-bucket/sample/images/Sintel.jpg",
                          category: "인트로"),
            SeamlessDataInfo(title: "시간 여행", tags: ["인스타그램", "릴스", "여행", "시간"], videoURL: URL(string:"https://storage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4")!,
                          poster: "https://storage.googleapis.com/gtv-videos-bucket/sample/images/SubaruOutbackOnStreetAndDirt.jpg",
                          category: "비트"),
            SeamlessDataInfo(title: "오늘의 점심 메뉴는?", tags: ["인스타그램", "점심", "메뉴"], videoURL: URL(string:"https://storage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4")!,
                          poster: "https://storage.googleapis.com/gtv-videos-bucket/sample/images/TearsOfSteel.jpg",
                          category: "예능"),
        ]
    }
}
