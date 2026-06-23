import CSDL3

let digitSegments: [Int: [Int]] = [
    0: [0, 1, 2, 3, 4, 5],
    1: [1, 2],
    2: [0, 1, 6, 4, 3],
    3: [0, 1, 6, 2, 3],
    4: [5, 6, 1, 2],
    5: [0, 5, 6, 2, 3],
    6: [0, 5, 6, 4, 2, 3],
    7: [0, 1, 2],
    8: [0, 1, 2, 3, 4, 5, 6],
    9: [0, 1, 2, 3, 5, 6]
]

func renderCenterLine(renderer: OpaquePointer?, screenWidth: Int32, screenHeight: Int32) {
    let dashWidth: Float = 6
    let dashHeight: Float = 24
    let dashGap: Float = 16

    let x: Float = Float(screenWidth) / 2 - dashWidth / 2
    var y: Float = 0

    while y < Float(screenHeight) {
        var dash = SDL_FRect(
            x: x,
            y: y,
            w: dashWidth,
            h: dashHeight
        )
        SDL_RenderFillRect(renderer, &dash)
        y += dashHeight + dashGap
    }
}

func renderDigit(_ digit: Int, x: Float, y: Float, scale: Float, renderer: OpaquePointer?) {
    guard let segments = digitSegments[digit] else { return }

    let thickness = scale
    let width = scale * 6
    let height = scale * 10

    let segmentRects: [SDL_FRect] = [
        SDL_FRect(x: x + thickness, y: y, w: width - 2 * thickness, h: thickness),
        SDL_FRect(x: x + width - thickness, y: y + thickness, w: thickness, h: height / 2 - thickness),
        SDL_FRect(x: x + width - thickness, y: y + height / 2, w: thickness, h: height / 2 - thickness),
        SDL_FRect(x: x + thickness, y: y + height - thickness, w: width - 2 * thickness, h: thickness),
        SDL_FRect(x: x, y: y + height / 2, w: thickness, h: height / 2 - thickness),
        SDL_FRect(x: x, y: y + thickness, w: thickness, h: height / 2 - thickness),
        SDL_FRect(x: x + thickness, y: y + height / 2 - thickness / 2, w: width - 2 * thickness, h: thickness)
    ]

    for index in segments {
        var rect = segmentRects[index]
        SDL_RenderFillRect(renderer, &rect)
    }
}

func renderNumber(
    _ number: Int,
    x: Float,
    y: Float,
    scale: Float,
    renderer: OpaquePointer?
) {
    let digits = String(number).compactMap {Int(String($0))}

    let digitWidth = scale * 6
    let digitSpacing = scale * 2

    for(index, digit) in digits.enumerated() {
        renderDigit(
            digit,
            x: x + Float(index) * (digitWidth + digitSpacing),
            y: y,
            scale: scale,
            renderer: renderer
        )
    }
}

func renderScore(renderer: OpaquePointer?, screenWidth: Int32, leftScore: Int, rightScore: Int) {
    let scale: Float = 6
    let y: Float = 40

    let centerX = Float(screenWidth) / 2
    let digitWidth = scale * 6
    let digitSpacing = scale * 2
    let scoreGapFromCenter: Float = 45

    let leftDigitCount = max(1, String(leftScore).count)
    let rightDigitCount = max(1, String(rightScore).count)

    let leftScoreWidth = 
        Float(leftDigitCount) * digitWidth +
        Float(leftDigitCount - 1) * digitSpacing

    let rightScoreWidth = 
        Float(rightDigitCount) * digitWidth +
        Float(rightDigitCount - 1) * digitSpacing

    renderNumber(
        leftScore,
        x: centerX - scoreGapFromCenter - leftScoreWidth,
        y: y,
        scale: scale,
        renderer: renderer
    )

    renderNumber(
        rightScore,
        x: centerX + scoreGapFromCenter,
        y: y,
        scale: scale,
        renderer: renderer
    )    
}

