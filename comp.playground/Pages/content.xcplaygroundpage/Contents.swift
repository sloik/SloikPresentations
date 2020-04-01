import UIKit

/*:
 # DISCLAIMER
 
 I stand here on the shoulders of giants and here are those giants that inspired me to put it all in one place. Please check their work and be inspired as I am ✌🏻
 
 * [pointfree.co - there I saw a lot of operators that I show here](https://www.pointfree.co)
 * [Runes - frameworks with more operators](https://github.com/thoughtbot/Runes)
 * [Overture - library for composing functions with ease](https://github.com/pointfreeco/swift-overture)
  * [F# for fun and profit  -- tons of ideas how to apply this concepts in real life](https://fsharpforfunandprofit.com/video/)
 
 ---
  */

























/*:
 
 # Composition is better than inheritance
 
 Many people say those words but what do they mean? Let's start from the other way around.
 
 `Why use inheritance in the first place?`
 
 It's a way to reuse code. Simple as that.
 
 `So what's the problem with that?`
 
 Nothing! But if your system evolves changes to this inheritance hierarchy are hard to do. Other clients depend on certain behaviours. Then requirements change and you have to adopt. It's possible but painful.

 _Example of inheritance hierarchy. Just image that you have to change anything here!_
 ![](uikit_classes.jpg)
 
 `How composition helps?`
 
 With composition it's easier to create new parts form smaller pieces. You can freely modify any behaviour not only by adding some stuff but also by removing.
 
 Or just glue what you need at call site.
 
 ## Composition 101
 
 Simplest and probably most common used in a day to day method of composition is aggregation. The _big idea_ is that you take smaller parts and _aggregate_ them together.
 */

struct User {
    let name: String
    let age: Int
}

/*:
 Two simpler types `Int` and `String` are aggregated together to form one type `User`. Now this _bigger_ thing can be used in place of any _smaller_ one.
 */

struct ContactInfo {
    let user: User
    let address: String
}

/*:
 
 ## Function Composition

 As developers we want to achieve as much code reuse as we could possible can. We split up our monoliths to frameworks, long functions to smaller ones etc..

 On example where this approach shines is Unix/Linux and the terminal _commands_. One has many small programs (in our context functions) that can be easily _combined_ together using operators. With this small parts one can build bigger utilities/programs/function that can also be composed with other parts. Just like LEGO ;)

 # Pipe 🚰

 I think one of the most common activities in programming is calling a function to obtain some result and pass that in to next function and that to the next and so on. Let's see an artificial example so we can focus on the structure rather the computation.

 Let's define our building blocks:
 */

func increment(_ x: Int) -> Int { x + 1 }
func    square(_ x: Int) -> Int { x * x }

/*:
With that let's write some simple computations. Just to see the structure:
 */

run("🤥 long version to see the structure") {
    var x = 1
    print("\(x) + 1             =>", {
        let incremented = increment(x)
        return incremented
    }())

    x = 2
    print("(\(x)^2) + 1         =>", {
        let squared = square(x)
        let incremented = increment(squared)

        return incremented
    }())

    x = 0
    print("((\(x) + 1)^2)^2 + 1 =>", {
        let incremented = increment(x)
        let squared = square(incremented)
        let squaredAgain = square(squared)
        let incrementedAgain = increment(squaredAgain)

        return incrementedAgain
    }())
}

/*:
 I know that _this_ code you would write differently. But remember this is just to show **the structure** and not to focus on the computation. But for the sake of completeness let's write it without the extra variables:
 */

run("🤪 simple ones") {
    var x = 1
    print("\(x) + 1             =>", increment(x))

    x = 2
    print("(\(x)^2) + 1         =>", increment(square(x)))

    x = 0
    print("((\(x) + 1)^2)^2 + 1 =>", increment(square(square(increment(x)))))
}

/*:
For trivial cases this does not look so bad right 😊 But I would argue after 2nd example it's more challenging to fallow. Also the amount of parentheses does not help in terms of readability.

 ## Code Reuse

 Ok let's try to _close_ this _pattern_ inside of a function:
 */

func compose<A,B,C>(
    _ f: @escaping (A) -> B,
    _ g: @escaping (B) -> C
    ) -> (A) -> C {
    return { a in
        let b = f(a)
        let c = g(b)
        return c // g(f(a))
    }
}

/*:
This looks like we did not gain anything but let's try to do _something_ with it. Also this type of functions that take as argument and/or returns a function are called `Higher Order Functions`.
 */

let addTwo = compose(increment, increment)

/*:
_addTwo_ expresses the idea of adding 2 but look that we did not say "how" to do it only we _expressed_ this idea with composition with more _declarative_ style. The code reuse part is obvious at this moment.

 Let see how this _works_:
 */

run("🙃 with help") {
    // (x + 2)^4 + 3

    addTwo // x + 2

    let tetra = compose(square, square) // ^4

    let addTwoAndTetra = compose(addTwo, tetra) // (x + 2)^4

    let addThree = compose(addTwo, increment) // + 3

    let composed = compose(addTwoAndTetra, addThree)

    var x = -1
    print("(\(x) + 2)^4 + 3 =>", composed(x))

    x = 0
    print("(\(x) + 2)^4 + 3 =>", composed(x))

    x = 1
    print("(\(x) + 2)^4 + 3 =>", composed(x))
}

/*:
This is nice! It's so nice that a lot of hidden plumbing is not visible. Let's rewrite this whole computation as _one_ expression.
 */

