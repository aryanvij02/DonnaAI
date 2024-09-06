//
//  ScreenShotHandler.swift
//  OSai
//
//  Created by gill on 4/11/24.
//

import Foundation
import AppKit

class ScreenShotHandler {
    static let shared = ScreenShotHandler()
    private var handleMyOCR = OCRHandler()
    private var handleMyLLM = LLMHandler()
    public var turnedOn = true
    private var date = NSDate()
    private var result = ""
    public var fileURL: URL = {
        let fileManager = FileManager.default
        
        // Get the application support directory
        guard let appSupportDir = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            fatalError("Failed to get the application support directory")
        }
        
        // Create your app's subdirectory if it doesn't exist
        let appSubDir = appSupportDir.appendingPathComponent("OSai")
        try? fileManager.createDirectory(at: appSubDir, withIntermediateDirectories: true, attributes: nil)
        
        // Create and return the default file URL
        return appSubDir.appendingPathComponent("screens.txt")
    }()
    
    var screenshotTimer: Timer?
    
    enum ScreenshotError: Error {
        case unableToCreateImage
    }

    func startScreenshotTask() {
        stopScreenshotTask() // Ensure no timer is running
        screenshotTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            _ = try? self.takeScreenshot()
        }
        print("Screenshot task started")
    }
    
    func stopScreenshotTask() {
        screenshotTimer?.invalidate()
        screenshotTimer = nil
        print("Screenshot task stopped")
    }
    
    func takeScreenshot() throws {
        if StateManager.shared.turnedOn {
            guard let imageRef = CGDisplayCreateImage(CGMainDisplayID()) else {
                throw ScreenshotError.unableToCreateImage
            }
            print("Screenshot taken")
            OCRHandle(image: NSImage(cgImage: imageRef, size: NSZeroSize))
        } else {
            print("OSai is shut down.")
        }
    }
    
    func clearPortions() {
        do {
            let currContents = try String(contentsOf: fileURL)
            let halfSize = currContents.utf8.count / 2
            let newContents = String(currContents.dropFirst(halfSize))
            try newContents.write(to: fileURL, atomically: true, encoding: .utf8)
            print("CLEARED HALF")
        } catch {
            print("Error while clearing portions: \(error)")
        }
    }
    
    func textFileClear() {
        try? "".write(to: fileURL, atomically: true, encoding: .utf8)
        print("Text file cleared")
    }

    func getTextContent() -> String {
        do {
            let currContents = try String(contentsOf: fileURL)
            print("Successfully returned file at \(fileURL)")
            return currContents
        } catch {
            print("Failed to read file: \(error)")
            return ""
        }
    }
    
    func textFileAppend(ocrResult: String) -> String {
        do {
            var currContents = try String(contentsOf: fileURL)
            currContents += "-----This is a new screenshot taken at \(String(date.timeIntervalSince1970))-----"
            currContents.append(contentsOf: ocrResult)
            print("Prepared content for appending")
            return currContents
        } catch {
            print("Failed to read file for appending: \(error)")
            return ""
        }
    }
    
    func textFileHandler(ocrResult: String) {
        do {
            let contentToWrite = textFileAppend(ocrResult: ocrResult)
            try contentToWrite.write(to: fileURL, atomically: true, encoding: .utf8)
            print("Successfully wrote to the file at \(fileURL)")
        } catch {
            print("Failed to write to the file: \(error.localizedDescription)")
        }
    }
    
    
    
    func OCRHandle(image: NSImage) {
        handleMyOCR.performOCR(on: image) { [weak self] ocrResult in
            guard let self = self else { return }
            self.result = ocrResult
            
            // Check for common bank account names
            let commonBankAccountNames = ["Chase", "Bank of America", "Wells Fargo", "Citibank", "U.S. Bank"]
            let lowercaseOCRResult = ocrResult.lowercased()
            
            for bankName in commonBankAccountNames {
                if lowercaseOCRResult.contains(bankName.lowercased()) {
                    StateManager.shared.turnedOn = false
                    print("OSai turned off due to detecting a bank account name: \(bankName)")
                    StateManager.shared.currSystemImageChange()
                    StateManager.shared.textSleep = "OSai is looking away. Press power to resume."
                    return
                }
            }
            
            self.textFileHandler(ocrResult: self.result)
        }
    }}
