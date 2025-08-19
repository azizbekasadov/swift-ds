//
//  AppStorage.swift
//  horoscopeo
//
//  Created by Azizbek Asadov on 11.08.2025.
//



final class AppStorage {
    static var screensData: [ScreenData] = []
    static var screensData2: [Screen2Data] = []
    static var screensData3: [Screen3Data] = []
    
    @UserDefault(key: Constants.Keys.didFinishOnboarding,
                 name: "DidFinishOnboarding",
                 defaultValue: false)
    static var didFinishOnboarding: Bool
    
    @UserDefault(key: Constants.Keys.privacyDone,
                 name: "PrivacyDone",
                 defaultValue: false)
    static var privacyDone: Bool
    
    @UserDefault(key: Constants.Keys.currentServer,
                 name: "currentServerPSK",
                 defaultValue: "")
    static var currentServer: String
    
    @UserDefault(key: Constants.Keys.isCustomInstall,
                 name: "isCustomInstall",
                 defaultValue: false)
    static var isCustomInstall: Bool
    
    @UserDefault(key: Constants.Keys.isExtraPremium,
                 name: "isExtraPremium",
                 defaultValue: false)
    static var isExtraPremium: Bool

    @UserDefaultOptional(key: Constants.Keys.startTime,
                 name: "startTime")
    static var startTime: Date?
    
    @UserDefault(key: Constants.Keys.hasEverDoneScreenshot,
                 name: "hasEverDoneScreenshot",
                 defaultValue: false)
    static var hasEverDoneScreenshot: Bool
    
    @UserDefaultOptional(
        key: Constants.Keys.showSecureOffer,
        name: "showSecureOffer"
    )
    static var showSecureOffer: String?
    
    @UserDefault(
        key: Constants.Keys.offerCloseSec,
        name: "offerCloseSec",
        defaultValue: 999
    )
    static var offerCloseSec: Int
}

extension AppStorage {
    struct Constants {
        struct Keys {
            static let offerCloseSec = "offerCloseSec"
            static let showSecureOffer = "showSecureOffer"
            static let didFinishOnboarding = "wdqwdqwdqwdqwdwqdwqe3122313q2ew4erwewew4"
            static let privacyDone = "2edfwefvrsgwrefwee"
            static let currentServer = "21e21wdklqkwdnqkwdnlqkwklq"
            static let isCustomInstall = "detect"
            static let hasEverDoneScreenshot = "detect_screenshot"
            static let isExtraPremium = "wefaerwgawggwbdfbfdbfs"
            static let startTime = "dwghjkliouytfhgjkilouyt6ryewreyrutiyop890765rtyhgjklhgftydrghfjkliuygfhjkljlhghf"
        }
    }
}