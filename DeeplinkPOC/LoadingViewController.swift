//
//  LoadingViewController.swift
//  DeeplinkPOC
//
//  Created by Kamil Tustanowski on 04.04.2018.
//  Copyright © 2018 ktustanowski. All rights reserved.
//

import UIKit
import ReactiveSwift

struct LoadingViewModel {
    func loadData(completion: (() -> Void)?) {
        dispatchAfter(0.0) {
            completion?()
        }
    }
    
    func makeHomeViewModel() -> HomeViewModel {
        let all = [1, 2, 3, 4, 5, 6, 7, 8, 9].map { "Item \($0)" }
        let home = [1, 2, 3, 4, 5].map { "Item \($0)" }
        
        var allContent = [String: [String]]()
        var allPromos = [String: [String]]()

        all.forEach { item in
            allContent[item] = [1, 2, 3, 4, 5, 6, 7, 8, 9].map { "\(item) Content \($0)" }
            allPromos[item] = [1, 2, 3, 4, 5, 6, 7, 8, 9].map { "\(item) Promos \($0)" }
        }
        
        return HomeViewModel(allItems: all,
                             items: home,
                             promos: allPromos,
                             content: allContent)
    }
}

class LoadingViewController: UIViewController {
    
    private let viewModel = LoadingViewModel()
    
    override func viewDidLoad() {
        viewModel.loadData { [weak self] in
            self?.performSegue(withIdentifier: "ToHome", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as? UINavigationController
        let homeViewController = navigationController?.viewControllers.first as? HomeViewController
        homeViewController?.viewModel = viewModel.makeHomeViewModel()
    }
}
