//
//  LLMHandler.swift
//  OSai
//
//  Created by gill on 4/11/24.
//

import Foundation
class LLMHandler {
    func getGemini(context:String, body:String, completion: @escaping (String) -> Void) {
        
        if (body.utf8.count <= 2) {
            completion("Please give a valid input. Input must be greater than 2 characters!")
            return;
            
        }
        
        let url = URL(string: "http://24.144.88.47:8000/post")!
        var dataRes = ""
        var request = URLRequest(url: url)
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        request.httpMethod = "POST"
        let body = ["context": context, "question": body]
        let bodyData = try? JSONSerialization.data(
            withJSONObject: body
        )
        request.httpBody = bodyData
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion("An error occured.")
            } else if let data = data {
                if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let result = jsonObject["text"] as? String {
                        dataRes = result
                        completion(dataRes)
                    }
                    else {
                        completion("(debug) Faulty JSON request.")
                    }
                }
            } else {
                completion("Something unexpected happened? Try again.")
            }
        }
        task.resume()
    }
}
