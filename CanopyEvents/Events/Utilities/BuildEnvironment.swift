import StoreKit

/// Where this build came from, for showing internal tools: a debug build
/// or an Xcode run, or TestFlight, but never the App Store. TestFlight is
/// told by StoreKit 2's app transaction (verified, in the sandbox
/// environment), not the deprecated receipt URL. Ask once at launch;
/// `AppSession.showsDebugTools` keeps the answer.
enum BuildEnvironment {
    /// True for debug builds, Xcode and TestFlight; false for the App
    /// Store, and whenever the transaction can't be verified.
    static func isInternal() async -> Bool {
        #if DEBUG
        return true
        #else
        guard let result = try? await AppTransaction.shared, case .verified(let transaction) = result else {
            return false
        }
        return transaction.environment == .sandbox || transaction.environment == .xcode
        #endif
    }
}
