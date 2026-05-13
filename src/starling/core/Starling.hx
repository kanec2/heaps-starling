// =================================================================================================
//
//	Starling Framework for Heaps
//	Copyright Gamua GmbH. All Rights Reserved.
//	Ported to Heaps Engine
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.core;

import hxd.Timer;
import hxd.App;
import h2d.Graphics;
import h2d.Bitmap;
import h2d.Object;
import h2d.Tile;
import h2d.Scene;
import h3d.Vector;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.EventDispatcher;
import starling.textures.Texture;

/**
 * Dispatched when the Starling instance is initialized and ready.
 */
@:meta(Event(name="ready", type="starling.events.Event"))

/**
 * Dispatched when the context is lost (e.g., device sleep).
 */
@:meta(Event(name="contextLost", type="starling.events.Event"))

/**
 * Dispatched when the context is restored after being lost.
 */
@:meta(Event(name="contextRestored", type="starling.events.Event"))

/**
 * The Starling class represents the core of the Starling framework.
 * 
 * <p>It manages the scene graph, the render loop, and integrates with the Heaps engine.</p>
 * 
 * <p><strong>Initialization</strong></p>
 * 
 * <p>To start Starling, create an instance and pass it your root display object:</p>
 * 
 * <pre>
 * var starling = new Starling(new MyRootSprite(), stage);
 * starling.start();
 * </pre>
 * 
 * <p>The Starling instance will then render your content at 60 FPS (or the target frame rate).</p>
 */
class Starling extends EventDispatcher
{
	/** The version of the Starling framework. */
	public static inline var VERSION:String = "2.0.0-heaps";
	
	/** The current Starling instance. */
	public static var current(default, null):Starling;
	
	/** The root display object of this Starling instance. */
	public var root(default, null):DisplayObjectContainer;
	
	/** The stage (top-level container) of this Starling instance. */
	public var stage(default, null):Sprite;
	
	/** Indicates whether Starling is currently running. */
	public var isRunning(default, null):Bool = false;
	
	/** The target frame rate (in frames per second). */
	public var frameRate:Float = 60.0;
	
	/** The time scale factor (1.0 = normal speed). */
	public var timeScale:Float = 1.0;
	
	/** The background color of the stage. */
	public var backgroundColor:Int = 0x000000;
	
	/** Indicates whether smoothing (anti-aliasing) is enabled. */
	public var supportHighResolutions:Bool = true;
	
	/** The width of the viewport in points. */
	public var width(default, null):Float = 0.0;
	
	/** The height of the viewport in points. */
	public var height(default, null):Float = 0.0;
	
	/** The underlying Heaps scene. */
	public var heapsScene(default, null):Scene;
	
	/** The graphics context for rendering. */
	var _graphics:h2d.Graphics;
	
	/** The last frame's time for delta calculation. */
	var _lastTime:Float = 0.0;
	
	/** Accumulated time for frame timing. */
	var _accumulatedTime:Float = 0.0;
	
	/** Frame interval in seconds. */
	var _frameInterval:Float;
	
	/** Callback for advanced rendering. */
	var _renderCallback:Void->Void;
	
	/**
	 * Creates a new Starling instance.
	 * 
	 * @param rootClass The class that will be instantiated as the root display object.
	 * @param heapsScene The Heaps scene to render into. If null, uses hxd.Stage's scene.
	 */
	public function new(rootClass:Class<DisplayObjectContainer>, ?heapsScene:Scene)
	{
		super();
		
		Starling.current = this;
		
		// Set up the Heaps scene
		this.heapsScene = heapsScene != null ? heapsScene : App.instance.scene;
		
		// Create the stage (top-level container)
		stage = new Sprite();
		root = stage;
		
		// Initialize dimensions
		width = Std.int(heapsScene.width);
		height = Std.int(heapsScene.height);
		
		// Calculate frame interval
		_frameInterval = 1.0 / frameRate;
		
		// Create graphics context if needed
		_graphics = new Graphics(this.heapsScene);
		
		// Instantiate the root display object
		if (rootClass != null)
		{
			try {
				var rootInstance = Type.createInstance(rootClass, []);
				stage.addChild(rootInstance);
			} catch (e:Dynamic) {
				trace("Warning: Could not instantiate root class: " + e);
			}
		}
		
		// Listen for resize events
		App.instance.addEventTarget(onAppResize, [hxd.EventKind.Resize]);
	}
	
