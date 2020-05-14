import UIKit

/*:
 
 # True Story
 
 This is something that happened to me at work. During a code review I have stumbled upon a peace of code that looked something like this:
 */


extension UIView {
    func originalAllSubViewsOf<T: UIView>(type: T.Type) -> [T] {
        var all = [T]()
        func getSubview(view: UIView) {
            if let aView = view as? T { all.append(aView) }
            guard view.subviews.isEmpty == false else { return }
            view.subviews.forEach { getSubview(view: $0) }
        }
        getSubview(view: self)
        return all
    }
}

/*:
 
 And I have left a comment `could it be done with a filter?`.
 
 ## Context
 
 If you have done any UIKit work then you will recognise this method in an instance! The need is obvious.
 
 If this is new for you then in a deep view hierarchy of a view controller you have some custom views (or not necessary custom). And you want to call a method on each of them no matter how deep the rabbit whole goes.
 
 Sure you can use `subviews` but what happens when those views also have subviews and you need to get to them to? This extension is an answer for that.
 
 Let's see how it works. We need some views and subviews and classes... lets do this ;)
 */

class A: UIView {}
class B: UIView {}

let viewHierarchy: B = {
    let view = B()
    
    view
        .addSubview({
            let subview = UIView()
                subview
                    .addSubview(A())
            return subview
            }())
    
    view
        .addSubview(UILabel())
    
    view
        .addSubview({
            let subview = UIView()
            
            subview
                .addSubview(UILabel())
            
            subview
                .addSubview(A())
            
            subview
                .addSubview({
                    let subSubView = A()
                    
                    subSubView
                        .addSubview(B())
                    
                    return subSubView
                }())
            
            return subview
            }())
    
    return view
}()

/*:
 To summarise this hierarchy has:
 * 3 instances of UIView-a -- there is a catch as *all* of them are UIViews ;)
 * 2 instances of UILabel-s
 * 3 instances of As
 * 2 instance of B
 
 If it's hard to image then take a look here:
 ```
 ┌──────┬───┐
 │  B   │ ┌─┴────┬───────┐
 ├──────┘ │UIView│   ┌───┴─┐
 │        ├──────┘   │  A  │
 │        │          └───┬─┘
 │        └─┬────────────┘
 │        ┌─┴────┬───────┐
 │        │UIView│   ┌───┴───┐
 │        ├──────┘   │UILabel│
 │        │          └───┬───┘
 │        └─┬────────────┘
 │        ┌─┴────┬───────┐
 │        │UIView│   ┌───┴───┐
 │        ├──────┘   │UILabel│
 │        │          └───┬───┘
 │        │          ┌───┴─┐
 │        │          │  A  │
 │        │          └───┬─┘
 │        │          ┌───┴─┬─────┐
 │        │          │  A  │ ┌───┴─┐
 │        │          ├─────┘ │  B  │
 │        │          │       └───┬─┘
 │        │          └───┬───────┘
 │        └─┬────────────┘
 └──────────┘
 ```
 
 Ok so now we can take this extension and take it for a spin. We wont do anything with those instances only pluck out them from this hierarchy.
 */

let allAs = viewHierarchy.originalAllSubViewsOf(type: A.self)
let allBs = viewHierarchy.originalAllSubViewsOf(type: B.self)
let allLs = viewHierarchy.originalAllSubViewsOf(type: UILabel.self)
let allVs = viewHierarchy.originalAllSubViewsOf(type: UIView.self)

run("🐡 original implementation") {
    print("We have", allAs.count, "of type", type(of: allAs).Element)
    print("We have", allBs.count, "of type", type(of: allBs).Element)
    print("We have", allLs.count, "of type", type(of: allLs).Element)
    print("We have", allVs.count, "of type", type(of: allVs).Element)
}

/*:
 As you can see this kind of method can be very handy. Especially if you want to do something to only one kind of views that are visible on screen.
 
 What's more cool that this is strongly type. Each time we are getting an array of the views that we are interested. No need to cast no nothing. Good, cool API to use... but ;)
 
 Lets take a look at the implementation one more time:
 
````
 func originalAllSubViewsOf<T: UIView>(type: T.Type) -> [T] {
     var all = [T]()
     func getSubview(view: UIView) {
         if let aView = view as? T { all.append(aView) }
         guard view.subviews.isEmpty == false else { return }
         view.subviews.forEach { getSubview(view: $0) }
     }
     getSubview(view: self)
     return all
 }
````
 
It's function with a nested function that calls itself recursively. There is a check if current view also fits the predicate and should be added to an `all` accumulator array. What's a bit messy is that mutation of this array is done by the inner function... but the whole thing is internal to the implementation so... like you see. There are a lot of tradeoffs here. Name of the function conveys more of the intent of the developer than the implementation.
 
 ## Can we do better?
 
Define better. For now I will say better is _less code_ and reuse Swift higher order functions. So after some time of fiddling around I have come up with this:
 */

extension UIView {
    func views<T>(of type: T.Type) -> [T] {
        subviews
            .reduce(
                (self as? T).map{ [$0] } ?? [],
                { (acc, subview) in acc + subview.views(of: type) }
        )
    }
}

