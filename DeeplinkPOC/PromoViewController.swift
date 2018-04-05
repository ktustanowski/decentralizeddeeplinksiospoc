//
//  PromoViewController.swift
//  DeeplinkPOC
//
//  Created by Kamil Tustanowski on 04.04.2018.
//  Copyright © 2018 ktustanowski. All rights reserved.
//

import UIKit

struct PromoViewModel {
    let items: [String]
}

class PromoViewController: UITableViewController {
    var viewModel: PromoViewModel?
}

extension PromoViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.items.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PromoCell", for: indexPath)
        cell.textLabel?.text = viewModel?.items[indexPath.row]
        
        return cell
    }
}
