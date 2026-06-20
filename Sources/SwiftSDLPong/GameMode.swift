enum GameMode {
    case singlePlayer
    case twoPlayers

    var displayName: String {
        switch self {
            case .singlePlayer:
                return "Single Player"
            case .twoPlayers:
                return "Two Players"
        }        
    }

    mutating func toggle() {
        switch self {
            case .singlePlayer:
                self = .twoPlayers
            case .twoPlayers:
                self = .singlePlayer
        }
    }
}