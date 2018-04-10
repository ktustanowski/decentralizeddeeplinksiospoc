//
//  AllViewController.swift
//  DeeplinkPOC
//
//  Created by Kamil Tustanowski on 04.04.2018.
//  Copyright © 2018 ktustanowski. All rights reserved.
//

import UIKit
import LinkHandler

extension AllViewController: LinkHandler {
    func process(link: Link, animated: Bool) -> LinkHandling {
        guard isViewLoaded else { return .delayed(link, animated) }
        
        switch link.intent {
        case .showPromos(id: _, parentId: _):
            performSegue(withIdentifier: "ToPromo", sender: link)
            return .passedThrough(link)
        case .showContent(id: _, parentId: _):
            performSegue(withIdentifier: "ToContent", sender: link)
            return .passedThrough(link)
        default:
            return .rejected(link, "Unsupported link")
        }
    }
}

class AllViewController: UITableViewController {
    var linkHandling: LinkHandling?
    var viewModel: AllViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        completeLinking()
    }
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
            if let link = sender as? Link,
                case let .showPromos(id: _, parentId: parentId) = link.intent {
                    promoViewController?.viewModel = viewModel?.makePromoViewModel(with: parentId)
                    promoViewController?.pass(link: link, animated: true)
            } else {
                promoViewController?.viewModel = viewModel?.makePromoViewModel(with: tableView.indexPath(for: sender as! UITableViewCell)!)
            }
        case "ToContent":
            let contentViewController = segue.destination as? ContentViewController
            if let link = sender as? Link,
                case let .showContent(id: _, parentId: parentId) = link.intent {
                    contentViewController?.viewModel = viewModel?.makeContentViewModel(with: parentId)
                    contentViewController?.pass(link: link, animated: true)
            } else {
                contentViewController?.viewModel = viewModel?.makeContentViewModel(with: tableView.indexPath(for: sender as! UITableViewCell)!)
            }
        default:
            print("Ooops!")
        }
    }
}

struct AllViewModel {
    let items: [String]
    
    func makePromoViewModel(with itemId: String) -> PromoViewModel {
        return PromoViewModel(item: itemId)
    }
    
    func makePromoViewModel(with indexPath: IndexPath) -> PromoViewModel {
        return makePromoViewModel(with: items[indexPath.row])
    }
    
    func makeContentViewModel(with indexPath: IndexPath) -> ContentViewModel {
        return makeContentViewModel(with: items[indexPath.row])
    }
    
    func makeContentViewModel(with itemId: String) -> ContentViewModel {
        return ContentViewModel(item: itemId)
    }
}
