import Foundation

public protocol RetryPolicy {
    /// Return delay seconds before next retry, or nil to stop retrying.
    func retryDelay(for error: Error, attempt: Int, response: HTTPURLResponse?) -> TimeInterval?
}

public struct ExponentialBackoffRetryPolicy: RetryPolicy {
    public let maxAttempts: Int
    public let baseDelay: TimeInterval
    public let jitter: ClosedRange<Double>?

    public init(maxAttempts: Int = 3, baseDelay: TimeInterval = 0.5, jitter: ClosedRange<Double>? = 0.0...0.3) {
        self.maxAttempts = maxAttempts
        self.baseDelay = baseDelay
        self.jitter = jitter
    }

    public func retryDelay(for error: Error, attempt: Int, response: HTTPURLResponse?) -> TimeInterval? {
        guard attempt < maxAttempts else { return nil }
        // Retry for transport errors and 5xx
        let is5xx = (response?.statusCode ?? 0) >= 500
        let isTransport = (error as? URLError) != nil
        guard is5xx || isTransport else { return nil }
        var delay = baseDelay * pow(2.0, Double(attempt - 1))
        if let j = jitter {
            delay += Double.random(in: j) * delay
        }
        return delay
    }
}