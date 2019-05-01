//
//  WebAPI.swift
//  practical-skill-test-ios
//
//  Created by 田辺信之 on 2019/05/01.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import Foundation

typealias Input = Request
typealias Request = (
    url: URL,
    queries: [URLQueryItem],
    headers: [String: String],
    methodAndPayload: HTTPMethodAndPayload
)



enum HTTPMethodAndPayload {
    case get
    case post(payload: Data?)
    case put(payload: Data?)
    case patch(payload: Data?)
    case delete(payload: Data?)
    
    var method: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        case .put:
            return "PUT"
        case .patch:
            return "PATCH"
        case .delete:
            return "DELETE"
        }
    }
    
    var body: Data? {
        switch self {
        case .get:
            return nil
        case let .post(x):
            return x
        case let .put(x):
            return x
        case let .patch(x):
            return x
        case let .delete(x):
            return x
        }
    }
}



enum Output {
    case hasResponse(Response)
    case noResponse(ConnectionError)
}


enum ConnectionError {
    case malformedURL(debugInfo: String)
    case noDataOrNoResponse(debugInfo: String)
}



typealias Response = (
    statusCode: HTTPStatus,
    headers: [String: String],
    payload: Data
)



enum HTTPStatus {
    case ok
    case notFound
    case noContent
    case unsupported(code: Int)
    
    
    static func from(code: Int) -> HTTPStatus {
        switch code {
        case 200:
            return .ok
        case 404:
            return .notFound
        case 204:
            return .noContent
        default:
            return .unsupported(code: code)
        }
    }
}



enum WebAPI {
    static func call(with input: Input) {
        self.call(with: input) { _ in
            // 何もしない
        }
    }
    
    
    static func call(with input: Input, _ block: @escaping (Output) -> Void) {
        let urlRequest = self.createURLRequest(by: input)
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, urlResponse, error) in
            let output = self.createOutput(
                data: data,
                urlResponse: urlResponse as? HTTPURLResponse,
                error: error
            )
            
            block(output)
        }
        task.resume()
    }
    
    
    static private func createURLRequest(by input: Input) -> URLRequest {
        var request = URLRequest(url: input.url)
        request.httpMethod = input.methodAndPayload.method
        request.httpBody = input.methodAndPayload.body
        request.allHTTPHeaderFields = input.headers
        return request
    }
    
    
    static private func createOutput(
        data: Data?,
        urlResponse: HTTPURLResponse?,
        error: Error?
        ) -> Output {
        guard let data = data, let response = urlResponse else {
            return .noResponse(.noDataOrNoResponse(debugInfo: error.debugDescription))
        }
        
        var headers: [String: String] = [:]
        for (key, value) in response.allHeaderFields.enumerated() {
            headers[key.description] = String(describing: value)
        }
        return .hasResponse((
            statusCode: .from(code: response.statusCode),
            headers: headers,
            payload: data
        ))
    }
}



enum Either<Left, Right> {
    case left(Left)
    case right(Right)
    
    var left: Left? {
        switch self {
        case let .left(x):
            return x
            
        case .right:
            return nil
        }
    }
    
    var right: Right? {
        switch self {
        case .left:
            return nil
            
        case let .right(x):
            return x
        }
    }
}

// PostTokenStatusの変換で起きうるエラー一覧
enum TransformError {
    // ペイロードが壊れたJSONだった場合のエラー
    case malformedData(debugInfo: String)
    // HTTPステータスコードがOK以外だった場合のエラー
    case noContent
    case unexpectedStatusCode(debugInfo: String)
}


protocol APIClientDelegate {
    static func from(response: Response) -> Either<TransformError, Self>
}

extension APIClientDelegate where Self: Codable {
    static func from(response: Response) -> Either<TransformError, Self> {
        switch response.statusCode {
        case .ok:
            do {
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .useDefaultKeys
                let result = try jsonDecoder.decode(Self.self, from: response.payload)
                return .right(result)
            } catch {
                return .left(.malformedData(debugInfo: "\(error)"))
            }
        case .noContent:
            return .left(.noContent)
        default:
            return .left(.unexpectedStatusCode(debugInfo: "\(response.statusCode)"))
        }
    }
    
    
    static func fetch(
        method: HTTPMethodAndPayload,
        queries: [URLQueryItem] = [],
        apiPath: String,
        _ block: @escaping (Either<Either<ConnectionError, TransformError>, Self>) -> Void
        ) {
        let urlString = "\(Bundle.main.object(forInfoDictionaryKey: "GetDomainURL") as! String)/\(apiPath)"
        var component = URLComponents(string: urlString)
        component?.queryItems = queries
        guard let url = component?.url else {
            block(.left(.left(.malformedURL(debugInfo: "\(urlString))"))))
            return
        }
        let input: Input = (
            url: url,
            queries: queries,
            headers: ["Content-Type":"application/json"],
            methodAndPayload: method
        )
        
        WebAPI.call(with: input) { output in
            switch output {
            case let .noResponse(connectionError):
                block(.left(.left(connectionError)))
            case let.hasResponse(response):
                let errorOrData = Self.from(response: response)
                switch errorOrData {
                case let .left(transformeError):
                    block(.left(.right(transformeError)))
                case let .right(result):
                    block(.right(result))
                }
            }
        }
    }
}
