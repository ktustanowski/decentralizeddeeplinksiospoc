//
//  HomeViewController.swift
//  DeeplinkPOC
//
//  Created by Kamil Tustanowski on 30.03.2018.
//  Copyright © 2018 ktustanowski. All rights reserved.
//

import UIKit


struct HomeViewModel {
    let allItems: [String]
    let items: [String]
    let promos: [String: [String]]
    let content: [String: [String]]
    
    func makeAllViewModel() -> AllViewModel {
        return AllViewModel(items: allItems,
                            promos: promos,
                            content: content)
    }
    
    func makePromoViewModel(with indexPath: IndexPath) -> PromoViewModel {
        return PromoViewModel(items: promos[items[indexPath.row]]!)
    }

    func makeContentViewModel(with indexPath: IndexPath) -> ContentViewModel {
        return ContentViewModel(items: content[items[indexPath.row]]!)
    }
}

class HomeViewController: UITableViewController {

    var viewModel: HomeViewModel?
}

extension HomeViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.items.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath)
        cell.textLabel?.text = viewModel?.items[indexPath.row]
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "ToAll":
            let allViewController = segue.destination as? AllViewController
            allViewController?.viewModel = viewModel?.makeAllViewModel()
        case "ToPromo":
            let promoViewController = segue.destination as? PromoViewController
            promoViewController?.viewModel = viewModel?.makePromoViewModel(with: tableView.indexPath(for: sender as! UITableViewCell)!)
        case "ToContent":
            let contentViewController = segue.destination as? ContentViewController
            contentViewController?.viewModel = viewModel?.makeContentViewModel(with: tableView.indexPath(for: sender as! UITableViewCell)!)
        default:
            print("Ooops!")
        }
    }
}
