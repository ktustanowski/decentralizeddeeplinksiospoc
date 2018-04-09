//
//  ContentViewController.swift
//  DeeplinkPOC
//
//  Created by Kamil Tustanowski on 04.04.2018.
//  Copyright © 2018 ktustanowski. All rights reserved.
//

import UIKit
import LinkHandler

extension ContentViewController: LinkHandler {
    func process(link: Link, animated: Bool) -> LinkHandling {
        guard viewModel?.isLoaded == true else { return .delayed(link, animated) }
        
        switch link.intent {
        case .showLegal:
            openOnHome(link)
            return .passedThrough(link)
        case .showContent(id: let contentId, parentId: _):
            selectItem(with: contentId)
            return .opened(link)
        default:
            return .rejected(link, "Unrecognized link")
        }
    }
    
    func openOnHome(_ link: Link) {
        navigationController?.popToRootViewController(animated: false)
        (navigationController?.viewControllers.first as? LinkHandler)?.open(link: link, animated: true)
    }
    
    func selectItem(with id: String) {
        if let indexPathToSelect = viewModel?.indexPath(for: id) {
            tableView.selectRow(at: indexPathToSelect, animated: true, scrollPosition: .none)
        }
    }
}

class ContentViewController: UITableViewController {
    var linkHandling: LinkHandling?
    
    var viewModel: ContentViewModel?
    
    @IBAction func navigateToLegal(_ sender: Any) {
        open(link: Link(intent: .showLegal), animated: true)
    }
    
    override func viewDidLoad() {
        viewModel?.load { [weak self] in
            self?.tableView.reloadData()
            self?.completeLinking()
        }
    }
}

extension ContentViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.contentItems?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContentCell", for: indexPath)
        cell.textLabel?.text = viewModel?.contentItems?[indexPath.row]
        
        return cell
    }
}

class ContentViewModel {
    let item: String
    var contentItems: [String]?
    
    var isLoaded: Bool {
        return contentItems != nil
    }
    
    func load(completion: (() -> Void)?) {
        dispatchAfter(1.0) { [weak self] in
            self?.contentItems = [1, 2, 3, 4, 5, 6, 7, 8, 9].map { "\(self?.item ?? "") Content \($0)" }
            completion?()
        }
    }
    
    func indexPath(for id: String) -> IndexPath? {
        guard let index = contentItems?.index(of: id) else { return nil }
        
        return IndexPath(row: index, section: 0)
    }
    
    init(item: String) {
        self.item = item
    }
}
