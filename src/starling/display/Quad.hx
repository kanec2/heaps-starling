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

package starling.display;

import starling.textures.Texture;

/** Interface for disposable objects. */
interface IDisposable
{
	function dispose():Void;
}

/**
 * A Quad represents a colored rectangle.
 * Quads are optimized for rendering and are the base class for Image.
 */
class Quad extends DisplayObject implements IDisposable
{
	var _color:Int;
	
	/** Creates a quad with a certain size and color. */
	public function new(width:Float, height:Float, color:Int = 0xFFFFFF)
	{
		super();
		this.width = width;
		this.height = height;
		_color = color;
	}
	
	/** The color of the quad. */
	public var color(get, set):Int;
	
	private function get_color():Int
	{
		return _color;
	}
	
	private function set_color(value:Int):Int
	{
		_color = value;
		return value;
	}
	
	/** Disposes the quad resources. */
	public function dispose():Void
	{
		// Nothing to dispose for basic quad
	}
}
