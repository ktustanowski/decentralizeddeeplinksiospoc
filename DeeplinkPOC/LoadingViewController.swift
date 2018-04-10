//
//  LoadingViewController.swift
//  DeeplinkPOC
//
//  Created by Kamil Tustanowski on 04.04.2018.
//  Copyright © 2018 ktustanowski. All rights reserved.
//

import UIKit
import ReactiveSwift
import LinkHandler

extension LoadingViewController: LinkHandler {
    func process(link: Link, animated: Bool) -> LinkHandling {
        guard viewModel.isDataLoaded == true else { return .delayed(link, animated) }
        
        switch link.intent {
        default:
            navigateToHome(with: link)
            return .passedThrough(link)
        }
    }
}

class LoadingViewController: UIViewController {
    var linkHandling: LinkHandling?
    private let viewModel = LoadingViewModel()
    
    func navigateToHome(with link: Link? = nil) {
        performSegue(withIdentifier: "ToHome", sender: link)
    }
    
    override func viewDidLoad() {
        viewModel.loadData { [weak self] in
            // It we are deeplinking - this segue won't be presented to not break the flow
            // instead the deeplink process will move on
            self?.completeLinking(or: { self?.navigateToHome() })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as? UINavigationController
        let homeViewController = navigationController?.viewControllers.first as? HomeViewController
        homeViewController?.viewModel = viewModel.makeHomeViewModel()

        // Since we don't have view controller, we just start navigation, in process(link:)
        // we have to open link manually to maintain the deeplink chain
        homeViewController?.pass(link: sender as? Link, animated: true)
    }
}

class LoadingViewModel {
    var homeItems: [String]?
    var allItems: [String]?
    
    var isDataLoaded: Bool {
        return homeItems != nil && allItems != nil
    }
    
    func loadData(completion: (() -> Void)?) {
        dispatchAfter(0.5) { [weak self] in
            self?.allItems = [1, 2, 3, 4, 5, 6, 7, 8, 9].map { "Item \($0)" }
            self?.homeItems = [1, 2, 3, 4, 5].map { "Item \($0)" }
            completion?()
        }
    }
    
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(allItems: allItems ?? [],
                             items: homeItems ?? [])
    }
}
