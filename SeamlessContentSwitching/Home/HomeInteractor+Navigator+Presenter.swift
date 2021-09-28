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
//  HomeInteractor+Navigator+Presenter.swift
//  SeamlessUI
//
//  Created by ETHAN2 on 2021/06/15.
//

import Foundation

public protocol HomeInteractor: AnyObject {
    func dispatch(_ action: Home.Action)
}

class HomeInteractorImpl: HomeInteractor {
    let navigator: HomeNavigator
    private let presenter: HomePresenter
    
    init(presenter: HomePresenter, navigator: HomeNavigator) {
        self.presenter = presenter
        self.navigator = navigator
        
        self.navigator.onEvent = { [weak self] event in
            self?.handleSceneEvent(event)
        }
    }
    
    func dispatch(_ action: Home.Action) {
        presenter.present(action: action)
        
        switch action {
        case .seamless:
            navigator.present(.projectSeamless)
        case .dismissModal:
            navigator.dismiss()
        }
    }
    
    private func handleSceneEvent(_ event: Home.SceneEvent) {
        switch event {
        case .didDismissProjectSeamless:
            self.dispatch(.dismissModal)
        }
    }
}

class HomePresenter: NSObject {
    weak var view: HomeViewController?
    private var viewState: Home.ViewState = .init()
    
    init(view: HomeViewController) {
        self.view = view
        super.init()
    }
    
    public func present(action: Home.Action) {
        switch action {
        case .seamless:
            viewState.animateBackground = false
        case .dismissModal:
            viewState.animateBackground = true
        }
        
        view?.update(with: viewState)
    }
}

enum HomeNavigatorDestination {
    case projectSeamless
}

protocol HomeNavigator: AnyObject {
    func present(_ destination: HomeNavigatorDestination)
    func dismiss()
    
    typealias OnEvent = (Home.SceneEvent) -> Void
    var onEvent: OnEvent? { get set }
}

public struct Home {
    public enum Action {
        case seamless
        case dismissModal
    }
    
    public struct ViewState {
        public var animateBackground: Bool
        
        init(animateBackground: Bool = true) {
            self.animateBackground = animateBackground
        }
    }
    
    enum SceneEvent {
        case didDismissProjectSeamless
    }
}

public class HomeNavigatorImpl: HomeNavigator {
    var onEvent: OnEvent?
    
    weak private(set) var viewController: HomeViewController?
    
    init(viewController: HomeViewController) {
        self.viewController = viewController
    }
    
    func present(_ destination: HomeNavigatorDestination) {
        switch destination {
        case .projectSeamless:
            presentProjectSeamless()
        }
    }
    
    func dismiss() {
        viewController?.dismiss(animated: true)
    }
    
    func presentProjectSeamless() {
        if let controller = viewController {
            
            let modalView = UINavigationController(rootViewController: SeamlessUIController(viewModel: SeamlessUIViewModel(), onDismiss: {
                self.onEvent?(.didDismissProjectSeamless)
            }))
            
            modalView.modalPresentationStyle = .fullScreen
            controller.present(modalView, animated: true)            
        }
    }
}
