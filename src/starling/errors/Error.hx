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

package starling.errors;

/**
 * Base class for all Starling errors.
 */
class Error extends haxe.Exception
{
	public var name(default, null):String;
	
	public function new(message:String = "", id:Int = 0)
	{
		super(message);
		name = "Error";
	}
	
	public function toString():String
	{
		return name + ": " + message;
	}
}
