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
//  SeamlessInteractor+Navigator+Presenter.swift
//  SeamlessUI
//
//  Created by ETHAN2 on 2021/08/10.
//

import Foundation

public protocol SeamlessInteractor: AnyObject {
    func dispatch(_ action: Seamless.Action)
}

class SeamlessInteractorImpl: SeamlessInteractor {
    let navigator: SeamlessNavigator
    private let presenter: SeamlessPresenter
    
    init(presenter: SeamlessPresenter, navigator: SeamlessNavigator) {
        self.presenter = presenter
        self.navigator = navigator
        
        self.navigator.onEvent = { [weak self] event in
            self?.handleSceneEvent(event)
        }
    }
    
    func dispatch(_ action: Seamless.Action) {
        presenter.present(action: action)
        
        switch action {
        case .touchTag(let tag, let wordType):
            navigator.present(.projectSeamless(tag: tag, wordType: wordType))
        case .dismissModal:
            navigator.dismiss()
        case .viewWillAppear:
            break
        case .viewDidAppear:
            break
        case .viewDidDisappear:
            break
        case .applicationDidBecomeActive:
            break
        case .applicationDidEnterBackground:
            break
        }
    }
    
    private func handleSceneEvent(_ event: Seamless.SceneEvent) {
        switch event {
        case .didDismissProjectSeamless:
            self.dispatch(.dismissModal)
        }
    }
}

class SeamlessPresenter: NSObject {
    weak var view: SeamlessViewController?
    private var viewState: Seamless.ViewState = .init()
    
    init(view: SeamlessViewController) {
        self.view = view
        super.init()
    }
    
    public func present(action: Seamless.Action) {
        var updated: Bool = false
        switch action {
        case .touchTag:
            viewState.play = false
            viewState.modalPresented = true
            updated = true
        case .dismissModal:
            break
        case .viewWillAppear:
            viewState.play = true
            viewState.modalPresented = false
            updated = true
        case .viewDidAppear:
            break
        case .viewDidDisappear:
            break
        case .applicationDidBecomeActive:
            if !viewState.modalPresented {
                viewState.play = true
                updated = true
            }            
        case .applicationDidEnterBackground:
            if !viewState.modalPresented, viewState.play {
                viewState.play = false
                updated = true
            }
        }
        
        if updated {
            view?.update(with: viewState)
        }        
    }
}

enum SeamlessNavigatorDestination {
    case projectSeamless(tag: String, wordType: wordType)
}

protocol SeamlessNavigator: AnyObject {
    func present(_ destination: SeamlessNavigatorDestination)
    func dismiss()
    
    typealias OnEvent = (Seamless.SceneEvent) -> Void
    var onEvent: OnEvent? { get set }
}

public struct Seamless {
    public enum Action {
        case viewWillAppear
        case viewDidAppear
        case viewDidDisappear
        case applicationDidBecomeActive
        case applicationDidEnterBackground
        
        case touchTag(tag: String, wordType: wordType)
        case dismissModal
    }
    
    public struct ViewState {
        public var play: Bool
        public var modalPresented: Bool
        
        init(play: Bool = true, modalPresented: Bool = false) {
            self.play = play
            self.modalPresented = modalPresented
        }
    }
    
    enum SceneEvent {
        case didDismissProjectSeamless
    }
}

public class SeamlessNavigatorImpl: SeamlessNavigator {
    var onEvent: OnEvent?
    
    weak private(set) var viewController: SeamlessViewController?
    
    init(viewController: SeamlessViewController) {
        self.viewController = viewController
    }
    
    func present(_ destination: SeamlessNavigatorDestination) {
        switch destination {
        case .projectSeamless(let tag, let wordType):
            presentProjectSeamless(tag: tag, wordType: wordType)
        }
    }
    
    func dismiss() {
        viewController?.dismiss(animated: true)
    }
    
    func presentProjectSeamless(tag: String, wordType: wordType) {
        if let controller = viewController {
            let modalView = SeamlessUIController(viewModel: SeamlessUIViewModel(fetchRequest: SeamlessDataRequest(target: tag, type: .tag)), onDismiss: { self.onEvent?(.didDismissProjectSeamless) }
            )
                        
            modalView.modalPresentationStyle = .fullScreen            
            controller.navigationController?.pushViewController(modalView, animated: true)
        }
    }
}

