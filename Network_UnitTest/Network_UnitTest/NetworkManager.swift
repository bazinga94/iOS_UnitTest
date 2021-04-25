//
//  NetworkManager.swift
//  Network_UnitTest
//
//  Created by Jongho Lee on 2021/04/10.
//
import Foundation

// 우아한 형제들 기술블로그 참고 https://woowabros.github.io/swift/2020/12/20/ios-networking-and-testing.html
// Marvel API 참고 https://medium.com/makingtuenti/writing-a-scalable-api-client-in-swift-4-b3c6f7f3f3fb

protocol URLSessionProtocol {
	func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}
extension URLSession: URLSessionProtocol {
}

protocol NetworkProtocol {
	init(session: URLSessionProtocol)
	var session: URLSessionProtocol { get set }
	func fetchRequest<T: Decodable>(url: URL, type: HttpMethod, body: String, completion: @escaping ResultCallback<T>)
}

extension NetworkProtocol {
	init(session: URLSessionProtocol = URLSession.shared) {
		self.init(session: session)
		self.session = session
	}

	var session: URLSessionProtocol {
		return URLSession.shared
	}

	func fetchRequest<T>(url: URL, type: HttpMethod, body: String? = nil, completion: @escaping (Result<T, APIError>) -> Void) where T : Decodable {
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

class NetworkManager: NetworkProtocol {
	var session: URLSessionProtocol

	required init(session: URLSessionProtocol) {
		self.session = session
	}

	func fetchRequest<T>(url: URL, type: HttpMethod, body: String, completion: @escaping (Result<T, APIError>) -> Void) where T : Decodable {
		var request = URLRequest(url: url)
		request.httpMethod = type.rawValue
		request.httpBody = body.data(using: .utf8)

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
