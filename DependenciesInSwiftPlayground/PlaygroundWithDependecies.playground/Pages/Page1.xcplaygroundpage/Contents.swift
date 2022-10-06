import UIKit

var str = "Hello, playground"

import OptionalAPI

let life: Int? = 40

life
    .andThen{ $0 + 1 }
    .andThen{ print($0) }


print("😎")
