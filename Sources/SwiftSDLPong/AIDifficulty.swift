enum AIDifficulty {
    case easy
    case normal
    case hard

    var paddleSpeed: Float {
        switch self {
            case .easy:
                return 240
            case .normal:
                return 320
            case .hard:
                return 420
        }
    }

    var displayName: String {
        switch self {
            case .easy:
                return "Easy"
            case .normal:
                return "Normal"
            case .hard:
                return "Hard"
        }
    }
}