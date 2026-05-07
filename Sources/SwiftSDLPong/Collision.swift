import CSDL3

func intersects(_ a: SDL_FRect, _ b: SDL_FRect) -> Bool {
    a.x < b.x + b.w &&
    a.x + a.w > b.x &&
    a.y < b.y + b.h &&
    a.y + a.h > b.y
}