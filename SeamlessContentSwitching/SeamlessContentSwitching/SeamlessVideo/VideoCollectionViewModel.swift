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
//  VideoCollectionViewModel.swift
//  SeamlessUI
//
//  Created by JT3 on 2021/06/24.
//

import AVFoundation

class VideoCollectionViewModel {
    private var sources: [SeamlessDataInfo]
    private(set) var currentVideo: Int = -1
    private var videoLoader: VideoLoader
    private var playerManager: PlayerManager
    
    private let fakeURLScheme = "KM-"
    
    private let prefetchCount = 2
    private let preloadingSize = 1100*1024
    
    init(sources: [SeamlessDataInfo], start videoIndex: Int, videoCache: VideoCache? = nil) {
        self.sources = sources
        videoLoader = VideoLoader(urlSchemePrefix: fakeURLScheme, videoCache: videoCache)
        playerManager = PlayerManager(resourceLoaderDelegate: videoLoader, start: videoIndex)

        preparePlayer(videoIndex)
        setCurrentVideo(videoIndex)
    }

    var videoCount: Int {
        sources.count
    }
    
    func getDataInfo(_ videoIndex: Int) -> SeamlessDataInfo? {
        return sources[videoIndex]
    }
    
    @discardableResult
    func preparePlayer(_ videoIndex: Int) -> AVPlayer {
        NSLog("preparePlayer \(videoIndex)")
        let fakeURLString = fakeURLScheme + sources[videoIndex].videoURL.absoluteString
        let fakeURL = URL(string: fakeURLString) ?? sources[videoIndex].videoURL
        return playerManager.preparePlayer(for: fakeURL, videoIndex: videoIndex)
    }

    func doneUsingPlayer(_ videoIndex: Int) {
        NSLog("doneUsingPlayer \(videoIndex)")
        playerManager.doneUsingPlayer(videoIndex)
    }
    
    private func prepareLoad(for videoIndex: Int) {
        videoLoader.cancelLoading(except: sources[videoIndex].videoURL)
        videoLoader.load(url: sources[videoIndex].videoURL)
        
        // Set prefetch.
        preload()
    }
    
    func setCurrentVideo(_ videoIndex: Int) {
        NSLog("setCurrentVideo: new video \(videoIndex), current video \(currentVideo)")
        guard currentVideo != videoIndex else { return }
        
        currentVideo = videoIndex
        
        prepareLoad(for: videoIndex)
        playerManager.play(at: videoIndex)
    }
    
    func play() {
        playerManager.play()
    }
    
    func pause() {
        playerManager.pause()
    }
    
    private func preload() {
        for i in (1...prefetchCount) {
            if currentVideo + i < sources.count {
                NSLog("setCurrentVideo: preload for \(currentVideo + i), size: \(preloadingSize)")
                videoLoader.load(url: sources[currentVideo + i].videoURL, length: preloadingSize)
            }
            if currentVideo - i >= 0 {
                NSLog("setCurrentVideo: preload for \(currentVideo - i), size: \(preloadingSize)")
                videoLoader.load(url: sources[currentVideo - i].videoURL, length: preloadingSize)
            }
        }
    }
}
