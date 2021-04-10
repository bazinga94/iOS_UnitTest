//
//  NetworkManager.swift
//  Network_UnitTest
//
//  Created by Jongho Lee on 2021/04/10.
//
import Foundation

// 우아한 형제들 기술블로그 참고 https://woowabros.github.io/swift/2020/12/20/ios-networking-and-testing.html

enum APIError: Error {
	case unknown
	case httpStatus
	case decodingJSON
	case dataNil
//	var errorDescription: String? { "unknownError" }
}

enum HttpMethod: String {
	case GET
	case POST
}

class NetworkManager {

	let session: URLSession

	init(session: URLSession = .shared) {
		self.session = session
	}

	func fetchRequest<T: Decodable>(url: URL, type: HttpMethod, body: String? = nil, completion: @escaping (Result<T, APIError>) -> Void) {
		var request = URLRequest(url: url)
		request.httpMethod = type.rawValue
		request.httpBody = body?.data(using: .utf8)

		let task: URLSessionDataTask = session
			.dataTask(with: request) { data, urlResponse, error in
				guard let response = urlResponse as? HTTPURLResponse,
					  (200...399).contains(response.statusCode) else {
					completion(.failure(.httpStatus))
					return
				}

				guard let data = data else {
					return completion(.failure(.dataNil))
				}

				guard let model = try? JSONDecoder().decode(T.self, from: data) else {
					completion(.failure(.decodingJSON))
					return
				}
				completion(.success(model))
			}
		task.resume()
	}
}