/*:
 You must admit that implementation did reduced quite a bit ;) Thing to notice is how the initial element for the reduce function is computed: `(self as? T).map{ [$0] } ?? []`. In my _private_ code I have some helper functions and operators to make it more streamlined but... I think it is still very dense and conveys meaning very well.
 
 Next is the **partial result block**. And I must say I like it a lot. It says _give me what you have so far and add to it result of getting views(of:)_.
 
 This is dense. So lets see how it goes against original implementation:
 */

run("🌟 reduced implementation") {
    print("Test allAs have the same count:",
          assertEqual(
            allAs.count,
            viewHierarchy.views(of: A.self).count
        )
    )
    
    print("Test allBs have the same count:",
          assertEqual(
            allBs.count,
            viewHierarchy.views(of: B.self).count
        )
    )
    
    print("Test allLs have the same count:",
          assertEqual(
            allLs.count,
            viewHierarchy.views(of: UILabel.self).count
        )
    )
    
    print("Test allVs have the same count:",
          assertEqual(
            allVs.count,
            viewHierarchy.views(of: UIView.self).count
        )
    )
}

/*:
 Sweet! As far our tests go we have the same behaviour. But...
 
 ## Can we do better?
  
 Define better. There are more relation ships like this in UIKit and who know where else. Let's take **UIViewController** for a spin. You can add a **child view controller** to it.
 */

class AVC: UIViewController {}
class BVC: UIViewController {}
class CVC: UIViewController {}

/*:
 Sorry for the short name of the View Controller classes. But it will be more readable when we do the same thing as with UIView-s.
 */

let controllerHierarchy: BVC = {
    let controller = BVC()
    
    controller
        .addChild({
            let subController = UIViewController()
                subController
                    .addChild(AVC())
            return subController
            }())
    
    controller
        .addChild(CVC())
    
    controller
        .addChild({
            let subController = UIViewController()
            
            subController
                .addChild(CVC())
            
            subController
                .addChild(AVC())
            
            subController
                .addChild({
                    let subSubController = AVC()
                    
                    subSubController
                        .addChild(BVC())
                    
                    return subSubController
                }())
            
            return subController
            }())
    
    return controller
}()

/*:
 It's the same code as for view hierarchy only name of the classes changed:
 * UIView -> UIViewController
 * A -> AVC
 * B -> BVC
 * UILabel -> CVC
 
 If you want more _visual_ representation than here you go:
 
 ```
 ┌─────┐
 │ BVC │
 └─────┘
    │   ┌──────────────────┐
    ├──▶│ UIViewController │
    │   └──────────────────┘
    │             │        ┌─────┐
    │             └───────▶│ AVC │
    │                      └─────┘
    │   ┌──────────────────┐
    ├──▶│ UIViewController │
    │   └──────────────────┘
    │             │        ┌─────┐
    │             └───────▶│ CVC │
    │                      └─────┘
    │   ┌──────────────────┐
    └──▶│ UIViewController │
        └──────────────────┘
                  │        ┌─────┐
                  ├───────▶│ CVC │
                  │        └─────┘
                  │        ┌─────┐
                  ├───────▶│ AVC │
                  │        └─────┘
                  │        ┌─────┐
                  └───────▶│ AVC │
                           └─────┘
                              │  ┌─────┐
                              └─▶│ BVC │
                                 └─────┘
 ```
 
 Almost looks like a folder structure... hmm... but we wont go there. Let's check the controller count:
 * 3 instances of UIViewController-s -- there is a catch as *all* of them are UIViewController-s ;)
 * 2 instances of CVC-s
 * 3 instances of AVCs
 * 2 instance of BVCs
 
 Let's do what any respecting developer would do. Let's copy and paste some code:
 */

extension UIViewController {
    func allChildren<T>(of type: T.Type) -> [T] {
        children
            .reduce(
                (self as? T).map{ [$0] } ?? [],
                { (acc, subController) in acc + subController.allChildren(of: type) }
        )
    }
}

/*:
 As you can see it was a minor rename but now we have the same stuff that we had for views working for UIControllers! I did say working? Lets check:
 */

let allAVCs = controllerHierarchy.allChildren(of: AVC.self)
let allBVCs = controllerHierarchy.allChildren(of: BVC.self)
let allCVCs = controllerHierarchy.allChildren(of: CVC.self)
let allUIVs = controllerHierarchy.allChildren(of: UIViewController.self)

run("🍟 view controllers") {
    print("We have", allAVCs.count, "of type", type(of: allAVCs).Element)
    print("We have", allBVCs.count, "of type", type(of: allBVCs).Element)
    print("We have", allCVCs.count, "of type", type(of: allCVCs).Element)
    print("We have", allUIVs.count, "of type", type(of: allUIVs).Element)
}

/*:
 Ok so we can clearly see that there is a pattern. After all it's a copy and pasted pice of code with some methods renamed.
 
 As I want it to be generic as possible I will create a free function that will abstract this idea for me. The idea is to extract _T from sub stuff_. So lets get to it:
 */


