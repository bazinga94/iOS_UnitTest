//
//  NetworkConfig.swift
//  Network_UnitTest
//
//  Created by Jongho Lee on 2021/04/25.
//

import Foundation

protocol NetworkInterface {
	associatedtype Response: APIResponse
	var url: URL { get }
	var responseSample: Data { get }
}

protocol RequestableBody {
	associatedtype Request: APIRequest
	var body: Request { get set }
}

protocol APIRequest: Encodable {
}

protocol APIResponse: Decodable {
}

enum APIError: Error {
	case unknown
	case httpStatus
	case encodingModel
	case decodingJSON
	case dataNil
	//	var errorDescription: String? { "unknownError" }
}

enum HttpMethod: String {
	case GET
	case POST
	case PUT
	case DELETE
}

typealias ResultCallback<Response> = (Result<Response, APIError>) -> Void