run("🦋 composition with functions ") {
    // (x + 2)^4 + 3
    let composed =
    compose(                // <-- plumbing🚰 (x + 2)^4 + 3
        compose(            // <-- plumbing🚰 (x + 2)^4
            compose(        // <-- plumbing🚰  x + 2
                increment,  // <-- basic block 🧱 +1
                increment   // <-- basic block 🧱 +1
            ),
            compose(    // <-- plumbing🚰 ^4
                square, // <-- basic block 🧱 ^2
                square  // <-- basic block 🧱 ^2
            )
        ),
        compose(           // <-- plumbing🚰 +3
            compose(       // <-- plumbing🚰 +2
                increment, // <-- basic block 🧱 +1
                increment  // <-- basic block 🧱 +1
            ),
            increment      // <-- basic block 🧱 +1
        )
    )

    var x = -1
    print("(\(x) + 2)^4 + 3 =>", composed(x))

    x = 0
    print("(\(x) + 2)^4 + 3 =>", composed(x))

    x = 1
    print("(\(x) + 2)^4 + 3 =>", composed(x))
}

/*:
I hope it's very visible that a lot of this code is plumbing for what we are actually trying to achieve. And I hope at this moment everyone can reflect and recall in memory of a piece of code where this structure is present.

This is _fine_ as we can read what the _glue_ function does. The _name_ is a very good hint. But as we can see plumbing is very visible. After all no one wants to live in a house where pipes run on the walls instead in them.

 Let's do something about it...

 # Operators

 Operators have bad press. They are a useful tool to have that can make code more expressive. Let's take a look at some operator that we already know:
 */

2 + 3

/*:
The same can be achieved with a plain old function
 */

func addNumbers(_ a: Int, _ b: Int) -> Int { a + b }

assertEqual(
    2 + 3, addNumbers(2, 3)
)

/*:
But here is the whole truths. Operators are plain old functions but with a special syntax to call them. And we can prove that:
 */

run("🎒 operators are functions") {
    print(type(of: addNumbers))

    // variable for storing functions
    var someFunction: (Int, Int) -> Int = addNumbers

    someFunction(2,3)

    // lets assign our plus operator
    someFunction = (+)

    someFunction(2,3)

    // we can call this operator as a regular function to but with just
    (+)(2,3)
}

/*:
Now you know! So it's time to for some operators that help with working with functions:
 */

precedencegroup ForwardApplication {
    associativity: left
    higherThan: MultiplicationPrecedence
}

infix operator |>: ForwardApplication

public func |> <A, B>(x: A, f: (A) -> B) -> B { f(x) }

 
run("🌞 pipe forward") {
    var x = 1
    print(
        "\(x) + 1             =>",
        x |> increment
    )

    x = 2
    print(
        "(\(x)^2) + 1         =>",
        x
            |> square
            |> increment
    )

    x = 0
    print(
        "((\(x) + 1)^2)^2 + 1 =>",
        x
            |> increment
            |> square
            |> square
            |> increment
    )
}

/*:
 ### One more thing

 With this function and operator we gained a way of inlining simple anonymous functions with a very readable way.
 */

run("🌟 inline functions") {

    print("x + 1           =>",
        1 |> { $0 + 1 }
    )

    print("(x + 2)^2^2 - 1 =>",
        0
            |> { i in i + 2 }
            |> square
            |> square
            |> { $0 - 1 }
    )
}

/*:
Wow! This looks way better then the function version and even better than the explicit code with helper variables. With this we have a very cool tool that we can use to build longer pipelines that can process a value. Also this structure is very flexible and easy to modify. Just add or remove a line ad hoc function or whatever. Simple :)

 Readability is also a plus. The plumbing is minimal. If you squint your eyes you see only the dense part of the code. The part that show the intent the "what" not the "how".

 Another way of looking at this operator is like on a design pattern that encapsulates calling a function with some value.

 # Function >>> Composition

 With _pipe forward_ functions are getting called at every step of the _pipeline_. Sometimes it's not the thing we want. Sometimes we want to define a _recipe_, a function that can be used in other places.

 There are a lot of APIs that expect a function as input. The most know one is `map` function. And others like `filter`, `reduce`, `firstWhere` etc. And yes they are also `Higher Order Functions` as they take as input another function.

 Lets see how it's possible to compose functions
 */

precedencegroup ForwardComposition {
    higherThan: ForwardApplication
    associativity: right
}

infix operator >>>: ForwardComposition

public func >>> <A, B, C>(
    _ f: @escaping (A) -> B,
    _ g: @escaping (B) -> C)
    -> (A) -> C {
        return { a in a |> f |> g }
}

/*:
With this operator we have a tool that allows us to _define a pipeline_ that's waiting to be executed.
 */

run("🍷 fun with >>>") {
    // (x + 3)^3 + 10
    let expression = increment
        >>> increment
        >>> increment
        >>> { x in x * x * x }
        >>> { $0 + 10 }

    print("expression type:",
          type(of: expression)
    )

    print("(x + 3)^3 + 10 =>",
          -3 |> expression
    )

    print("[-3,0,3] map   =>",
        [-3,0,3].map(expression)
    )
}


/*:
 # Summary

 Operators are a very useful tool that can make code more focused on the intent rather than on plumbing. Each time you use an operator you are reusing code. Applying some design pattern.

 Of course there is something to learn (there is always something to learn!). Like the meaning for the operators... but it's not much. Those presented are one liners. And they unlock a very nice pattern in the structure of code you can write.

 What's not visible now but this shape is universal and can be repeated for other types. Anyone who writes Rx/Combine code should recognise at least some similarities.

 Those operators are only the beginning ;) Like I said there is another composition pattern looking at us. It's the `map` function. But this one deserves it's on talk. Of course if you wanna hear about it ;)
 */


print("🥳 👑🦠")
