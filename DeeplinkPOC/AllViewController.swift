//
//  AllViewController.swift
//  DeeplinkPOC
//
//  Created by Kamil Tustanowski on 04.04.2018.
//  Copyright © 2018 ktustanowski. All rights reserved.
//

import UIKit

struct AllViewModel {
    let items: [String]
    let promos: [String: [String]]
    let content: [String: [String]]
    
    func makePromoViewModel(with indexPath: IndexPath) -> PromoViewModel {
        return PromoViewModel(items: promos[items[indexPath.row]]!)
    }
    
    func makeContentViewModel(with indexPath: IndexPath) -> ContentViewModel {
        return ContentViewModel(items: content[items[indexPath.row]]!)
    }
}


class AllViewController: UITableViewController {
    var viewModel: AllViewModel?
}

extension AllViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.items.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllCell", for: indexPath)
        cell.textLabel?.text = viewModel?.items[indexPath.row]
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
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
