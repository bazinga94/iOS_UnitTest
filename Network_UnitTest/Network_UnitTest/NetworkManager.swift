//
//  NetworkManager.swift
//  Network_UnitTest
//
//  Created by Jongho Lee on 2021/04/10.
//
import Foundation

// 우아한 형제들 기술블로그 참고 https://woowabros.github.io/swift/2020/12/20/ios-networking-and-testing.html
struct JokeReponse: Decodable {
	let type: String
	let value: Joke
}

struct Joke: Decodable {
	let id: Int
	let joke: String
	let categories: [String]
}

enum JokesAPI {
	case randomJokes

	static let baseURL = "https://api.icndb.com/"
	var path: String { "jokes/random" }
	var url: URL { URL(string: JokesAPI.baseURL + path)! }
}

enum APIError: LocalizedError {
	case unknownError
	var errorDescription: String? { "unknownError" }
}

class JokesAPIProvider {

	let session: URLSession
	init(session: URLSession = .shared) {
		self.session = session
	}

	func fetchRandomJoke(completion: @escaping (Result<Joke, Error>) -> Void) {
		let request = URLRequest(url: JokesAPI.randomJokes.url)

		let task: URLSessionDataTask = session
			.dataTask(with: request) { data, urlResponse, error in
				guard let response = urlResponse as? HTTPURLResponse,
					  (200...399).contains(response.statusCode) else {
					completion(.failure(error ?? APIError.unknownError))
					return
				}

				if let data = data,
				   let jokeResponse = try? JSONDecoder().decode(JokeReponse.self, from: data) {
					completion(.success(jokeResponse.value))
					return
				}
				completion(.failure(APIError.unknownError))
			}

		task.resume()
	}
}
