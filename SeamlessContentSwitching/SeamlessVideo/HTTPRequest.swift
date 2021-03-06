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
//  HTTPRequest.swift
//  SeamlessUI
//
//  Created by JT3 on 2021/06/24.
//

import Foundation

// Request for 1 url.
class HTTPRequest {
    enum LoadingState: Int {
        case none = 0, loading, completed
    }

    var url: URL
    var requestOffset: Int
    var requestLength: Int?
    var priority: Int
    var loader: HTTPFileLoader
    weak var delegate: HTTPLoaderDelegate?

    var state = LoadingState.none
    private var error: Error?
    private(set) var task: URLSessionDataTask?
    private var dataOffset = 0

    private var data = Data()
    private var downloadTick: UInt64 = 0

    init(url: URL, offset: Int, length: Int?, priority: Int, loader: HTTPFileLoader) {
        self.url = url
        requestOffset = offset
        requestLength = length
        self.priority = priority
        self.loader = loader
        
        dataOffset = requestOffset
    }
    
    // Return new range by subracting the overwrapped range from the previous request.
    // Return nil we don't need to download this request. (This request is part of previous request.)
    func calcDownloadRange(for offset: Int, length: Int?) -> (Int, Int?)? {
        var finalOffset = offset
        var finalLength = length
        
        if offset >= requestOffset {
            guard let originalLength = requestLength else { return nil }    // The previous request is for the remaining file, so we don't need to send this request.

            if offset < requestOffset + originalLength {
                finalOffset = requestOffset + originalLength
                if let newLength = length { // If the request is for some range of file.
                    if offset + newLength <= requestOffset + originalLength {
                        // This request is part of original request. No need to download again.
                        return nil
                    }
                    finalLength = offset + newLength - finalOffset
                } else { // If the request is for the remaining file.
                    finalLength = nil
                }
            } // else: No overwrapped range, so we need to request the range as it is.
        } else {    // We need to download from offset. Let's calculate the length of data we need to request.
            if requestLength == nil { // Previous request is for the remaining file. so we need to download (requestOffset - offset) bytes from offset.
                finalLength = requestOffset - offset
            }
            else if let originalLength = requestLength, let newLength = length, // If the later part of the new range is contained in the previous range, then we need to download only (requestOffset - offset) bytes.
               offset + newLength <= requestOffset + originalLength {
                finalLength = requestOffset - offset
            }
            // else: let's donwload the range as it is.
        }
        
        NSLog("[HTTPRequest] calcDownloadRange ReqRange[\(offset), \(length ?? -1)], PrevRange[\(requestOffset), \(requestLength ?? -1)], FinalRange[\(finalOffset), \(finalLength ?? -1)]")
        return (finalOffset, finalLength)
    }
    
    func load() {
        downloadTick = DispatchTime.now().uptimeNanoseconds
        NSLog("[HTTPRequest] load: url: \(url.lastPathComponent), offset: \(requestOffset), length: \(requestLength ?? -1)")
        state = .loading
        task = loader.prepareLoadingTask(url: url, offset: requestOffset, length: requestLength)
        loader.startLoading(using: task!)
    }

    func cancel() {
        if let dataTask = task {
            dataTask.cancel()
        } else {
            state = .completed
            error = NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: nil)
        }
    }
    
    func didReceive(response: URLResponse) {
        delegate?.didRecvResponse(url: url, response: response)
    }
    
    func didReceive(data: Data) {
        delegate?.didRecvData(url: url, data: data, offset: dataOffset)
        dataOffset += data.count
        
//        let elapsed = Double(DispatchTime.now().uptimeNanoseconds - downloadTick) / 1000000000
//        let bw = Int(Double(dataOffset) * 8 / elapsed)
//        NSLog("[HTTPRequest] didReceive: url: \(url.lastPathComponent), elapsed: \(elapsed.formatted), bw: \(bw)")
    }

    func didComplete(error: Error?) {
        state = .completed
        self.error = error
        delegate?.didComplete(url: url, error: error)
        
        let elapsed = Double(DispatchTime.now().uptimeNanoseconds - downloadTick) / 1000000000
        let bw = Double(dataOffset) * 8 / elapsed
        NSLog("[HTTPRequest] didComplete: url: \(url.lastPathComponent), elapsed: \(elapsed.formatted), bw: \(bw)")
    }
}

extension HTTPRequest: Hashable {
    static func == (lhs: HTTPRequest, rhs: HTTPRequest) -> Bool {
        lhs.url == rhs.url && lhs.requestOffset == rhs.requestOffset && lhs.requestLength == rhs.requestLength
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
        hasher.combine(requestOffset)
        if let length = requestLength {
            hasher.combine(length)
        }
    }
}
