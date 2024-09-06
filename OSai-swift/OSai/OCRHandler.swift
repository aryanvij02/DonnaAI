//
//  OCRHandler.swift
//  OSai
//
//  Created by gill on 4/11/24.
//

import Foundation
import AppKit
import VisionKit

class OCRHandler {
    func performOCR(on image: NSImage, completion: @escaping (String) -> Void) {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            completion("")
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        // Use VisionKit for OCR
        let textRecognitionRequest = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion("")
                return
            }
            
            var recognizedText = ""
            
            for observation in observations {
                guard let candidate = observation.topCandidates(1).first else {
                    continue
                }
                
                let text = candidate.string
                recognizedText += text + "\n"
                
                // Check if the recognized text contains mathematical equations
                if self.containsMath(text) {
                    // Extract the bounding box of the math equation
                    let boundingBox = observation.boundingBox
                    
                    // Extract the image region containing the math equation
                    let mathImage = self.extractImageRegion(from: cgImage, boundingBox: boundingBox)
                    
                    // Call the API with the math image
                    self.callMathAPI(with: mathImage)
                }
            }
            
            completion(recognizedText)
        }
        
        textRecognitionRequest.recognitionLanguages = ["en-US"]
        textRecognitionRequest.usesLanguageCorrection = false
        textRecognitionRequest.recognitionLevel = .accurate
        textRecognitionRequest.minimumTextHeight = 0.01
        textRecognitionRequest.customWords = ["alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta", "iota", "kappa", "lambda", "mu", "nu", "xi", "omicron", "pi", "rho", "sigma", "tau", "upsilon", "phi", "chi", "psi", "omega", "Gamma", "Delta", "Theta", "Lambda", "Xi", "Pi", "Sigma", "Phi", "Psi", "Omega"]
        
        do {
            try requestHandler.perform([textRecognitionRequest])
        } catch {
            completion("")
        }
    }
    
    private func containsMath(_ text: String) -> Bool {
        // Regular expression pattern to match mathematical equations
        let mathPattern = "\\$.*?\\$|\\\\\\(.*?\\\\\\)|\\\\\\[.*?\\\\\\]"
        return text.range(of: mathPattern, options: .regularExpression) != nil
    }
    
    private func extractImageRegion(from image: CGImage, boundingBox: CGRect) -> CGImage? {
        let width = CGFloat(image.width)
        let height = CGFloat(image.height)
        let cropRect = CGRect(x: boundingBox.origin.x * width,
                              y: (1 - boundingBox.origin.y - boundingBox.size.height) * height,
                              width: boundingBox.size.width * width,
                              height: boundingBox.size.height * height)
        
        guard let croppedImage = image.cropping(to: cropRect) else {
            return nil
        }
        
        return croppedImage
    }
    
    private func callMathAPI(with image: CGImage, completion: @escaping (String) -> Void) {
        // Convert the CGImage to Data
        guard let imageData = image.pngData() else {
            return
        }
        
        let url = URL(string: "http://127.0.0.1:5000/ocr")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload = ["image": imageData.base64EncodedString()]
        let jsonData = try? JSONSerialization.data(withJSONObject: payload)
        request.httpBody = jsonData
        
        // Send the API request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    completion("An error occurred.")
                } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    print("HTTP Error: \(httpResponse.statusCode)")
                    completion("HTTP error occurred. Status code: \(httpResponse.statusCode)")
                } else if let data = data {
                    do {
                        if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let result = jsonObject["latex"] as? String {
                            completion(result)
                        } else {
                            completion("(debug) Faulty JSON response.")
                        }
                    } catch {
                        completion("(debug) JSON decoding error: \(error)")
                    }
                } else {
                    completion("Something unexpected happened. Try again.")
                }
            }
            task.resume()
    }
}

extension CGImage {
    func pngData() -> Data? {
        guard let mutableData = CFDataCreateMutable(nil, 0),
              let destination = CGImageDestinationCreateWithData(mutableData, "public.png" as CFString, 1, nil) else {
            return nil
        }
        CGImageDestinationAddImage(destination, self, nil)
        guard CGImageDestinationFinalize(destination) else {
            return nil
        }
        return mutableData as Data
    }
}
