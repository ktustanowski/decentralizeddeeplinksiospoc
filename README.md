# Decentralised Deep Link - Proof of Concept

Decentralised approach to iOS deeplinks

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
Instead of some huge central coordinator I followed the decentralised approach. PoC application navigation is based on storyboards so (it requires a bit more boilerplate code but). I like how overall this approach made the deeplinkh handling clear. The flow just goes from one node (view controller) to another and simple enum-fueled decision making is done on what to do next. 

Thanks to this the application flow is not altered and when we open link on some screen we are using regular navigation pattern. 

This also offers great control on the flow. Item that we want to show is not accessibile from home screen? Not a problem, just navigate to screen containing all the items and show it from there. Item is on home? Even better. One step less.
Additional bonus is that having this nodes setup we can reuse them. Let's say we need to be able to show user legal documents from content screen. We just prepare the link to legal page, dismiss the content ant tell home to navigate to settings because Home already knows how to handle settings links. 

## The flow - high overview

## The architecture





This very simple PoC app is simulating how real application works like data loading 

I'm using term deep links but the goal is to actually support also other ways of interapp commuincation. To have one starting point for all this kind of flows in the app. Like Spotlight search, Universal likns etc.

More info is coming...


Inspired by:

http://ilya.puchka.me/deeplinks-no-brainer/

https://medium.com/@stasost/ios-how-to-open-deep-links-notifications-and-shortcuts-253fb38e1696

Thanks!
