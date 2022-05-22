//: [Previous](@previous)

/*:

# Swift concurrency

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

 * [Meet Swift Concurrency](https://developer.apple.com/news/?id=2o3euotz)
 */


//: [Next](@next)
