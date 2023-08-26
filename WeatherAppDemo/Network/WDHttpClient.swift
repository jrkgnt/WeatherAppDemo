//
//  WDHttpClient.swift
//  WeatherAppDemo
//
//  Created by Ravikiran Jagarlamudi on 8/24/23.
//

import Foundation

public protocol WDHTTPTask {
    func resume()
}

public protocol WDHTTPSession {
    func createDataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> WDHTTPTask
    func finishTasksAndInvalidate()
}
public protocol WDHTTPResponse: Decodable { }


public protocol WDRequestProviding {
    var request: URLRequest? { get }
}


public protocol WDHTTPRequest: WDRequestProviding, Encodable {
    
    /// The type of the expected response.
    associatedtype ResponseParserType: Parser
    
    /// Have setter to allow domain specific header; eg: in testing mock request will have specific header key:value
    var headers: [String: String] { get set }
    
    var queryParameters: [URLQueryItem] { get }
    
    var method: WDHTTPMethod { get }
    
    var requestURL: URL { get }
    
    var request: URLRequest?  { get }
    
}

extension WDHTTPRequest {
    // default  if not overridden by the implementation
    var request: URLRequest?  {
        var urlComponents = URLComponents(url: requestURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryParameters
        
        var urlRequest = URLRequest(url: self.requestURL)
        urlRequest.httpMethod = self.method.rawValue
        urlRequest.allHTTPHeaderFields = self.headers.merging(self.headers, uniquingKeysWith: { key1, _ in key1 })
        return urlRequest
    }
}



extension URLSessionTask : WDHTTPTask {
    
}

extension URLSession : WDHTTPSession {
    public func createDataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> WDHTTPTask {
        self.dataTask(with: request, completionHandler: completionHandler)
    }
}

public enum WDHTTPMethod: String, Codable {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

// TODO: Try to use enum

public enum WDCustomErrorCodes: Int, Error {
    case nonHTTPURLResponse = 5000
    case non2xxHTTPURLResponse = 5001
    
    case persistenceFailure = 5002

}

public enum WDCustomError: Error {
    public static let errorDomain = "com.ravi.personal.WeatherAppDemo.http"
    case decodingError(Error?)
    case invalidRequest
    case invalidResponse
    case underlying(Error)
    case custom(code: Int, message: String)
}


public class WDHTTPClient {
    public typealias CompletionHandler<T> = (Result<T, Error>) -> Void
    let session: WDHTTPSession
    init(session: WDHTTPSession? = nil) {
        self.session = session ?? URLSession.shared
    }
    
    public func perform<R: WDHTTPRequest>(_ wdHttpRequest: R, completionHandler: @escaping CompletionHandler< R.ResponseParserType.OutputType>) {
        
        guard let urlRequest = wdHttpRequest.request else {
            completionHandler(.failure(WDCustomError.invalidRequest))
            return
        }
        
        let dataTask = self.session.createDataTask(with: urlRequest) { data, urlResponse, error in
            if let nonEmptyError = error {
                completionHandler(.failure(nonEmptyError))
                return
            }
            guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
                completionHandler(.failure(WDCustomError.custom(code: WDCustomErrorCodes.nonHTTPURLResponse.rawValue, message: "Response is not an HTTPResponse")))
                return
            }
            
            guard (200...299).contains(httpURLResponse.statusCode) else {
                completionHandler(.failure(WDCustomError.custom(code: WDCustomErrorCodes.non2xxHTTPURLResponse.rawValue, message: "Response is not an HTTPResponse")))
                return
            }
            
            guard let nonEmptyData = data else {
                completionHandler(.failure(WDCustomError.custom(code: 5001, message: "data is nil")))
                return
            }
            // parse the data using underlying parser type
            let specificParser = R.ResponseParserType.init(ParserContext())
            let parsedData = specificParser.parse(nonEmptyData)
            guard let validParsedModel = parsedData.0 else {
                completionHandler(.failure(WDCustomError.custom(code: 5002, message: "not able to parse: \(parsedData.1) ")))
                return
            }
            completionHandler(.success(validParsedModel))
        }
        dataTask.resume()
    }
    
    
    
//    deinit {
//        session.finishTasksAndInvalidate()
//    }
}

/**
 
 open class HTTPClientCommand<SuccessParser: Parser>  {
 
 let session: HTTPSession
 
 public typealias SuccessType = SuccessParser.OutputType
 public typealias SuccessClosure<T> = (T) -> Void
 public typealias HTTPErrorClosure = (HTTPError) -> Void
 
 open var onCompleteSuccess: ((SuccessType) -> Void)?
 open var onCompleteError: ((HTTPError) -> Void)?
 
 init(session: HTTPSession?) {
 self.session = session ?? URLSession.shared
 }
 
 open func requestHeaders() -> [String: String]? {
 return nil
 }
 
 open var queryParams: [String: String]? {
 return nil
 }
 
 open var bodyDictionary: [String: String]? {
 return nil
 }
 
 open var bodyData: Data? {
 let bodyData = try? JSONSerialization.data(withJSONObject: self.bodyDictionary ?? [:], options: JSONSerialization.WritingOptions())
 return bodyData
 }
 
 @discardableResult
 open func success(_ successClosure:@escaping SuccessClosure<SuccessType>) -> Self {
 self.onCompleteSuccess = successClosure
 return self
 }
 
 @discardableResult
 open func error(_ errorClosure:@escaping HTTPErrorClosure) -> Self {
 self.onCompleteError = errorClosure
 return self
 }
 
 }
 
 */