	/**
	 * Starts the render loop.
	 */
	public function start():Void
	{
		if (isRunning)
			return;
		
		isRunning = true;
		_lastTime = Timer.time;
		
		// Register update callback
		App.instance.addEventTarget(onFrame, [hxd.EventKind.EnterFrame]);
		
		// Dispatch ready event
		dispatchEvent(new Event(Event.READY));
	}
	
	/**
	 * Stops the render loop.
	 */
	public function stop():Void
	{
		if (!isRunning)
			return;
		
		isRunning = false;
		
		// Remove update callback
		App.instance.removeEventTarget(onFrame, [hxd.EventKind.EnterFrame]);
	}
	
	/**
	 * Advances the simulation by the given time delta.
	 * 
	 * @param passedTime Time elapsed since the last frame in seconds.
	 */
	public function advanceTime(passedTime:Float):Void
	{
		if (passedTime <= 0)
			return;
		
		// Apply time scale
		var scaledTime = passedTime * timeScale;
		
		// Update all display objects in the tree
		if (stage != null)
		{
			updateDisplayObject(stage, scaledTime);
		}
	}
	
	/**
	 * Recursively updates a display object and its children.
	 */
	private function updateDisplayObject(obj:DisplayObject, passedTime:Float):Void
	{
		// Call advanceTime if the object has it (for MovieClip, etc.)
		if (Reflect.hasField(obj, "advanceTime"))
		{
			Reflect.callMethod(obj, Reflect.field(obj, "advanceTime"), [passedTime]);
		}
		
		// Update children if it's a container
		if (Std.is(obj, DisplayObjectContainer))
		{
			var container:DisplayObjectContainer = cast obj;
			for (i in 0...container.numChildren)
			{
				var child = container.getChildAt(i);
				if (child != null)
				{
					updateDisplayObject(child, passedTime);
				}
			}
		}
	}
	
	/**
	 * Renders the complete display tree.
	 */
	public function render():Void
	{
		if (stage == null || !stage.visible)
			return;
		
		// Clear graphics
		_graphics.clear();
		
		// Begin batch rendering
		_graphics.beginFill(backgroundColor);
		_graphics.drawRect(0, 0, width, height);
		_graphics.endFill();
		
		// Render the display tree
		renderDisplayObject(stage, _graphics);
		
		// Execute custom render callback if set
		if (_renderCallback != null)
		{
			_renderCallback();
		}
	}
	
	/**
	 * Recursively renders a display object and its children.
	 */
	private function renderDisplayObject(obj:DisplayObject, graphics:h2d.Graphics, ?parentTransform:h3d.Matrix):Void
	{
		if (!obj.visible || obj.alpha <= 0)
			return;
		
		// Build transformation matrix
		var transform = parentTransform != null ? parentTransform.clone() : new h3d.Matrix();
		
		// Apply transformations
		transform.translate(obj.x, obj.y);
		if (obj.rotation != 0)
		{
			var cos = Math.cos(obj.rotation);
			var sin = Math.sin(obj.rotation);
			transform.rotate(obj.rotation);
		}
		transform.scale(obj.scaleX, obj.scaleY);
		
		// Render specific object types
		if (Std.is(obj, starling.display.Quad))
		{
			renderQuad(cast obj, graphics, transform);
		}
		else if (Std.is(obj, starling.display.Image))
		{
			renderImage(cast obj, graphics, transform);
		}
		
		// Render children if it's a container
		if (Std.is(obj, DisplayObjectContainer))
		{
			var container:DisplayObjectContainer = cast obj;
			for (i in 0...container.numChildren)
			{
				var child = container.getChildAt(i);
				if (child != null)
				{
					renderDisplayObject(child, graphics, transform);
				}
			}
		}
	}
	
