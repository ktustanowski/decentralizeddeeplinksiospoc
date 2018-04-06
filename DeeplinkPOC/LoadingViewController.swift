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

class LoadingViewModel {
    var homeItems: [String]?
    var allItems: [String]?
    
    var isDataLoaded: Bool {
        return homeItems != nil && allItems != nil
    }
    
    func loadData(completion: (() -> Void)?) {
        dispatchAfter(0.0) { [weak self] in
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

class LoadingViewController: UIViewController {
    var linkHandling: LinkHandling?
    private let viewModel = LoadingViewModel()
    
    override func viewDidLoad() {
        viewModel.loadData { [weak self] in
            self?.completeLinking(or: {
                self?.performSegue(withIdentifier: "ToHome", sender: nil)
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as? UINavigationController
        let homeViewController = navigationController?.viewControllers.first as? HomeViewController
        homeViewController?.viewModel = viewModel.makeHomeViewModel()
        if let link = sender as? Link {
            homeViewController?.open(link: link, animated: true)
        }
    }
    
    deinit {
        print("DEINITED LOADING VC!")
    }
}

extension LoadingViewController: LinkHandler {
    func process(link: Link, animated: Bool) -> LinkHandling {
        // if view is not loaded yet we should probably wait for it
        guard viewModel.isDataLoaded == true else { return .delayed(link, animated) }
        
        switch link.intent {
        default:
            performSegue(withIdentifier: "ToHome", sender: link)
            return .passedThrough(link)
        }
    }
}
