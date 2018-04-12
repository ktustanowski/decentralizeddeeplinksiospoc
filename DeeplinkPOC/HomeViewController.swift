//
//  HomeViewController.swift
//  DeeplinkPOC
//
//  Created by Kamil Tustanowski on 30.03.2018.
//  Copyright © 2018 ktustanowski. All rights reserved.
//

import UIKit
import LinkHandler

extension HomeViewController: LinkHandler {
    func process(link: Link, animated: Bool) -> LinkHandling {
        let isVisible = view.window != nil // without this linking navigation was overlapping with unwinding
        guard isViewLoaded && isVisible else { return .delayed(link, animated) }
        
        switch link.intent {
        case .showSettings, .showLegal, .showLogin, .showTermsConditions:
            performSegue(withIdentifier: "ToSettings", sender: link)
            return .passedThrough(link)
        case .showPromos(id: _, parentId: let parentId):
            if viewModel?.items.contains(parentId) == true {
                // If item is on home perform deep link
                performSegue(withIdentifier: "ToPromo", sender: link)
                return .passedThrough(link)
            } else if viewModel?.allItems.contains(parentId) == true {
                // If item isn't on home perform but is on All screen
                // deep link to All screen first
                performSegue(withIdentifier: "ToAll", sender: link)
                return .passedThrough(link)
            } else {
                // No item? Then just reject deep link.
                return .rejected(link, "\(parentId) not found")
            }
        case .showContent(id: _, parentId: let parentId):
            if viewModel?.items.contains(parentId) == true {
                // If item is on home perform deep link
                performSegue(withIdentifier: "ToContent", sender: link)
                return .passedThrough(link)
            } else if viewModel?.allItems.contains(parentId) == true {
                // If item isn't on home perform but is on All screen
                // deep link to All screen first
                performSegue(withIdentifier: "ToAll", sender: link)
                return .passedThrough(link)
            } else {
                // No item? Then just reject deep link.
                return .rejected(link, "\(parentId) not found")
            }
        default:
            return .rejected(link, "Unsupported link")
        }
    }
}

class HomeViewController: UITableViewController {
    var linkHandling: LinkHandling?
    var viewModel: HomeViewModel?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        completeLinking()
    }
    
    @IBAction func unwindToHome(segue:UIStoryboardSegue) { }
}

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
        case "ToSettings":
            let settingsViewController = segue.destination as? SettingsViewController
            settingsViewController?.pass(link: sender as? Link, animated: true)
        case "ToAll":
            let allViewController = segue.destination as? AllViewController
            allViewController?.viewModel = viewModel?.makeAllViewModel()
            allViewController?.pass(link: sender as? Link, animated: true)
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
