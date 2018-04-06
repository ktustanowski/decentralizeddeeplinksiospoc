//
//  HomeViewController.swift
//  DeeplinkPOC
//
//  Created by Kamil Tustanowski on 30.03.2018.
//  Copyright © 2018 ktustanowski. All rights reserved.
//

import UIKit
import LinkHandler

struct HomeViewModel {
    let allItems: [String]
    let items: [String]
        
    func makeAllViewModel() -> AllViewModel {
        return AllViewModel(items: allItems)
    }
    
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

class HomeViewController: UITableViewController {
    var linkHandling: LinkHandling?
    var viewModel: HomeViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        completeLinking()
    }
    
    deinit {
        print("DEINITED HOME!")
    }
}

extension HomeViewController: LinkHandler {
    func process(link: Link, animated: Bool) -> LinkHandling {
        // if view is not loaded yet we should probably wait for it
        guard isViewLoaded else { return .delayed(link, animated) }
        
        switch link.intent {
        case .showSettings, .showLegal, .showLogin, .showTermsConditions:
            performSegue(withIdentifier: "ToSettings", sender: link)
            return .opened(link)
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
            if let link = sender as? Link {
                if case let .showPromos(id: _, parentId: parentId) = link.intent {
                    promoViewController?.viewModel = viewModel?.makePromoViewModel(with: parentId)
                    promoViewController?.open(link: link, animated: true)
                }
            } else {
                promoViewController?.viewModel = viewModel?.makePromoViewModel(with: tableView.indexPath(for: sender as! UITableViewCell)!)
            }
        case "ToContent":
            let contentViewController = segue.destination as? ContentViewController
            if let link = sender as? Link {
                if case let .showContent(id: _, parentId: parentId) = link.intent {
                    contentViewController?.viewModel = viewModel?.makeContentViewModel(with: parentId)
                    contentViewController?.open(link: link, animated: true)
                }
            } else {
                contentViewController?.viewModel = viewModel?.makeContentViewModel(with: tableView.indexPath(for: sender as! UITableViewCell)!)
            }
        default:
            print("Ooops!")
        }
    }
}
