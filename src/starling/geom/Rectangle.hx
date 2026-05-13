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

package starling.geom;

/**
 * A Rectangle class defines a rectangular region.
 */
class Rectangle
{
	/** The x coordinate of the top-left corner. */
	public var x:Float;
	
	/** The y coordinate of the top-left corner. */
	public var y:Float;
	
	/** The width of the rectangle. */
	public var width:Float;
	
	/** The height of the rectangle. */
	public var height:Float;
	
	/** Creates a new Rectangle. */
	public function new(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0)
	{
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}
	
	/** The right edge of the rectangle (x + width). */
	public var right(get, set):Float;
	
	private function get_right():Float
	{
		return x + width;
	}
	
	private function set_right(value:Float):Float
	{
		width = value - x;
		return value;
	}
	
	/** The bottom edge of the rectangle (y + height). */
	public var bottom(get, set):Float;
	
	private function get_bottom():Float
	{
		return y + height;
	}
	
	private function set_bottom(value:Float):Float
	{
		height = value - y;
		return value;
	}
	
	/** The left edge of the rectangle. */
	public var left(get, set):Float;
	
	private function get_left():Float
	{
		return x;
	}
	
	private function set_left(value:Float):Float
	{
		x = value;
		return value;
	}
	
	/** The top edge of the rectangle. */
	public var top(get, set):Float;
	
	private function get_top():Float
	{
		return y;
	}
	
	private function set_top(value:Float):Float
	{
		y = value;
		return value;
	}
	
	/** Returns a copy of this rectangle. */
	public function clone():Rectangle
	{
		return new Rectangle(x, y, width, height);
	}
	
	/** Checks if this rectangle contains a point. */
	public function containsPoint(pointX:Float, pointY:Float):Bool
	{
		return pointX >= x && pointX < right &&
			   pointY >= y && pointY < bottom;
	}
	
	/** Checks if this rectangle intersects with another rectangle. */
	public function intersects(other:Rectangle):Bool
	{
		return !(other.right <= x || other.left >= right ||
				 other.bottom <= y || other.top >= bottom);
	}
	
	/** Returns the intersection of this rectangle with another. */
	public function intersection(other:Rectangle):Rectangle
	{
		if (!intersects(other))
		{
			return new Rectangle();
		}
		
		var resultX = Math.max(x, other.x);
		var resultY = Math.max(y, other.y);
		var resultRight = Math.min(right, other.right);
		var resultBottom = Math.min(bottom, other.bottom);
		
		return new Rectangle(resultX, resultY, resultRight - resultX, resultBottom - resultY);
	}
	
	/** Sets the values of this rectangle. */
	public function setTo(x:Float, y:Float, width:Float, height:Float):Void
	{
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}
	
	/** Returns a string representation of the rectangle. */
	public function toString():String
	{
		return '(x=$x, y=$y, w=$width, h=$height)';
	}
}
