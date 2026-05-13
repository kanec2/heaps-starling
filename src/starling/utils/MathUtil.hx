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
 * Utility class for math operations.
 */
class MathUtil
{
	public static inline var PI:Float = Math.PI;
	public static inline var TWO_PI:Float = Math.PI * 2.0;
	public static inline var HALF_PI:Float = Math.PI / 2.0;
	
	/** Converts degrees to radians. */
	public static function degreesToRadians(degrees:Float):Float
	{
		return degrees * PI / 180.0;
	}
	
	/** Converts radians to degrees. */
	public static function radiansToDegrees(radians:Float):Float
	{
		return radians * 180.0 / PI;
	}
	
	/** Clamps a value between min and max. */
	public static function clamp(value:Float, min:Float, max:Float):Float
	{
		if (value < min) return min;
		if (value > max) return max;
		return value;
	}
	
	/** Linear interpolation between two values. */
	public static function lerp(a:Float, b:Float, t:Float):Float
	{
		return a + (b - a) * t;
	}
	
	/** Maps a value from one range to another. */
	public static function map(value:Float, fromMin:Float, fromMax:Float, toMin:Float, toMax:Float):Float
	{
		return toMin + (value - fromMin) * (toMax - toMin) / (fromMax - fromMin);
	}
	
	/** Returns true if value is approximately equal to target within epsilon. */
	public static function approxEqual(a:Float, b:Float, epsilon:Float = 0.0001):Bool
	{
		return Math.abs(a - b) < epsilon;
	}
}
