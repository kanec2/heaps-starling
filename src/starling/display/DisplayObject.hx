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

import starling.events.Event;
import starling.events.EventDispatcher;

/**
 * Dispatched when an object is added to a parent.
 */
@:meta(Event(name="added", type="starling.events.Event"))

/**
 * Dispatched when an object is connected to the stage (directly or indirectly).
 */
@:meta(Event(name="addedToStage", type="starling.events.Event"))

/**
 * Dispatched when an object is removed from its parent.
 */
@:meta(Event(name="removed", type="starling.events.Event"))

/**
 * Dispatched when an object is removed from the stage and won't be rendered any longer.
 */
@:meta(Event(name="removedFromStage", type="starling.events.Event"))

/**
 * The DisplayObject class is the base class for all objects that are rendered on the screen.
 * 
 * <p><strong>The Display Tree</strong></p>
 * 
 * <p>In Starling, all displayable objects are organized in a display tree. Only objects that
 * are part of the display tree will be displayed (rendered).</p>
 * 
 * <p>The display tree consists of leaf nodes (Image, Quad) that will be rendered directly to
 * the screen, and of container nodes (subclasses of "DisplayObjectContainer", like "Sprite").
 * A container is simply a display object that has child nodes - which can, again, be either
 * leaf nodes or other containers.</p>
 * 
 * <p>A display object has properties that define its position in relation to its parent
 * (x, y), as well as its rotation and scaling factors (scaleX, scaleY).</p>
 */
class DisplayObject extends EventDispatcher
{
	/** The x coordinate of the object relative to its parent. */
	public var x:Float = 0.0;
	
	/** The y coordinate of the object relative to its parent. */
	public var y:Float = 0.0;
	
	/** The width of the object. */
	public var width(default, set):Float = 0.0;
	
	/** The height of the object. */
	public var height(default, set):Float = 0.0;
	
	/** The scale factor along the x-axis. */
	public var scaleX:Float = 1.0;
	
	/** The scale factor along the y-axis. */
	public var scaleY:Float = 1.0;
	
	/** The rotation of the object in radians. */
	public var rotation:Float = 0.0;
	
	/** The alpha (transparency) value of the object (0.0 to 1.0). */
	public var alpha:Float = 1.0;
	
	/** Indicates whether the object is visible. */
	public var visible:Bool = true;
	
	/** Indicates whether the object can receive touch events. */
	public var touchable:Bool = true;
	
	/** The name of the display object. */
	public var name:String = "";
	
	/** The parent container of this display object. */
	public var parent(default, null):DisplayObjectContainer = null;
	
	/** Creates a new DisplayObject. */
	public function new()
	{
		super();
	}
	
	private function set_width(value:Float):Float
	{
		width = value;
		return value;
	}
	
	private function set_height(value:Float):Float
	{
		height = value;
		return value;
	}
	
	/**
	 * Adds the object to a parent container.
	 */
	function setParent(parent:DisplayObjectContainer):Void
	{
		this.parent = parent;
	}
	
	/**
	 * Removes the object from its parent.
	 */
	public function removeFromParent(dispose:Bool = false):Void
	{
		if (parent != null)
		{
			parent.removeChild(this, dispose);
		}
	}
	
	/**
	 * Converts a point from the local coordinate system to global (stage) coordinates.
	 */
	public function localToGlobal(localPoint:{x:Float, y:Float}):{x:Float, y:Float}
	{
		var globalPoint = {x: localPoint.x, y: localPoint.y};
		
		var current:DisplayObject = this;
		while (current != null)
		{
			var rotatedX = globalPoint.x * Math.cos(current.rotation) - globalPoint.y * Math.sin(current.rotation);
			var rotatedY = globalPoint.x * Math.sin(current.rotation) + globalPoint.y * Math.cos(current.rotation);
			
			globalPoint.x = rotatedX * current.scaleX + current.x;
			globalPoint.y = rotatedY * current.scaleY + current.y;
			
			current = current.parent;
		}
		
		return globalPoint;
	}
	
	/**
	 * Converts a point from global (stage) coordinates to the local coordinate system.
	 */
	public function globalToLocal(globalPoint:{x:Float, y:Float}):{x:Float, y:Float}
	{
		// Simplified implementation - full version would need matrix transformations
		return {x: globalPoint.x - x, y: globalPoint.y - y};
	}
	
	/**
	 * Returns the bounds of the object in the coordinate space of another object.
	 */
	public function getBounds(space:DisplayObject = null):{x:Float, y:Float, width:Float, height:Float}
	{
		if (space == null || space == this)
		{
			return {x: 0, y: 0, width: width, height: height};
		}
		
		// Simplified - would need proper matrix transformation for full implementation
		return {x: x, y: y, width: width, height: height};
	}
	
	/**
	 * Checks if a point is inside the bounds of this object.
	 */
	public function hitTest(localPoint:{x:Float, y:Float}):Bool
	{
		return localPoint.x >= 0 && localPoint.x <= width &&
			   localPoint.y >= 0 && localPoint.y <= height;
	}
}
