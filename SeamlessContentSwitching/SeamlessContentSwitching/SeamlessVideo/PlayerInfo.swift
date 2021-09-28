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
//  PlayerInfo.swift
//  SeamlessUI
//
//  Created by JT3 on 2021/08/03.
//

import AVFoundation

protocol PlayerDelegate: AnyObject {
    func didPlayToEndTime(playerInfo: PlayerInfo)
    func playbackLikelyToKeepUp(playerInfo: PlayerInfo)
}

class PlayerInfo: NSObject {
    var videoIndex: Int
    var isPlaying = false

    private var videoURL: URL
    private weak var resourceLoaderDelegate: AVAssetResourceLoaderDelegate?
    private weak var playerDelegate: PlayerDelegate?
    
    private var player: AVPlayer?
    
    private let observer = PlayerObserver()

    init(videoURL: URL, videoIndex: Int, resourceLoaderDelegate: AVAssetResourceLoaderDelegate?, playerDelegate: PlayerDelegate? = nil) {
        self.videoURL = videoURL
        self.videoIndex = videoIndex
        self.resourceLoaderDelegate = resourceLoaderDelegate
        self.playerDelegate = playerDelegate
        
        super.init()

        observer.playerDelegate = self
    }
    
    deinit {
        NSLog("PlayerInfo \(videoIndex) deinit")
        observer.stop()
    }
    
    func preparePlayer() -> AVPlayer {
        let asset = AVURLAsset(url: videoURL)
        if resourceLoaderDelegate != nil {
            asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: DispatchQueue.global(qos: .userInitiated))
        }
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        observer.start(player: player!, index: videoIndex)

        return player!
    }
    func getPlayer() -> AVPlayer? {
        return player
    }
    
    func play() {
        isPlaying = true

        player?.play()
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func replay() {
        isPlaying = true
        player?.seek(to: .zero) { [weak self] _ in
            self?.play()
        }
    }
    
    func stop() {
        player?.pause()
        player?.seek(to: .zero)
        
        isPlaying = false
    }
}

extension PlayerInfo: PlayerObserverDelegate {
    func didPlayToEndTime() {
        playerDelegate?.didPlayToEndTime(playerInfo: self)
    }
    func playbackLikelyToKeepUp() {
        playerDelegate?.playbackLikelyToKeepUp(playerInfo: self)
    }
}
