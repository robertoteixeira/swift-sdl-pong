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

    func renderCenteredText(
        _ text: String,
        centerX: Float,
        y: Float,
        renderer: OpaquePointer?
    ) {
        guard let size = textSize(text) else { return }

        let x = centerX - Float(size.width) / 2

        renderText(
            text, 
            x: x,
            y: y,
            renderer: renderer
        )
    }

    func textSize(_ text: String) -> (width: Int32, height: Int32)? {
        guard let font else { return nil }

        var width: Int32 = 0
        var height: Int32 = 0

        let success = text.withCString { cText in
            TTF_GetStringSize(
                font,
                cText,
                0,
                &width,
                &height
            )
        }

        guard success else {
            let error = String(cString: SDL_GetError())
            print("TTF_GetStringSize failed: \(error)")
            return nil
        }

        return (width, height)
    }
    
}