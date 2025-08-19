
public enum SubscriptionStatus: Equatable {
    case notSubscribed
    case active(expirationDate: Date?)
    case expired(expirationDate: Date?)
    case inGracePeriod(expirationDate: Date?)
    case inBillingRetry(expirationDate: Date?)
}