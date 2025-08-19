//
//  SecurityMonitor.swift
//  horoscopeo
//
//  Created by Azizbek Asadov on 11.08.2025.
//


import UIKit

final class SecurityMonitor {
    static let shared = SecurityMonitor()
    
    private init() {
//        observeScreenshot()
        observeScreenRecording()
    }
    
    public func observeScreenshot() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidTakeScreenshot),
            name: UIApplication.userDidTakeScreenshotNotification,
            object: nil
        )
    }

    private func observeScreenRecording() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if UIScreen.main.isCaptured {
                self.userDidStartScreenRecording()
            }
        }
    }

    @objc func userDidTakeScreenshot() {
        flagUserAndSaveBlackImage()
    }

    private func userDidStartScreenRecording() {
        flagUserAndSaveBlackImage()
    }

    private func flagUserAndSaveBlackImage() {
        AppStorage.hasEverDoneScreenshot = true

        if let blackImage = UIImage.blackImage(ofSize: UIScreen.main.bounds.size) {
            UIImageWriteToSavedPhotosAlbum(blackImage, nil, nil, nil)
        }

        AppStorage.isCustomInstall = false
        print("⚠️ User flagged for screen capture")
    }
}

extension UIImage {
    static func blackImage(ofSize size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        UIColor.black.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let blackImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return blackImage
    }
}
