//
//  IAPManaging.swift
//  horoscopeo
//
//  Created by Azizbek Asadov on 12.08.2025.
//

import Foundation
import StoreKit

@MainActor
public final class SKPaymentManager: ObservableObject, @preconcurrency IAPManaging {

    // Published for SwiftUI if you want to observe
    @Published public private(set) var products: [Product] = []
    @Published public private(set) var purchasedProductIDs: Set<String> = []
    @Published public private(set) var isLoading: Bool = false

    private var productIDs: [String] = []
    private var updatesTask: Task<Void, Never>?

    public init() {}

    deinit {
        updatesTask?.cancel()
    }

    // MARK: - Lifecycle

    public func configure(with productIDs: [String]) async {
        self.productIDs = productIDs
        isLoading = true
        defer { isLoading = false }

        do {
            // Load products
            let fetched = try await Product.products(for: productIDs)
            // Keep a stable order like you define in productIDs
            self.products = productIDs.compactMap { id in fetched.first(where: { $0.id == id }) }

            // Prime entitlements & start listening for updates
            await refreshEntitlements()
            startTransactionListenerIfNeeded()
        } catch {
            // You might surface an error state if needed
            self.products = []
        }
    }

    // MARK: - Purchasing

    public func purchase(productID: String) async throws -> PurchaseResult {
        guard let product = products.first(where: { $0.id == productID }) else {
            throw StoreKitError.unknown
        }

        // Purchase (no options by default; inject options here if you need appAccountToken etc.)
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            // Update local entitlements
            purchasedProductIDs.insert(transaction.productID)
            // Always finish
            await transaction.finish()
            return .success(productID: transaction.productID)

        case .pending:
            return .pending

        case .userCancelled:
            return .userCancelled

        @unknown default:
            return .userCancelled
        }
    }

    // MARK: - Restore

    public func restorePurchases() async throws {
        // StoreKit2 restore: trigger App Store sync
        try await AppStore.sync()
        // Entitlements will flow via Transaction.updates; refresh as well
        await refreshEntitlements()
    }

    // MARK: - Queries

    public func isPurchased(_ productID: String) async -> Bool {
        if purchasedProductIDs.contains(productID) { return true }
        // double‑check authoritative transaction state (non‑consumables/subscriptions)
        if let _ = await latestVerifiedTransaction(for: productID) {
            return true
        }
        return false
    }

    public func subscriptionStatus(for productID: String) async -> SubscriptionStatus {
        guard let product = products.first(where: { $0.id == productID }),
              let _ = product.subscription else {
            return .notSubscribed
        }

        // Grab the latest transaction for this productID
        guard let latest = await latestVerifiedTransaction(for: productID) else {
            return .notSubscribed
        }

        // Ask StoreKit for renewal info (subscription group aware)
//        do {
//            if let renewing = await latest.renewalInfo?.payloadValue {
//                let expiry = latest.expirationDate
//                switch renewing.state {
//                case .subscribed:         return .active(expirationDate: expiry)
//                case .inGracePeriod:      return .inGracePeriod(expirationDate: expiry)
//                case .inBillingRetry:     return .inBillingRetry(expirationDate: expiry)
//                case .expired:            return .expired(expirationDate: expiry)
//                default:                  return expiry.map { .expired(expirationDate: $0) } ?? .notSubscribed
//                }
//            } else {
//                // Non-renewing purchase path
//                if let expiry = latest.expirationDate, expiry < Date() {
//                    return .expired(expirationDate: expiry)
//                }
//                return .active(expirationDate: latest.expirationDate)
//            }
//        } catch {
//            // If renewal-info fails, still infer from the transaction.
//            if let expiry = latest.expirationDate, expiry < Date() {
//                return .expired(expirationDate: expiry)
//            }
//            return .active(expirationDate: latest.expirationDate)
//        }
        
        return .notSubscribed
    }

    // MARK: - Internals

    private func startTransactionListenerIfNeeded() {
        guard updatesTask == nil else { return }

        updatesTask = Task.detached(priority: .background) { [weak self] in
            guard let self else { return }
            for await result in Transaction.updates {
                // Each update arrives on a background actor; hop to main to mutate state.
                await self.handle(transactionResult: result)
            }
        }
    }

    @MainActor
    private func handle(transactionResult: VerificationResult<Transaction>) async {
        do {
            let transaction = try checkVerified(transactionResult)
            // Update entitlements in memory
            purchasedProductIDs.insert(transaction.productID)
            // Always finish the transaction
            await transaction.finish()
        } catch {
            // Ignore unverified
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }

    private func latestVerifiedTransaction(for productID: String) async -> Transaction? {
        
        do {
            if let result = try await Transaction.latest(for: productID) {
                switch result {
                case .unverified(_, _):
                    return nil
                case .verified(let t):
                    return t
                }
            }
        } catch { }
        return nil
    }

    private func refreshEntitlements() async {
        var owned = Set<String>()
        for await result in Transaction.currentEntitlements {
            if case .verified(let t) = result {
                owned.insert(t.productID)
            }
        }
        self.purchasedProductIDs = owned
    }
}
