//
//  PromoViewController.swift
//  DeeplinkPOC
//
//  Created by Kamil Tustanowski on 04.04.2018.
//  Copyright © 2018 ktustanowski. All rights reserved.
//

import UIKit
import LinkHandler

// dlpoc://Item/4/Promo/8

class PromoViewModel {
    let item: String
    var promoItems: [String]?
    
    var isLoaded: Bool {
        return promoItems != nil
    }
    
    func load(completion: (() -> Void)?) {
        dispatchAfter(1.0) { [weak self] in
            self?.promoItems = [1, 2, 3, 4, 5, 6, 7, 8, 9].map { "\(self?.item ?? "") Promo \($0)" }
            completion?()
        }
    }
    
    func indexPath(for id: String) -> IndexPath? {
        guard let index = promoItems?.index(of: id) else { return nil }
        
        return IndexPath(row: index, section: 0)
    }

    init(item: String) {
        self.item = item
    }
}

class PromoViewController: UITableViewController {
    var linkHandling: LinkHandling?
    var viewModel: PromoViewModel?
    
    override func viewDidLoad() {
        viewModel?.load { [weak self] in
            self?.tableView.reloadData()
            self?.completeLinking()
        }
    }
}

extension PromoViewController: LinkHandler {
    func process(link: Link, animated: Bool) -> LinkHandling {
        guard viewModel?.isLoaded == true else { return .delayed(link, animated) }
        
        switch link.intent {
        case .showPromos(id: let contentId, parentId: _):
            if let indexPathToSelect = viewModel?.indexPath(for: contentId) {
                tableView.selectRow(at: indexPathToSelect, animated: true, scrollPosition: .none)
            }
            return .opened(link)
        default:
            return .rejected(link, "Unrecognized link")
        }
    }
}

extension PromoViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.promoItems?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PromoCell", for: indexPath)
        cell.textLabel?.text = viewModel?.promoItems?[indexPath.row]
        
        return cell
    }
}
