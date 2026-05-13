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
import starling.textures.SubTexture;

/**
 * An Image is a quad with a texture mapped onto it.
 * It's one of the most commonly used display objects in Starling.
 */
class Image extends Quad
{
	var _texture:Texture;
	var _smoothing:String = "none";
	
	/** Creates an image with a texture. */
	public function new(texture:Texture = null)
	{
		var width:Float = 0;
		var height:Float = 0;
		
		if (texture != null)
		{
			width = texture.width;
			height = texture.height;
		}
		
		super(width, height);
		_texture = texture;
	}
	
	/** The texture that is displayed on the image. */
	public var texture(get, set):Texture;
	
	private function get_texture():Texture
	{
		return _texture;
	}
	
	private function set_texture(value:Texture):Texture
	{
		_texture = value;
		
		if (value != null)
		{
			width = value.width;
			height = value.height;
		}
		
		return value;
	}
	
	/** The smoothing mode for the texture. */
	public var smoothing(get, set):String;
	
	private function get_smoothing():String
	{
		return _smoothing;
	}
	
	private function set_smoothing(value:String):String
	{
		_smoothing = value;
		return value;
	}
	
	/** Sets the texture rectangle (for displaying only a part of the texture). */
	public function setTextureRect(rect:{x:Float, y:Float, width:Float, height:Float}):Void
	{
		if (_texture != null)
		{
			_texture = new SubTexture(_texture, rect);
		}
	}
	
	/** Resets the texture rectangle to show the full texture. */
	public function resetTextureRect():Void
	{
		// Implementation would restore original texture
	}
}
