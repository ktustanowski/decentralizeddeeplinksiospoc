//
//  ContentViewController.swift
//  DeeplinkPOC
//
//  Created by Kamil Tustanowski on 04.04.2018.
//  Copyright © 2018 ktustanowski. All rights reserved.
//

import UIKit

struct ContentViewModel {
    let items: [String]
}

class ContentViewController: UITableViewController {
    var viewModel: ContentViewModel?
}

extension ContentViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.items.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContentCell", for: indexPath)
        cell.textLabel?.text = viewModel?.items[indexPath.row]
        
        return cell
    }
}