func substuff<T, W>(
    of type: T.Type,
    in what: W,
    extractStuff sub: (W) -> [W])
    -> [T] {
        sub(what)
            .reduce(
                (what as? T).map{ [$0] } ?? [],
                { (acc: [T], newWhat: W) -> [T] in
                    acc + substuff(of: type, in: newWhat, extractStuff: sub) }
        )
}

/*:
 As you can see this is the same shape. As a bonus because there is no information about any of the types we cannot mutate anything! But let's take it pice by pice.
 
 First argument is the _Type_ we are interested. Second is the instance this function will start this working. And this function needs to know how to extract some stuff from thing we are currently working on. To put it in context of previous examples how to get subviews from a view and children from view controller.
 
 Ok let's check this out. I will add more extensions but this time implementation will come from this function.
 */

extension UIView {
    func viewsUsingStuff<T>(of type: T.Type) -> [T] {
        substuff(of: type, in: self, extractStuff: \.subviews)
    }
}

extension UIViewController {
    func allChildrenUsingStuff<T>(of type: T.Type) -> [T] {
        substuff(of: type, in: self, extractStuff: \.children)
    }
}

/*:
 Nice :D Let's test if we get the same results :D
 */

run("🍣 Test all the things") {
    print("Test allAs have the same count:",
          assertEqual(
            allAs.count,
            viewHierarchy.viewsUsingStuff(of: A.self).count
        ),
          "Have the same instances:",
          assertEqual(
            allAs,
            viewHierarchy.viewsUsingStuff(of: A.self)
        )
    )
    
    print("Test allBs have the same count:",
          assertEqual(
            allBs.count,
            viewHierarchy.viewsUsingStuff(of: B.self).count
        ),
          "Have the same instances:",
          assertEqual(
            allBs,
            viewHierarchy.viewsUsingStuff(of: B.self)
        )
    )
    
    print("Test allLs have the same count:",
          assertEqual(
            allLs.count,
            viewHierarchy.viewsUsingStuff(of: UILabel.self).count
        ),
          "Have the same instances:",
          assertEqual(
            allLs,
            viewHierarchy.viewsUsingStuff(of: UILabel.self)
        )
    )
    
    print("Test allVs have the same count:",
          assertEqual(
            allVs.count,
            viewHierarchy.viewsUsingStuff(of: UIView.self).count
        ),
          "Have the same instances:",
          assertEqual(
            allVs,
            viewHierarchy.viewsUsingStuff(of: UIView.self)
        )
    )
    
    __
    
    print("Test allAVCs have the same count:",
          assertEqual(
            allAVCs.count,
            controllerHierarchy.allChildrenUsingStuff(of: AVC.self).count
        ),
          "Have the same instances:",
          assertEqual(
            allAVCs,
            controllerHierarchy.allChildrenUsingStuff(of: AVC.self)
        )
    )
    
    print("Test allBVCs have the same count:",
          assertEqual(
            allBVCs.count,
            controllerHierarchy.allChildrenUsingStuff(of: BVC.self).count
        ),
          "Have the same instances:",
          assertEqual(
            allBVCs,
            controllerHierarchy.allChildrenUsingStuff(of: BVC.self)
        )
    )
    
    print("Test allCVCs have the same count:",
          assertEqual(
            allCVCs.count,
            controllerHierarchy.allChildrenUsingStuff(of: CVC.self).count
        ),
          "Have the same instances:",
          assertEqual(
            allCVCs,
            controllerHierarchy.allChildrenUsingStuff(of: CVC.self)
        )
    )
    
    print("Test allUIVs have the same count:",
          assertEqual(
            allUIVs.count,
            controllerHierarchy.allChildrenUsingStuff(of: UIViewController.self).count
        ),
          "Have the same instances:",
          assertEqual(
            allUIVs,
            controllerHierarchy.allChildrenUsingStuff(of: UIViewController.self)
        )
    )
}

/*:
 Now this is cool! Lets take a look on it one more time:
 
 ````
 extension UIView {
     func viewsUsingStuff<T>(of type: T.Type) -> [T] {
         substuff(of: type, in: self, extractStuff: \.subviews)
     }
 }

 extension UIViewController {
     func allChildrenUsingStuff<T>(of type: T.Type) -> [T] {
         substuff(of: type, in: self, extractStuff: \.children)
     }
 }
 ````
 
 You can say that the most interesting stuff is the `extractStuff` part. And it is! That's the part when you inject behaviour of getting substuff! And you can lift a [KeyPath to a function](https://github.com/apple/swift-evolution/blob/master/proposals/0249-key-path-literal-function-expressions.md) so everything is statically checked!

# Conclusion
 
 Let's get back to this PR and the comment. Developer stayed with his original implementation and that is fine. This is just code ;)
 
 More important is that part when we went that extra mile. Finding and defining this function as this give us a nice chance to talk about it. See what is possible and when to say stop, it's enough. For him it was that original implementation. For me I would go with `reduce` version and copied it to other places where it was needed.
 
 Why copy? It's easier to understand. Closer to the task at hand. So wat it's copied? :)
 
 Thanks for reading this :)
 */






print("🍑")
