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

func renderScore(renderer: OpaquePointer?, screenWidth: Int32, leftScore: Int, rightScore: Int) {
    let scale: Float = 6
    let y: Float = 40

    let centerX = Float(screenWidth) / 2
    let digitWidth = scale * 6
    let scoreGapFromCenter: Float = 45

    renderDigit(
        leftScore % 10,
        x: centerX - scoreGapFromCenter - digitWidth,
        y: y,
        scale: scale,
        renderer: renderer
    )

    renderDigit(
        rightScore % 10,
        x: centerX + scoreGapFromCenter,
        y: y,
        scale: scale,
        renderer: renderer
    )    
}

func renderGame(renderer: OpaquePointer?, game: inout Game) {
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

    SDL_RenderPresent(renderer)
}