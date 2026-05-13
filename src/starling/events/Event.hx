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

package starling.events;

/**
 * The Event class allows you to create objects that are passed up and down the display list.
 */
@:keep
class Event
{
	// Event types
	public static inline var ADDED = "added";
	public static inline var ADDED_TO_STAGE = "addedToStage";
	public static inline var REMOVED = "removed";
	public static inline var REMOVED_FROM_STAGE = "removedFromStage";
	public static inline var ENTER_FRAME = "enterFrame";
	public static inline var TOUCH = "touch";
	public static inline var KEY_UP = "keyUp";
	public static inline var KEY_DOWN = "keyDown";
	public static inline var RESIZE = "resize";
	public static inline var CHANGE = "change";
	public static inline var COMPLETE = "complete";
	public static inline var CANCEL = "cancel";
	public static inline var SCROLL = "scroll";
	public static inline var READY = "ready";
	public static inline var CONTEXT_LOST = "contextLost";
	public static inline var CONTEXT_RESTORED = "contextRestored";
	
	/** The type of event. */
	public var type(default, null):String;
	
	/** Determines whether the event bubbles up the display tree. */
	public var bubbles(default, null):Bool;
	
	/** The object that dispatched the event. */
	public var target(default, null):EventDispatcher;
	
	/** The current object in the event flow. */
	public var currentTarget(default, null):EventDispatcher;
	
	/** Indicates whether the event is prevented from bubbling. */
	var _stopsPropagation:Bool = false;
	
	/** Indicates whether the event is prevented from being processed by additional listeners. */
	var _stopsImmediatePropagation:Bool = false;
	
	/** Data associated with the event. */
	public var data:Dynamic;
	
	/**
	 * Creates an Event object to pass as a parameter to event handlers.
	 */
	public function new(type:String, bubbles:Bool = false, data:Dynamic = null)
	{
		this.type = type;
		this.bubbles = bubbles;
		this.data = data;
	}
	
	/**
	 * Prevents further processing of the event by additional listeners of the current target.
	 */
	public function stopImmediatePropagation():Void
	{
		_stopsImmediatePropagation = true;
	}
	
	/**
	 * Prevents the event from bubbling up the display tree.
	 */
	public function stopPropagation():Void
	{
		_stopsPropagation = true;
	}
	
	/**
	 * Returns a copy of this Event object.
	 */
	public function clone():Event
	{
		return new Event(type, bubbles, data);
	}
	
	/**
	 * Checks whether the event has stopped propagation.
	 */
	public function isStopped():Bool
	{
		return _stopsImmediatePropagation || _stopsPropagation;
	}
	
	/**
	 * Checks whether immediate propagation has been stopped.
	 */
	public function isImmediateStopped():Bool
	{
		return _stopsImmediatePropagation;
	}
}
