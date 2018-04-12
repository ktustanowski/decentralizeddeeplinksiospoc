# Decentralized Deep Link - Proof of Concept

Decentralized approach to iOS deep links (and more)

## The problem
Deep links most of the time are "just implemented". Nothing more nothing less. Sure, how important they are depends on the app but overall it would be nice to have some pattern how to approach them in maintainable, future-proof manner. Not just black box implementation we are happy with. Until it works or until we need to extend it.

## The goal
To make deep linking:
* reliable
* easy to understand
* easy to follow
* easy to extend

## The approach
As usual I started from... googling for any publications on the subject to have more context. I'm providing links to the two most helpful documents in the end. 
I wanted to be able to handle all, or as much as possible at least, ways of how other apps, system, etc. can interact and communicate with the application. 
### One entry point for:
* Deep Links
* Shortcuts (force touch)
* Universal Links
* Spotlight search
* PUSH
### Preparation
The part right before dispatching a link which consists of determinig of link type, some config loading, waiting for components initialization etc. is based on signals so it can be easily extended based on the needs.
### Navigation
Instead of some huge central coordinator I followed the decentralized approach. PoC application navigation is based on storyboards so (it requires a bit more boilerplate code). What I like about this is how overall this approach made the deeplinkh handling clear. The flow just goes from one node (view controller) to another and simple enum-fueled decision making is done on what to do next. 

This also offers great control on the flow. Item that we want to show is not accessibile from home screen? Not a problem, just navigate to screen containing all the items and show it from there. Item is on home? Even better. One step less.
Additional bonus is that having this nodes setup we can reuse them. Let's say we need to be able to show legal documents to the user from content screen. We just prepare the link to legal page, dismiss the content and tell home to navigate to settings because Home already knows how to this. 

