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

/**
 * A DisplayObjectContainer represents a collection of display objects.
 * It is the base class for all display objects that act as containers.
 */
class DisplayObjectContainer extends DisplayObject
{
	/** An array containing all children of this container. */
	var _children:Array<DisplayObject>;
	
	/** Creates a new DisplayObjectContainer. */
	public function new()
	{
		super();
		_children = [];
	}
	
	/** Returns the number of children in this container. */
	public var numChildren(default, null):Int = 0;
	
	/**
	 * Adds a child to the container.
	 */
	public function addChild(child:DisplayObject):DisplayObject
	{
		if (child == null) return null;
		
		// Remove from previous parent
		if (child.parent != null)
		{
			child.parent.removeChild(child);
		}
		
		_children.push(child);
		child.setParent(this);
		numChildren = _children.length;
		
		// Dispatch added event
		child.dispatchEvent(new Event(Event.ADDED));
		
		// If this container is on stage, dispatch addedToStage for child
		dispatchAddedToStageRecursively(child);
		
		return child;
	}
	
	/**
	 * Adds a child at a specific index.
	 */
	public function addChildAt(child:DisplayObject, index:Int):DisplayObject
	{
		if (child == null) return null;
		
		if (index < 0 || index > _children.length)
		{
			throw "Index out of bounds";
		}
		
		// Remove from previous parent
		if (child.parent != null)
		{
			child.parent.removeChild(child);
		}
		
		_children.insert(index, child);
		child.setParent(this);
		numChildren = _children.length;
		
		child.dispatchEvent(new Event(Event.ADDED));
		dispatchAddedToStageRecursively(child);
		
		return child;
	}
	
	/**
	 * Removes a child from the container.
	 */
	public function removeChild(child:DisplayObject, dispose:Bool = false):DisplayObject
	{
		if (child == null) return null;
		
		var index = _children.indexOf(child);
		if (index >= 0)
		{
			return removeChildAt(index, dispose);
		}
		
		return null;
	}
	
	/**
	 * Removes a child at a specific index.
	 */
	public function removeChildAt(index:Int, dispose:Bool = false):DisplayObject
	{
		if (index < 0 || index >= _children.length)
		{
			throw "Index out of bounds";
		}
		
		var child = _children[index];
		_children.splice(index, 1);
		child.setParent(null);
		numChildren = _children.length;
		
		child.dispatchEvent(new Event(Event.REMOVED));
		dispatchRemovedFromStageRecursively(child);
		
		if (dispose && child is IDisposable)
		{
			cast(child, IDisposable).dispose();
		}
		
		return child;
	}
	
	/**
	 * Removes all children from the container.
	 */
	public function removeChildren(beginIndex:Int = 0, endIndex:Int = -1, dispose:Bool = false):Void
	{
		if (endIndex < 0) endIndex = _children.length - 1;
		
		for (i in 0...(endIndex - beginIndex + 1))
		{
			removeChildAt(beginIndex, dispose);
		}
	}
	
	/**
	 * Returns the child at a specific index.
	 */
	public function getChildAt(index:Int):DisplayObject
	{
		if (index < 0 || index >= _children.length)
		{
			throw "Index out of bounds";
		}
		return _children[index];
	}
	
	/**
	 * Returns the index of a child.
	 */
	public function getChildIndex(child:DisplayObject):Int
	{
		return _children.indexOf(child);
	}
	
	/**
	 * Sets the index of a child.
	 */
	public function setChildIndex(child:DisplayObject, index:Int):Void
	{
		var oldIndex = _children.indexOf(child);
		if (oldIndex < 0)
		{
			throw "Child not found";
		}
		
		_children.splice(oldIndex, 1);
		_children.insert(index, child);
	}
	
	/**
	 * Swaps the positions of two children.
	 */
	public function swapChildren(child1:DisplayObject, child2:DisplayObject):Void
	{
		var index1 = _children.indexOf(child1);
		var index2 = _children.indexOf(child2);
		
		if (index1 < 0 || index2 < 0)
		{
			throw "Child not found";
		}
		
		swapChildrenAt(index1, index2);
	}
	
	/**
	 * Swaps the positions of two children at specific indices.
	 */
	public function swapChildrenAt(index1:Int, index2:Int):Void
	{
		if (index1 < 0 || index1 >= _children.length ||
			index2 < 0 || index2 >= _children.length)
		{
			throw "Index out of bounds";
		}
		
		var temp = _children[index1];
		_children[index1] = _children[index2];
		_children[index2] = temp;
	}
	
	/**
	 * Checks if an object is a child of this container.
	 */
	public function contains(child:DisplayObject):Bool
	{
		return _children.indexOf(child) >= 0;
	}
	
	/**
	 * Recursively dispatches ADDED_TO_STAGE events.
	 */
	function dispatchAddedToStageRecursively(child:DisplayObject):Void
	{
		// Simplified - full implementation would check if parent is on stage
		child.dispatchEvent(new Event(Event.ADDED_TO_STAGE));
		
		if (child is DisplayObjectContainer)
		{
			var container = cast(child, DisplayObjectContainer);
			for (i in 0...container.numChildren)
			{
				dispatchAddedToStageRecursively(container.getChildAt(i));
			}
		}
	}
	
	/**
	 * Recursively dispatches REMOVED_FROM_STAGE events.
	 */
	function dispatchRemovedFromStageRecursively(child:DisplayObject):Void
	{
		child.dispatchEvent(new Event(Event.REMOVED_FROM_STAGE));
		
		if (child is DisplayObjectContainer)
		{
			var container = cast(child, DisplayObjectContainer);
			for (i in 0...container.numChildren)
			{
				dispatchRemovedFromStageRecursively(container.getChildAt(i));
			}
		}
	}
}

/** Interface for disposable objects. */
interface IDisposable
{
	function dispose():Void;
}
