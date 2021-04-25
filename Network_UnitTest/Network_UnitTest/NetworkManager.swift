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
	func fetch<T: NetworkInterface & RequestableBody>(method: HttpMethod, request: T, completion: @escaping ResultCallback<T.Response>)
	func fetch<T: NetworkInterface>(method: HttpMethod, request: T, completion: @escaping ResultCallback<T.Response>)
}

extension NetworkProtocol {
	init(session: URLSessionProtocol = URLSession.shared) {
		self.init(session: session)
		self.session = session
	}

	var session: URLSessionProtocol {
		return URLSession.shared
	}
}

class NetworkManager: NetworkProtocol {

	var session: URLSessionProtocol

	required init(session: URLSessionProtocol) {
		self.session = session
	}

	/// POST method network request
	func fetch<T>(method: HttpMethod = .POST, request: T, completion: @escaping ResultCallback<T.Response>) where T : NetworkInterface, T : RequestableBody {

		guard let encodedModel = try? JSONEncoder().encode(request.body) else {
			completion(.failure(.encodingModel))
			return
		}
		var urlRequest = URLRequest(url: request.url)
		urlRequest.httpMethod = method.rawValue
		urlRequest.httpBody = encodedModel

		let task: URLSessionDataTask = session
			.dataTask(with: urlRequest) { data, urlResponse, error in
				guard let response = urlResponse as? HTTPURLResponse,
					  (200...399).contains(response.statusCode) else {
					completion(.failure(.httpStatus))
					return
				}

				guard let data = data else {
					return completion(.failure(.dataNil))
				}

				guard let model = try? JSONDecoder().decode(T.Response.self, from: data) else {
					completion(.failure(.decodingJSON))
					return
				}
				completion(.success(model))
			}
		task.resume()
	}

	/// GET method network request
	func fetch<T>(method: HttpMethod = .GET, request: T, completion: @escaping ResultCallback<T.Response>) where T : NetworkInterface {

		var urlRequest = URLRequest(url: request.url)
		urlRequest.httpMethod = method.rawValue

		let task: URLSessionDataTask = session
			.dataTask(with: urlRequest) { data, urlResponse, error in
				guard let response = urlResponse as? HTTPURLResponse,
					  (200...399).contains(response.statusCode) else {
					completion(.failure(.httpStatus))
					return
				}

				guard let data = data else {
					return completion(.failure(.dataNil))
				}

				guard let model = try? JSONDecoder().decode(T.Response.self, from: data) else {
					completion(.failure(.decodingJSON))
					return
				}
				completion(.success(model))
			}
		task.resume()
	}
}
