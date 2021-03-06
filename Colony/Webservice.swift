
import Foundation
import Moya
import PromiseKit

enum HTTPError: Error, CustomStringConvertible {
    case networkError(code: Int)
    case parsingError(message: String)
    
    var description: String {
        switch self {
        case .networkError(let code):
            return "Network error with code \(code)"
        case .parsingError(let message):
            return "Unable to parse object \(message)"
        }
    }
}

final class WebService {
    
    static let shared = WebService()
    private let provider = MoyaProvider<MultiTarget>()
    //private let cache = Cache.shared
    
    private init () { }
    
    private func request(target: TargetType, success successCallback: @escaping (Response) -> Void, error errorCallback: @escaping (HTTPError) -> Void, failure failureCallback: @escaping (MoyaError) -> Void) {
        provider.request(MultiTarget(target)) { (result) in
            switch result {
            case .success(let response):
                if response.statusCode >= 200 && response.statusCode <= 300 {
                    successCallback(response)
                } else {
                    let error = HTTPError.networkError(code: response.statusCode)
                    errorCallback(error)
                }
            case .failure(let error):
                failureCallback(error)
            }
        }
    }
    
    func load<T>(_ resource: Resource<T>) -> Promise<T> {
        let target = resource.target
        return Promise { fulfill, reject in
            self.request(target: target, success: { (response) in
                //self.saveDataToCache(data: response.data, for: resource)
                if let objects = resource.parse(response.data) {
                    fulfill(objects)
                } else {
                    let error = HTTPError.parsingError(message: "ERROR: parsing \(type(of: T.self))")
                    reject(error)
                }
            }, error: { (httpError) in
                reject(httpError)
            }, failure: { (moyaError) in
                reject(moyaError)
            })
        }
    }
    
//    func saveDataToCache<T>(data: Data, for resource: Resource<T>) {
//        switch resource.target {
//        case is ServerAPI:
//            self.cache.saveData(data, for: resource, cacheKey: CacheKey.movies)
//        case is OMDbAPI:
//            self.cache.saveData(data, for: resource, cacheKey: OMDbAPI.cacheKey)
//        default: break
//        }
//    }
    
}


