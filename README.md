# Starling Framework for Heaps

A port of the [Starling Framework](https://github.com/openfl/starling) for the [Heaps Engine](https://github.com/HeapsIO/heaps).

## About Starling

Starling is a cross-platform game engine that leverages GPU acceleration for 2D rendering. It provides a display tree API similar to Flash, making it easy to create interactive applications and games.

## Features

- GPU-accelerated 2D rendering
- Display tree with familiar API (Stage, Sprite, Image, Quad, etc.)
- Touch/mouse event handling
- Animation support
- Texture atlas support
- Particle system extensions
- Filter effects
- Text rendering with bitmap and true type fonts

## Installation

```bash
haxelib install starling-heaps
```

Or add to your `.hxml`:
```
-lib starling-heaps
```

## Usage

```haxe
import starling.core.Starling;
import starling.display.Sprite;
import starling.display.Image;
import starling.textures.Texture;

class Game extends Sprite {
    public function new() {
        super();
        
        // Create and add display objects
        var texture = Texture.fromColor(0xff0000, 100, 100);
        var image = new Image(texture);
        addChild(image);
    }
}

// Initialize Starling
Starling.start(Game, hxd.Res.initEngine());
```

## API Mapping

| Starling Class | Heaps Equivalent |
|----------------|------------------|
| Stage | h2d.Scene |
| Sprite | h2d.Object |
| DisplayObjectContainer | h2d.Object |
| Image | h2d.Bitmap / h2d.Tile |
| Quad | h2d.Graphics |
| TextField | h2d.Text |
| TouchEvent | h2d.Interactive |

## Project Structure

```
src/
└── starling/
    ├── core/           # Core classes (Starling, Stage)
    ├── display/        # Display tree classes
    ├── events/         # Event system
    ├── textures/       # Texture management
    ├── utils/          # Utilities
    ├── geom/           # Geometry classes
    ├── filters/        # Visual filters
    ├── animation/      # Animation classes
    ├── assets/         # Asset management
    ├── text/           # Text rendering
    └── extensions/     # Extensions (particles, etc.)
```

## License

BSD License - same as original Starling Framework

## Credits

- Original Starling Framework by Gamua GmbH
- Heaps Engine by Nicolas Cannasse
- This port adapts Starling's API for use with Heaps