func renderPauseIcon(renderer: OpaquePointer?, screenWidth: Int32, screenHeight: Int32) {
    let barWidth: Float = 6
    let barHeight: Float = 26
    let gap: Float = 6
    let margin: Float = 20

    let totalWidth = barWidth * 2 + gap
    let startX = Float(screenWidth) - margin - totalWidth
    let y = margin

    var leftBar = SDL_FRect(
        x: startX,
        y: y,
        w: barWidth,
        h: barHeight
    )

    var rightBar = SDL_FRect(
        x: startX + barWidth + gap,
        y: y,
        w: barWidth,
        h: barHeight
    )

    SDL_RenderFillRect(renderer, &leftBar)
    SDL_RenderFillRect(renderer, &rightBar)
}

func renderStartIndicator(renderer: OpaquePointer?, screenWidth: Int32, screenHeight: Int32) {
    let size: Float = 9
    let gap: Float = 6
    let margin: Float = 30

    let totalWidth = size * 2 - gap
    let startX = Float(screenWidth) - margin - totalWidth
    let y = margin + 8

    var leftDot = SDL_FRect(
        x: startX,
        y: y,
        w: size,
        h: size
    )

    var rightDot = SDL_FRect(
        x: startX + size + gap,
        y: y,
        w: size,
        h: size
    )

    SDL_RenderFillRect(renderer, &leftDot)
    SDL_RenderFillRect(renderer, &rightDot)
}

func renderWinnerIndicator(renderer: OpaquePointer?, screenWidth: Int32, leftScore: Int, rightScore: Int) {
    let markerWidth: Float = 42
    let markerHeight: Float = 6
    let y: Float = 112

    let centerX = Float(screenWidth) / 2

    let winnerX: Float

    if leftScore > rightScore {
        winnerX = centerX - 45 - markerWidth
    } else {
        winnerX = centerX + 45
    }

    var marker = SDL_FRect(
        x: winnerX,
        y: y,
        w: markerWidth,
        h: markerHeight
    )

    SDL_RenderFillRect(renderer, &marker)
}

func renderGame(renderer: OpaquePointer?, game: inout Game, textRenderer: TextRenderer?) {
    SDL_SetRenderDrawColor(renderer, 20, 20, 20, 255)
    SDL_RenderClear(renderer)

    SDL_SetRenderDrawColor(renderer, 240, 240, 240, 255)

    renderCenterLine(
        renderer: renderer,
        screenWidth: game.screenWidth,
        screenHeight: game.screenHeight
    )

    renderScore(
        renderer: renderer,
        screenWidth: game.screenWidth,
        leftScore: game.leftScore,
        rightScore: game.rightScore
    )

    SDL_RenderFillRect(renderer, &game.leftPaddle)
    SDL_RenderFillRect(renderer, &game.rightPaddle)
    SDL_RenderFillRect(renderer, &game.ball)

    switch game.state {
        case .waitingToStart:
            renderStartIndicator(renderer: renderer, screenWidth: game.screenWidth, screenHeight: game.screenHeight)
        case .paused:
            renderPauseIcon(renderer: renderer, screenWidth: game.screenWidth, screenHeight: game.screenHeight)
        case .gameOver:
            renderWinnerIndicator(
                renderer: renderer, 
                screenWidth: game.screenWidth, 
                leftScore: game.leftScore, 
                rightScore: game.rightScore
            )
        case .playing:
            break
    }

    switch game.state {
        case .waitingToStart:
            textRenderer?.renderText("PRESS SPACE", x: 270, y: 520, renderer: renderer)
        case .paused:
            textRenderer?.renderText("PAUSED", x: 335, y: 520, renderer: renderer)
        case .gameOver:
            let winner = game.leftScore > game.rightScore ? "LEFT WINS" : "RIGHT WINS"
            textRenderer?.renderText("\(winner) - PRESS R", x: 210, y: 520, renderer: renderer)
        case .playing:
            break
    }

    SDL_RenderPresent(renderer)
}