//
//  NetworkManager.swift
//  Network_UnitTest
//
//  Created by Jongho Lee on 2021/04/10.
//
import Foundation

// 우아한 형제들 기술블로그 참고 https://woowabros.github.io/swift/2020/12/20/ios-networking-and-testing.html

protocol URLSessionProtocol {
	func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}
extension URLSession: URLSessionProtocol {
}

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

protocol NetworkProtocol {
	init(session: URLSessionProtocol)
	var session: URLSessionProtocol { get set }
	func fetchRequest<T: Decodable>(url: URL, type: HttpMethod, body: String, completion: @escaping (Result<T, APIError>) -> Void)
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

//	init(session: URLSessionProtocol = URLSession.shared) {
//		self.session = session
//	}	// Class가 아니라 Protocol로 사용

//	func fetchRequest<T: Decodable>(url: URL, type: HttpMethod, body: String? = nil, completion: @escaping (Result<T, APIError>) -> Void) {
//		var request = URLRequest(url: url)
//		request.httpMethod = type.rawValue
//		request.httpBody = body?.data(using: .utf8)
//
//		let task: URLSessionDataTask = session
//			.dataTask(with: request) { data, urlResponse, error in
//				guard let response = urlResponse as? HTTPURLResponse,
//					  (200...399).contains(response.statusCode) else {
//					completion(.failure(.httpStatus))
//					return
//				}
//
//				guard let data = data else {
//					return completion(.failure(.dataNil))
//				}
//
//				guard let model = try? JSONDecoder().decode(T.self, from: data) else {
//					completion(.failure(.decodingJSON))
//					return
//				}
//				completion(.success(model))
//			}
//		task.resume()
//	}
}

//class NetworkManager {
//
//	func fetchRequest<T: Decodable>(url: URL, type: HttpMethod, body: String? = nil, completion: @escaping (Result<T, APIError>) -> Void) {
//		var request = URLRequest(url: url)
//		request.httpMethod = type.rawValue
//		request.httpBody = body?.data(using: .utf8)
//
//		let task: URLSessionDataTask = session
//			.dataTask(with: request) { data, urlResponse, error in
//				guard let response = urlResponse as? HTTPURLResponse,
//					  (200...399).contains(response.statusCode) else {
//					completion(.failure(.httpStatus))
//					return
//				}
//
//				guard let data = data else {
//					return completion(.failure(.dataNil))
//				}
//
//				guard let model = try? JSONDecoder().decode(T.self, from: data) else {
//					completion(.failure(.decodingJSON))
//					return
//				}
//				completion(.success(model))
//			}
//		task.resume()
//	}	// 왜 에러가 생기지?!
//}
