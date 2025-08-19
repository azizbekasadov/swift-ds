
infix operator ?= : AssignmentPrecedence
infix operator ?+ : AdditionPrecedence
infix operator ?+= : AssignmentPrecedence
infix operator =~ : LogicalConjunctionPrecedence

func ?= <T>(target: inout T, newValue: T?) {
    if let unwrapped = newValue {
        target = unwrapped
    }
}

func ?+ <T: AdditiveArithmetic>(lhs: T?, rhs: T?) -> T? {
    return lhs.flatMap { x in rhs.map { y in x + y } }
}

func ?+= <T: AdditiveArithmetic>(lhs: inout T?, rhs: T?) {
    lhs = lhs ?+ rhs
}

func ?+ <T: StringProtocol>(lhs: Optional<T>, rhs: Optional<T>) -> String {
    return [lhs, rhs].compactMap { $0 }.joined()
}


func =~ (string:String, regex:String) -> Bool {
    return string.range(of: regex, options: .regularExpression) != nil
}