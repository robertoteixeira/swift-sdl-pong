import CSDL3

struct Game {
    let configuration: GameConfiguration

    var screenWidth: Int32 {
        configuration.screenWidth
    }

    var screenHeight: Int32 {
        configuration.screenHeight
    }

    var leftPaddle: SDL_FRect
    var rightPaddle: SDL_FRect
    var ball: SDL_FRect

    var ballVelocityX: Float
    var ballVelocityY: Float

    var leftScore = 0
    var rightScore = 0

    var state: GameState = .waitingToStart

    init(configuration: GameConfiguration) {
        self.configuration = configuration
        
        self.ballVelocityX = configuration.initialBallSpeedX
        self.ballVelocityY = configuration.initialBallSpeedY

        self.leftPaddle = SDL_FRect(
            x: 40,
            y: Float(configuration.screenHeight) / 2 - configuration.paddleHeight / 2,
            w: configuration.paddleWidth,
            h: configuration.paddleHeight
        )

        self.rightPaddle = SDL_FRect(
            x: Float(configuration.screenWidth) - 40 - configuration.paddleWidth,
            y: Float(configuration.screenHeight) / 2 - configuration.paddleHeight / 2,
            w: configuration.paddleWidth,
            h: configuration.paddleHeight
        )

        self.ball = SDL_FRect(
            x: Float(configuration.screenWidth) / 2 - configuration.ballSize / 2,
            y: Float(configuration.screenHeight) / 2 - configuration.ballSize / 2,
            w: configuration.ballSize,
            h: configuration.ballSize
        )

        resetBall(towardsLeft: Bool.random())
        print("Press Space to start")
    }

    mutating func start() {
        guard state == .waitingToStart else { return }

        state = .playing
        print("Game started")
    }

    mutating func togglePause() {
        if state == .playing {
            state = .paused
            print("Paused")
        } else if state == .paused {
            state = .playing
            print("Resumed")
        }
    }

    mutating func restart() {
        leftScore = 0
        rightScore = 0

        leftPaddle.y = Float(screenHeight) / 2 - leftPaddle.h / 2
        rightPaddle.y = Float(screenHeight) / 2 - rightPaddle.h / 2

        resetBall(towardsLeft: Bool.random())

        state = .waitingToStart
        print("Press Space to start")
    }

    mutating func update(deltaTime: Float, keyboardState: UnsafePointer<Bool>?) {
        guard state == .playing else { return }

        handleInput(deltaTime: deltaTime, keyboardState: keyboardState)
        clampPaddles()
        updateBall(deltaTime: deltaTime)
        handleWallCollision()
        handlePaddleCollision()
        handleScoring()
    }

    private mutating func handleInput(deltaTime: Float, keyboardState: UnsafePointer<Bool>?) {
        guard let keyboardState else { return }

        handleLeftPlayerInput(deltaTime: deltaTime, keyboardState: keyboardState)

        switch configuration.gameMode {
            case .singlePlayer:
                updateAIPaddle(deltaTime: deltaTime)
            break
            case .twoPlayers:
                handleRightPlayerInput(deltaTime: deltaTime, keyboardState: keyboardState)
        }
    }

    private mutating func handleLeftPlayerInput(deltaTime: Float, keyboardState: UnsafePointer<Bool>) {
        if keyboardState[Int(SDL_SCANCODE_W.rawValue)] {
            leftPaddle.y -= configuration.paddleSpeed * deltaTime
        }

        if keyboardState[Int(SDL_SCANCODE_S.rawValue)] {
            leftPaddle.y += configuration.paddleSpeed * deltaTime
        }
    }

    private mutating func handleRightPlayerInput(deltaTime: Float, keyboardState: UnsafePointer<Bool>) {
        if keyboardState[Int(SDL_SCANCODE_UP.rawValue)] {
            rightPaddle.y -= configuration.paddleSpeed * deltaTime
        }

        if keyboardState[Int(SDL_SCANCODE_DOWN.rawValue)] {
            rightPaddle.y += configuration.paddleSpeed * deltaTime
        }
    }

    private mutating func updateAIPaddle(deltaTime: Float) {
        let ballCenterY = ball.y + ball.h / 2
        let paddleCenterY = rightPaddle.y + rightPaddle.h / 2

        if ballCenterY < paddleCenterY {
            rightPaddle.y -= configuration.aiPaddleSpeed * deltaTime
        } else if ballCenterY > paddleCenterY {
            rightPaddle.y += configuration.aiPaddleSpeed * deltaTime
        }
    }    

    private mutating func clampPaddles() {
        leftPaddle.y = max(0, min(leftPaddle.y, Float(screenHeight) - leftPaddle.h))
        rightPaddle.y = max(0, min(rightPaddle.y, Float(screenHeight) - rightPaddle.h))
    }

    private mutating func updateBall(deltaTime: Float) {
        ball.x += ballVelocityX * deltaTime
        ball.y += ballVelocityY * deltaTime
    }

    private mutating func handleWallCollision() {
        if ball.y <= 0 {
            ball.y = 0
            ballVelocityY *= -1
        }

        if ball.y + ball.h > Float(screenHeight) {
            ball.y = Float(screenHeight) - ball.h
            ballVelocityY *= -1
        }
    }

    private mutating func handlePaddleCollision() {
        if intersects(ball, leftPaddle), ballVelocityX < 0 {
            ball.x = leftPaddle.x + leftPaddle.w
            applyPaddleBounce(paddle: leftPaddle, movingRight: true)
        }

        if intersects(ball, rightPaddle), ballVelocityX > 0 {
            ball.x = rightPaddle.x - ball.w
            applyPaddleBounce(paddle: rightPaddle, movingRight: false)
        }
    }

    private mutating func handleScoring() {
        if ball.x + ball.w < 0 {
            rightScore += 1
            print("Left \(leftScore) - \(rightScore) Right")

            if rightScore >= configuration.winningScore {
                state = .gameOver
                print("Right player wins. Press R to restart.")
            } else {
                resetBall(towardsLeft: false)
            }
        }

        if ball.x > Float(screenWidth) {
            leftScore += 1
            print("Left \(leftScore) - \(rightScore) Right")

            if leftScore >= configuration.winningScore {
                state = .gameOver
                print("Left player wins. Press R to restart.")
            } else {
                resetBall(towardsLeft: true)
            }
        }
    }

    private mutating func resetBall(towardsLeft: Bool) {
        ball.x = Float(screenWidth) / 2 - ball.w / 2
        ball.y = Float(screenHeight) / 2 - ball.h / 2

        ballVelocityX = towardsLeft ? -configuration.initialBallSpeedX : configuration.initialBallSpeedX
        ballVelocityY = Bool.random() ? -configuration.initialBallSpeedY : configuration.initialBallSpeedY
    }

    private mutating func applyPaddleBounce(paddle: SDL_FRect, movingRight: Bool) {
        let ballCenterY = ball.y + ball.h / 2
        let paddleCenterY = paddle.y + paddle.h / 2

        let distanceFromCenter = ballCenterY - paddleCenterY
        let normalizedDistance = distanceFromCenter / (paddle.h / 2)

        ballVelocityX = movingRight ? configuration.paddleBounceSpeedX : -configuration.paddleBounceSpeedX
        ballVelocityY = normalizedDistance * configuration.maxPaddleBounceSpeedY
    }
}