
import Foundation

/*:
 # How This Playground Works
 
 Most of the time it's some comment and back story and a bit of code.
 
 Sometimes you can run this code and it will be in a special block called `run` like this:
 */


run("👋🏻 check the console output") {
    let result = 2 + 2
    print(result)
}

/*:
 In console you should see something like this:
 
 ```
 👋🏻 check the console output >
 4
 👋🏻 check the console output >
 ```
 
 Each of this `run` blocks will have it's own marking for begin and end. Also I will try to start it with an emoji so it will cach your eye more 👀
 
 It may happen that some blocks are disabled or the output is to verbose and you do not want to see anymore some examples. Then just add `x` in front of run making it `xrun`
 */

xrun("🙅🏼‍♂️ No Go") {
    print("As long as it's xrun then you will not see it.")
}

/*:
 Nothing to see in console for this example. Those blocks allow me to reuse names and alter just small part. Think of them like snapshots ;)
 
 ## Last Thing
 
 At the bottom of each playground page I put `print("🍑")`. If I see it then I know that playground did run and everything is peachy ;) Playgrounds are what they are ;)
 */

print("🍑")

/*:
 # [Tap Here To Go To The Thing You Came Here](@next)
 */

//: [Next](@next)
