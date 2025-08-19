
public enum PurchaseResult: Equatable {
    case success(productID: String)
    case pending
    case userCancelled
}