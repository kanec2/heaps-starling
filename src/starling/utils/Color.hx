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

package starling.utils;

/**
 * Utility class for color operations.
 */
class Color
{
	public static inline var WHITE:Int = 0xFFFFFF;
	public static inline var BLACK:Int = 0x000000;
	public static inline var RED:Int = 0xFF0000;
	public static inline var GREEN:Int = 0x00FF00;
	public static inline var BLUE:Int = 0x0000FF;
	
	/** Creates a color from RGB values. */
	public static function rgb(r:Int, g:Int, b:Int):Int
	{
		return (r << 16) | (g << 8) | b;
	}
	
	/** Creates a color from RGBA values. */
	public static function rgba(r:Int, g:Int, b:Int, a:Int):Int
	{
		return (a << 24) | (r << 16) | (g << 8) | b;
	}
	
	/** Gets the red component of a color. */
	public static function getRed(color:Int):Int
	{
		return (color >> 16) & 0xFF;
	}
	
	/** Gets the green component of a color. */
	public static function getGreen(color:Int):Int
	{
		return (color >> 8) & 0xFF;
	}
	
	/** Gets the blue component of a color. */
	public static function getBlue(color:Int):Int
	{
		return color & 0xFF;
	}
	
	/** Gets the alpha component of a color. */
	public static function getAlpha(color:Int):Int
	{
		return (color >> 24) & 0xFF;
	}
}