## The flow - high overview
![the flow - high overview](https://github.com/ktustanowski/decentraliseddeeplinksiospoc/blob/master/Images/Decentralised_Deeplinks.png?raw=true)

## How it works
### LinkDispatcher
Top level structure and entry point to linking flow. We initialize it in AppDelegate. It prepares the Link to use later and decides when linking flow can start. So if we need to wait for a single sign on attempt to finish, any needed data / config loading or components initialization - we will. It's all based on signals so it's easy to extend. 

AppDelegate implement LinkDispatcherDelegate protocol:
```
public protocol LinkDispatcherDelegate {
    func willStartLinking()
    func link(with link: Link)
}
```
and then when needed it asks LinkDispatcher to handle url:
```
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    linkDispatcher.handle(url)
    return true
}
```
or i.e. NSUserActivity:
```
func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    linkDispatcher.handle(userActivity)
    return true
}
```
Internally LinkDispatcher uses LinkFactory to make links based on the input:
```
public struct LinkFactory {
    public static func make(with userActivity: NSUserActivity) -> SignalProducer<Link?, NoError> {
        return SignalProducer.merge(SpotlightParser.parse(userActivity).logEvents(identifier: "SL"),
                                    UniversalLinkParser.parse(userActivity).logEvents(identifier: "UL"))
    }
    
    public static func make(with shortcutItem: UIApplicationShortcutItem) -> SignalProducer<Link?, NoError> {
        return ShortcutParser.parse(shortcutItem).logEvents(identifier: "SC")
    }

    public static func make(with url: URL) -> SignalProducer<Link?, NoError> {
        return DeepLinkParser.parse(url).logEvents(identifier: "DL")
    }
    
    public static func make(with info: [AnyHashable : Any]) -> SignalProducer<Link?, NoError> {
        return PushParser.parse(info)
    }
}
```
Which then uses specialized parsers for any supported kind of input:
* DeepLinkParser
* ShortcutParser
* UniversalLinkParser
* SpotlightParser
* PushParser

![Linking preparation](https://github.com/ktustanowski/decentraliseddeeplinksiospoc/blob/master/Images/Linking_preparation.png)

Let's use **dlpoc://Settings/Legal** since it should fairly easy to describe.
When link was properly created and passed to delegate method LinkDispatcher work is done. It's where protocol oriented programming used in LinkHandler comes into play.
### LinkHandler
It's a protocol that (with help of an extension) does the magic:
```
public protocol LinkHandler: class {
    var linkHandling: LinkHandling? { get set }
    func process(link: Link, animated: Bool) -> LinkHandling
}
```
It uses LinkHandling which is basically an enum describing link handling state:
```
public enum LinkHandling: CustomStringConvertible {    
    case opened(Link)    
    case rejected(Link, String?)    
    case delayed(Link, Bool)    
    case passedThrough(Link)
}
```
The process function contains actual implementation of how links should be handled in concrete view controllers.

## The flow
 AppDelegate, asked by the LinkDispatcher to start, asks LoadingViewController to open the Link.
```
func link(with link: Link) {
    // Start deeplinking process
    window?.rootViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController()
    loadingViewController?.open(link: link, animated: true)
}
```
The problem is that at this point LoadingViewController is not yet ready to fulfill this request. It needs to do some loading before. Good that we can handle this easily:
```
extension LoadingViewController: LinkHandler {
    func process(link: Link, animated: Bool) -> LinkHandling {
        guard viewModel.isDataLoaded == true else { return .delayed(link, animated) }
        
        switch link.intent {
        default:
            navigateToHome(with: link)
            return .passedThrough(link)
        }
    }
}
```
Before LoadingViewController is ready every linking attempt will end in delaying the flow `return .delayed(link, animated)`.
Then we need to continue when data is ready which in this case will be when view model finishes data loading:
```    
override func viewDidLoad() {
    viewModel.loadData { [weak self] in
        // If we are deeplinking - this segue won't be presented to not break the flow
        // instead the deeplink process will move on
        self?.completeLinking(or: { self?.navigateToHome() })
    }
}
```
Ok. So we have the data and since we are in linking flow default segue to home is suppressed. What happens next is:
```        
switch link.intent {
    default:
        performSegue(withIdentifier: "ToHome", sender: link)
        return .passedThrough(link)
    }
}
```
Since this screen is just "in the way" this logic is very simple. But we are using Storyboards so, sadly, passing the link requires one additional step:
```    
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    [...just regular prepare for segue code...]
    homeViewController?.pass(link: sender as? Link, animated: true)
}
```
I just added small extension on UIViewController to make this a bit less painful:
```
public extension UIViewController {
    public func pass(link: Link?, animated: Bool) {
        guard let linkHandler = self as? LinkHandler,
            let link = link else { return }
        
        linkHandler.open(link: link, animated: animated)
    }
}
```
Ok, se we are on home. Linking was delayed to until viewDidLoad is called and after that linking resumed:
```
extension HomeViewController: LinkHandler {
    func process(link: Link, animated: Bool) -> LinkHandling {
        guard isViewLoaded else { return .delayed(link, animated) }
        
        switch link.intent {
        case .showSettings, .showLegal, .showLogin, .showTermsConditions:
            performSegue(withIdentifier: "ToSettings", sender: link)
            return .passedThrough(link)
        [...]
```
Since we use enum it's easy to gather flows together and we know that to show legal (and other subcategories) we need to open settings first and then pass the link further.
The last piece of the puzzle is settings screen where:
```
func process(link: Link, animated: Bool) -> LinkHandling {
    guard isViewLoaded else { return .delayed(link, animated) }
        
    switch link.intent {
    case .showLogin:
        performSegue(withIdentifier: "ToLogin", sender: nil)
        return .opened(link)
    case .showTermsConditions:
        performSegue(withIdentifier: "ToTermsConditions", sender: nil)
        return .opened(link)
    case .showLegal:
        performSegue(withIdentifier: "ToLegal", sender: nil)
        return .opened(link)
    default:
        return .rejected(link, "Unsupported link")
    }
}
```
![Linking - navigation](https://github.com/ktustanowski/decentraliseddeeplinksiospoc/blob/master/Images/Linking_navigation_flow.png)

**Note**: The delays etc. in the application are just to simulate some async stuff (like downloading data) going on. To make it behave a bit more closer to real world scenario application. This is also just PoC so it's pretty rough and unpolished. It's just to make this more understandable and testable in real-life-like situations.

Inspired by:

http://ilya.puchka.me/deeplinks-no-brainer/

https://medium.com/@stasost/ios-how-to-open-deep-links-notifications-and-shortcuts-253fb38e1696

Thanks!
