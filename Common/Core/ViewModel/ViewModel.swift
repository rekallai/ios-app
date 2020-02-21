import Foundation
import Moya
import CoreData

class ViewModel: NSObject {
    let api: APIProvider
    
    let store: Store
    
    init(api: APIProvider, store: Store) {
        self.api = api
        self.store = store
    }
    
    @discardableResult
    func request(
        _ target: ADBaseRequest,
        callbackQueue: DispatchQueue? = .none,
        progress: ProgressBlock? = .none,
        completion: @escaping (_ result: Result<Moya.Response, APIError>) -> Void
    ) -> Cancellable {
        let queue = callbackQueue ?? store.coreDataDispatchQueue
        return api.storeRequest(target, callbackQueue: queue, progress: progress, completion: {
            [weak self] result in
            
            if case .failure(let error) = result {
                self?.handleApiError(error: error)
            }
            
            completion(result)
        })
    }
    
    private func handleApiError(error: APIError) {
        switch error {
        case .tokenExpired:
            store.signOut()
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.apiTokenExpired, object: nil)
            }
        default:
            break
        }
    }
    
    var isAuthenticated: Bool {
        return store.isAuthenticated
    }
    
    func decodeResponse<D: Decodable>(_ type: D.Type, response: Moya.Response, moc: NSManagedObjectContext?) throws -> D {
        let decoder = baseDecoder()

        if let workMoc = moc {
            decoder.userInfo[CodingUserInfoKey.managedObjectContext] = workMoc
        }
        
        let result = try response.map(type, using: decoder)
        return result
    }
    
    func decodeData<D: Decodable>(_ type: D.Type, data: Data, moc: NSManagedObjectContext?) throws -> D {
        let decoder = baseDecoder()

        if let workMoc = moc {
            decoder.userInfo[CodingUserInfoKey.managedObjectContext] = workMoc
        }
        
        let result = try decoder.decode(type, from: data)
        return result
    }
    
    func decodeResponse<D: Decodable>(_ type: D.Type, response: Moya.Response) throws -> D {
        return try response.map(type, using: baseDecoder())
    }
    
    func baseDecoder()->JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        return decoder
    }
}
