import CSDL3
import CSDL3TTF

final class TextRenderer {
    private var font: OpaquePointer? = nil

    init?(fontPath: String, pointSize: Float) {
        guard TTF_Init() else {
            let error = String(cString: SDL_GetError())
            print("TTF_Init failed: \(error)")
            return
        }

        let loadedFont = TTF_OpenFont(fontPath, pointSize)

        guard let loadedFont else {
            let error = String(cString: SDL_GetError())
            print("TFF_OpenFont failed: \(error)")
            TTF_Quit()
            return nil
        }

        self.font = loadedFont
    }

    deinit {
        if let font {
            TTF_CloseFont(font)
        }

        TTF_Quit()
    }

    func renderText(
        _ text: String,
        x: Float,
        y: Float,
        renderer: OpaquePointer?
    ) {
        guard let font, let renderer else {
            return
        }

        let color = SDL_Color(r: 240, g: 240, b: 240, a: 255)

        text.withCString { cText in
            guard let surface = TTF_RenderText_Blended(
                font,
                cText,
                0,
                color
            ) else {
                let error = String(cString: SDL_GetError())
                print("TTF_RenderText_Blended failed: \(error)")
                return
            }

            defer {
                SDL_DestroySurface(surface)
            }

            guard let texture = SDL_CreateTextureFromSurface(renderer, surface) else {
                let error = String(cString: SDL_GetError())
                print("SDL_CreateTextureFromSurface failed: \(error)")
                return
            }

            defer {
                SDL_DestroyTexture(texture)
            }

            var destination = SDL_FRect(
                x: x,
                y: y,
                w: Float(surface.pointee.w),
                h: Float(surface.pointee.h)
            )

            SDL_RenderTexture(renderer, texture, nil, &destination)
        }
    }
    
}