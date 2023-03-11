//: [Previous](@previous)

/*:

# Swift concurrency

 > Zapoznaj się w wolnej chwili z [Swift Concurrency – Things They Don’t Tell You](https://wojciechkulik.pl/ios/swift-concurrency-things-they-dont-tell-you). Niestety nie wszystko jest takie łatwe jak w przykładach Apple.

---

 Razem ze Swift 5.5 do języka doszło pojęcie ["structured concurrency"](https://github.com/apple/swift-evolution/blob/main/proposals/0304-structured-concurrency.md).

 ## Pula wątków

 System zarządza pulą wątków. Dzięki czemu nie ma obawy, że powstanie ich za dużo. Nie ma też narzutu związanego z towrzeniem i niszczeniem wątków.

 ## async await

 Nowa ozlocona składnia, która mówi kompilatorowi oraz runtime, że dany kawałek kodu może zostać zatrzymany i wznowiony w przyszłości (Androidowiec w Tobie powinien od razu pomyśleć o corutines).

 Nieoczekiwanie z nową składnią możemy używać "non escaping closures" i dzięki temu skończyć z martwieniem się o _weak_ referencje do _self_.

 ## Structured concurrency

 Jedno zadanie może wywołać lawine kolejnych zadań. Czasem jakieś są ważniejsze niż inne. Tak utworzoną hierarchią runtime może _sterować_ i _przepuszczać_ ważniejsze zadania i/lub anulować tą lawine zadań w momencie gdy zadanie _rodzic_ jest anulowane (ponownie Androidowiec w Tobie powinien pomyśleć o corutines).


 ## Context aware compilation

 Umownie powiedzmy, że to jest _zbiór zasad_ jakich powinniśmy przestrzegać przy pisaniu współbieżnego i asynchronicznego kodu. Kompilator _zna_ te zasady i wykorzystuje je do generowania wydajnego i bezpiecznego kodu. Dodatkowo gdy coś zrobisz potencjalnie niebezpiecznego to program się nie skompiluje!

 # Links

* [Kodeco - Modern Concurrency: Getting Started](https://www.kodeco.com/28434449-modern-concurrency-getting-started)
 * [Meet Swift Concurrency](https://developer.apple.com/news/?id=2o3euotz)
 * [WWDC22 -Visualize and optimize Swift concurency](https://developer.apple.com/wwdc22/110350)
 * [RW AsyncSequence & AsyncStream Tutorial for iOS](https://www.raywenderlich.com/34044359-asyncsequence-asyncstream-tutorial-for-ios)
 * [RW Book - Modern Concurrency in Swift](https://www.raywenderlich.com/books/modern-concurrency-in-swift)
* [WWDC22 Meet distributed actors in Swift](https://developer.apple.com/wwdc22/110356)
 * [YT - Swiftful Thinking - Swift Concurrency (Intermediate Level) Playlist](https://www.youtube.com/playlist?list=PLwvDm4Vfkdphr2Dl4sY4rS9PLzPdyi8PM)
 * [Andy Ibanez - Modern Concurrency in Swift](https://www.andyibanez.com/posts/modern-concurrency-in-swift-introduction/)
 * [YT - How to download images in parallel with Swift Concurrency](https://www.youtube.com/watch?v=MjfEpYs5XA4)
 * [YT - Learn Swift Concurrency online for FREE, Async Await, Actors, Continuations And More](https://www.youtube.com/watch?v=U6lQustiTGE)
 * [YT - Willing Suspension of Disbelief - iOS Conf SG 2022](https://youtu.be/FEqmYi-FaB8)
 * [YT - How to use Continuations in Swift (withCheckedThrowingContinuation) | Swift Concurrency #7](https://youtu.be/Tw_WLMIfEPQ)
 * [YT - Swift Concurrency Under the Hood - iOS Conf SG 2022](https://youtu.be/wp5vIVxABFk)
 * [Limit Swift Concurrency's cooperative pool
](https://alejandromp.com/blog/limit-swift-concurrency-cooperative-pool)
 * [Task Groups in Swift explained with code examples](https://www.avanderlee.com/concurrency/task-groups-in-swift)
 * [Debouncing with Swift concurrency](https://sideeffect.io/posts/2023-01-11-regulate)
 * [Async/Await in Swift](https://youtu.be/esmf26aGz4s)
 * [How do Actors work in Swift?](https://youtu.be/8jvtHCXJ4Ow)
 * [YT - 2021 LLVM Dev Mtg “Asynchronous Functions in Swift”](https://youtu.be/H_K-us4-K7s)
 * [YT - 2016 LLVM Developers’ Meeting: G. Nishanov “LLVM Coroutines”](https://youtu.be/Ztr8QvMhqmQ)
 * [YT - 2018 LLVM Developers’ Meeting: J. McCall “Coroutine Representations and ABIs in LLVM”](https://youtu.be/wyAbV8AM9PM)
 * [Detached Tasks in Swift explained with code examples](https://www.avanderlee.com/concurrency/detached-tasks)
 * [Apple - Improving app responsiveness](https://developer.apple.com/documentation/xcode/improving-app-responsiveness)
 * [SwiftUI's .task modifier](https://alexanderweiss.dev/blog/2023-03-05-swiftui-task-modifier)

 */


//: [Next](@next)
