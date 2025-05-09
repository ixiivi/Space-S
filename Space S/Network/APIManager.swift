//
//  APIManager.swift
//  Space S
//
//  Created by 김재현 on 5/9/25.
//

import Foundation

class APIManager {
    static let shared = APIManager()

    private init() {}

    func fetchData(from url: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: url) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            completion(.success(data))
        }
        task.resume()
    }
}
