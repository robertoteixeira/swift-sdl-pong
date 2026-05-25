struct GameConfiguration {
    let screenWidth: Int32 = 800
    let screenHeight: Int32 = 600

    let paddleWidth: Float = 15
    let paddleHeight: Float = 100
    let ballSize: Float = 15

    let paddleSpeed: Float = 400
    let aiPaddleSpeed: Float = 320

    let initialBallSpeedX: Float = 260
    let initialBallSpeedY: Float = 180

    let paddleBounceSpeedX: Float = 300
    let maxPaddleBounceSpeedY: Float = 280

    let winningScore = 2

    let gameMode: GameMode = .singlePlayer
}