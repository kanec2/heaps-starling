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

package starling.textures;

/**
 * A Texture represents a texture that can be mapped onto display objects.
 * This is an abstract base class - use ConcreteTexture or SubTexture instances.
 */
@:keep
class Texture
{
	/** The width of the texture in points. */
	public var width(default, null):Float;
	
	/** The height of the texture in points. */
	public var height(default, null):Float;
	
	/** The base texture (for sub-textures). */
	public var base(default, null):Texture;
	
	/** The scale factor of the texture. */
	public var scale(default, null):Float = 1.0;
	
	/** Creates a new Texture. */
	private function new()
	{
	}
	
	/**
	 * Creates a texture from a color value.
	 */
	public static function fromColor(color:Int, width:Int, height:Int):Texture
	{
		return new ConcreteTexture(width, height, color);
	}
	
	/**
	 * Creates a texture from bitmap data.
	 */
	public static function fromBitmap(data:Dynamic):Texture
	{
		// Implementation would wrap hxd.BitmapData
		return null;
	}
	
	/**
	 * Creates an empty texture with the given size.
	 */
	public static function empty(width:Int, height:Int, color:Int = 0x00000000):Texture
	{
		return new ConcreteTexture(width, height, color);
	}
	
	/**
	 * Returns a sub-texture (a region of this texture).
	 */
	public function subTexture(rect:{x:Float, y:Float, width:Float, height:Float}):Texture
	{
		return new SubTexture(this, rect);
	}
	
	/**
	 * Disposes the texture resources.
	 */
	public function dispose():Void
	{
		// To be implemented by subclasses
	}
}

/**
 * Internal concrete texture implementation.
 */
private class ConcreteTexture extends Texture
{
	var _color:Int;
	
	public function new(width:Int, height:Int, color:Int)
	{
		super();
		this.width = width;
		this.height = height;
		_color = color;
	}
	
	override public function dispose():Void
	{
		// Dispose resources
	}
}
