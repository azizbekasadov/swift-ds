//
//  IAPManaging 2.swift
//  horoscopeo
//
//  Created by Azizbek Asadov on 12.08.2025.
//

import StoreKit

public protocol IAPManaging: AnyObject {
    var products: [Product] { get }
    var purchasedProductIDs: Set<String> { get }
    var isLoading: Bool { get }
    func configure(with productIDs: [String]) async
    func purchase(productID: String) async throws -> PurchaseResult
    func restorePurchases() async throws
    func isPurchased(_ productID: String) async -> Bool
    func subscriptionStatus(for productID: String) async -> SubscriptionStatus
}
