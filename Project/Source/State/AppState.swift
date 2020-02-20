import Foundation

private let AppStateTokenKey: String = "io.bedrock.AppStateTokenKey"

struct AppState: Codable {
    var token: String?

    static func persist(_ state: AppState) {
        UserDefaults.standard.set(state.token, forKey: AppStateTokenKey)
    }

    static func fromDisk() -> AppState {
        var state = AppState()
        state.token = UserDefaults.standard.string(forKey: AppStateTokenKey)
        return state
    }
}
