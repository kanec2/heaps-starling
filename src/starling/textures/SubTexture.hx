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
 * A SubTexture represents a region of another texture.
 */
class SubTexture extends Texture
{
	var _region:{x:Float, y:Float, width:Float, height:Float};
	
	/** Creates a sub-texture from a region of a parent texture. */
	public function new(parent:Texture, region:{x:Float, y:Float, width:Float, height:Float})
	{
		super();
		base = parent.base != null ? parent.base : parent;
		this.width = region.width;
		this.height = region.height;
		scale = parent.scale;
		_region = region;
	}
	
	/** The region of the parent texture. */
	public var region(get, null):{x:Float, y:Float, width:Float, height:Float};
	
	private function get_region():{x:Float, y:Float, width:Float, height:Float}
	{
		return _region;
	}
	
	override public function dispose():Void
	{
		// SubTexture doesn't own the base texture, so nothing to dispose
	}
}
