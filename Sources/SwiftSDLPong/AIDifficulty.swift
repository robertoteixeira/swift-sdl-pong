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
}