	/**
	 * Renders a Quad object.
	 */
	private function renderQuad(quad:starling.display.Quad, graphics:h2d.Graphics, transform:h3d.Matrix):Void
	{
		graphics.save();
		
		// Apply transformation
		applyTransform(graphics, transform);
		
		// Draw colored rectangle
		graphics.beginFill(quad.color, quad.alpha);
		graphics.drawRect(0, 0, quad.width, quad.height);
		graphics.endFill();
		
		graphics.restore();
	}
	
	/**
	 * Renders an Image object.
	 */
	private function renderImage(image:starling.display.Image, graphics:h2d.Graphics, transform:h3d.Matrix):Void
	{
		if (image.texture == null)
			return;
		
		graphics.save();
		
		// Apply transformation
		applyTransform(graphics, transform);
		
		// Get Heaps tile from Starling texture
		var tile = getTileFromTexture(image.texture);
		if (tile != null)
		{
			graphics.fill(tile);
		}
		
		graphics.restore();
	}
	
	/**
	 * Applies a transformation matrix to the graphics context.
	 */
	private function applyTransform(graphics:h2d.Graphics, matrix:h3d.Matrix):Void
	{
		// Extract translation
		var tx = matrix._41;
		var ty = matrix._42;
		
		// Extract scale and rotation from the matrix
		var scaleX = Math.sqrt(matrix._11 * matrix._11 + matrix._12 * matrix._12);
		var scaleY = Math.sqrt(matrix._21 * matrix._21 + matrix._22 * matrix._22);
		var rotation = Math.atan2(matrix._12, matrix._11);
		
		graphics.translate(tx, ty);
		if (rotation != 0)
			graphics.rotate(rotation);
		if (scaleX != 1 || scaleY != 1)
			graphics.scale(scaleX, scaleY);
	}
	
	/**
	 * Converts a Starling Texture to a Heaps Tile.
	 */
	private function getTileFromTexture(texture:Texture):Tile
	{
		// This would need proper integration with Heaps textures
		// For now, return a placeholder
		return null;
	}
	
	/**
	 * Called on each frame to update and render.
	 */
	private function onFrame(event:hxd.Event):Void
	{
		if (!isRunning)
			return;
		
		var currentTime = Timer.time;
		var passedTime = currentTime - _lastTime;
		_lastTime = currentTime;
		
		// Accumulate time for frame stepping
		_accumulatedTime += passedTime;
		
		// Step through frames at target frame rate
		while (_accumulatedTime >= _frameInterval)
		{
			advanceTime(_frameInterval);
			_accumulatedTime -= _frameInterval;
		}
		
		// Render
		render();
	}
	
	/**
	 * Called when the application window is resized.
	 */
	private function onAppResize(event:hxd.Event):Void
	{
		width = Std.int(App.instance.windowWidth);
		height = Std.int(App.instance.windowHeight);
		
		if (heapsScene != null)
		{
			heapsScene.resize(width, height);
		}
		
		// Dispatch resize event
		dispatchEvent(new Event(Event.RESIZE));
	}
	
	/**
	 * Sets a custom render callback.
	 */
	public function setRenderCallback(callback:Void->Void):Void
	{
		_renderCallback = callback;
	}
	
	/**
	 * Makes a display object the new root.
	 */
	public function setRoot(rootObj:DisplayObjectContainer):Void
	{
		if (root != null && root.parent == stage)
		{
			stage.removeChild(root);
		}
		
		root = rootObj;
		if (root != null)
		{
			stage.addChild(root);
		}
	}
	
	/**
	 * Disposes the Starling instance and all its resources.
	 */
	public function dispose():Void
	{
		stop();
		
		if (stage != null)
		{
			stage.dispose();
			stage = null;
		}
		
		if (_graphics != null)
		{
			_graphics.remove();
			_graphics = null;
		}
		
		Starling.current = null;
	}
	
	/**
	 * Returns the bounds of the stage.
	 */
	public function getStageBounds():{x:Float, y:Float, width:Float, height:Float}
	{
		return {x: 0, y: 0, width: width, height: height};
	}
}
