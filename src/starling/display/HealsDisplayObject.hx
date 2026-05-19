package starling.display;

import haxe.ds.Vector;
import starling.events.Event;
import starling.events.EventDispatcher;
import starling.geom.Rectangle;
import starling.geom.Matrix;

/** Dispatched when an object is added to a parent. */
@:meta(Event(name="added", type="starling.events.Event"))

/** Dispatched when an object is connected to the stage (directly or indirectly). */
@:meta(Event(name="addedToStage", type="starling.events.Event"))

/** Dispatched when an object is removed from its parent. */
@:meta(Event(name="removed", type="starling.events.Event"))

/** Dispatched when an object is removed from the stage and won't be rendered any longer. */
@:meta(Event(name="removedFromStage", type="starling.events.Event"))

/** Dispatched once every frame on every object that is connected to the stage. */
@:meta(Event(name="enterFrame", type="starling.events.EnterFrameEvent"))

/** Dispatched when an object is touched. Bubbles. */
@:meta(Event(name="touch", type="starling.events.TouchEvent"))

/**
 * The DisplayObject class is the base class for all objects that are rendered on the
 * screen.
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
 * (x, y), as well as its rotation and scaling factors (scaleX, scaleY). Use the
 * <code>alpha</code> and <code>visible</code> properties to make an object translucent or
 * invisible.</p>
 *
 * <p>Every display object may be the target of touch events. If you don't want an object to be
 * touchable, you can disable the "touchable" property. When it's disabled, neither the object
 * nor its children will receive any more touch events.</p>
 *
 * <strong>Transforming coordinates</strong>
 *
 * <p>Within the display tree, each object has its own local coordinate system. If you rotate
 * a container, you rotate that coordinate system - and thus all the children of the
 * container.</p>
 *
 * <p>Sometimes you need to know where a certain point lies relative to another coordinate
 * system. That's the purpose of the method <code>getTransformationMatrix</code>. It will
 * create a matrix that represents the transformation of a point in one coordinate system to
 * another.</p>
 *
 * @see DisplayObjectContainer
 * @see Sprite
 * @see Stage
 */
class DisplayObject extends EventDispatcher
{
        // private members
        private var __x:Float = 0.0;
        private var __y:Float = 0.0;
        private var __pivotX:Float = 0.0;
        private var __pivotY:Float = 0.0;
        private var __scaleX:Float = 1.0;
        private var __scaleY:Float = 1.0;
        private var __skewX:Float = 0.0;
        private var __skewY:Float = 0.0;
        private var __rotation:Float = 0.0;
        private var __alpha:Float = 1.0;
        private var __visible:Bool = true;
        private var __touchable:Bool = true;
        private var __blendMode:String = BlendMode.AUTO;
        private var __name:String = "";
        private var __useHandCursor:Bool = false;
        private var __transformationMatrix:Matrix;
        private var __transformationChanged:Bool = true;
        private var __parent:DisplayObjectContainer = null;

        // helper objects
        private static var sHelperMatrix:Matrix = new Matrix();
        private static var sHelperPoint:{x:Float, y:Float} = {x: 0, y: 0};

        /** The x coordinate of the object relative to its parent. */
        public var x(get, set):Float;

        /** The y coordinate of the object relative to its parent. */
        public var y(get, set):Float;

        /** The x coordinate of the object's origin point (pivot). */
        public var pivotX(get, set):Float;

        /** The y coordinate of the object's origin point (pivot). */
        public var pivotY(get, set):Float;

        /** The scale factor along the x-axis. */
        public var scaleX(get, set):Float;

        /** The scale factor along the y-axis. */
        public var scaleY(get, set):Float;

        /** Uniform scaling - sets both scaleX and scaleY to the same value. */
        public var scale(get, set):Float;

        /** The horizontal skew angle in radians. */
        public var skewX(get, set):Float;

        /** The vertical skew angle in radians. */
        public var skewY(get, set):Float;

        /** The rotation of the object in radians. */
        public var rotation(get, set):Float;

        /** Indicates whether the object is rotated or skewed. */
        public var isRotated(get, never):Bool;

        /** The alpha (transparency) value of the object (0.0 to 1.0). */
        public var alpha(get, set):Float;

        /** Indicates whether the object is visible. */
        public var visible(get, set):Bool;

        /** Indicates whether the object can receive touch events. */
        public var touchable(get, set):Bool;

        /** The blend mode used when rendering this object. */
        public var blendMode(get, set):String;

        /** The name of the display object. */
        public var name(get, set):String;

        /** Indicates if the cursor should change to a hand when hovering over this object. */
        public var useHandCursor(get, set):Bool;

        /** The transformation matrix of this object. */
        public var transformationMatrix(get, never):Matrix;

        /** The parent container of this display object. */
        public var parent(default, null):DisplayObjectContainer = null;

        /** Creates a new DisplayObject. */
        public function new()
        {
                super();
                __transformationMatrix = new Matrix();
        }

        // Property getters and setters

        private function get_x():Float return __x;
        private function set_x(value:Float):Float { __x = value; setTransformationChanged(); return value; }

        private function get_y():Float return __y;
        private function set_y(value:Float):Float { __y = value; setTransformationChanged(); return value; }

        private function get_pivotX():Float return __pivotX;
        private function set_pivotX(value:Float):Float { __pivotX = value; setTransformationChanged(); return value; }

        private function get_pivotY():Float return __pivotY;
        private function set_pivotY(value:Float):Float { __pivotY = value; setTransformationChanged(); return value; }

        private function get_scaleX():Float return __scaleX;
        private function set_scaleX(value:Float):Float { __scaleX = value; setTransformationChanged(); return value; }

        private function get_scaleY():Float return __scaleY;
        private function set_scaleY(value:Float):Float { __scaleY = value; setTransformationChanged(); return value; }

        private function get_scale():Float return (__scaleX + __scaleY) / 2.0;
        private function set_scale(value:Float):Float { __scaleX = __scaleY = value; setTransformationChanged(); return value; }

        private function get_skewX():Float return __skewX;
        private function set_skewX(value:Float):Float { __skewX = value; setTransformationChanged(); return value; }

        private function get_skewY():Float return __skewY;
        private function set_skewY(value:Float):Float { __skewY = value; setTransformationChanged(); return value; }

        private function get_rotation():Float return __rotation;
        private function set_rotation(value:Float):Float { __rotation = value; setTransformationChanged(); return value; }

        private function get_isRotated():Bool return __rotation != 0.0 || __skewX != 0.0 || __skewY != 0.0;

        private function get_alpha():Float return __alpha;
        private function set_alpha(value:Float):Float { __alpha = value; return value; }

        private function get_visible():Bool return __visible;
        private function set_visible(value:Bool):Bool { __visible = value; return value; }

        private function get_touchable():Bool return __touchable;
        private function set_touchable(value:Bool):Bool { __touchable = value; return value; }

        private function get_blendMode():String return __blendMode;
        private function set_blendMode(value:String):String { __blendMode = value; return value; }

        private function get_name():String return __name;
        private function set_name(value:String):String { __name = value; return value; }

        private function get_useHandCursor():Bool return __useHandCursor;
        private function set_useHandCursor(value:Bool):Bool { __useHandCursor = value; return value; }

        private function get_transformationMatrix():Matrix
        {
                if (__transformationChanged)
                {
                        updateTransformationMatrix();
                }
                return __transformationMatrix;
        }

        /** Marks the transformation matrix as needing update. */
        private function setTransformationChanged():Void
        {
                __transformationChanged = true;
        }

        /** Updates the transformation matrix based on current properties. */
        private function updateTransformationMatrix():Void
        {
                var matrix = __transformationMatrix;
                matrix.identity();

                // Apply translation to pivot
                if (__pivotX != 0.0 || __pivotY != 0.0)
                {
                        matrix.translate(-__pivotX, -__pivotY);
                }

                // Apply skew
                if (__skewX != 0.0 || __skewY != 0.0)
                {
                        matrix.skew(__skewX, __skewY);
                }

                // Apply rotation
                if (__rotation != 0.0)
                {
                        matrix.rotate(__rotation);
                }

                // Apply scale
                if (__scaleX != 1.0 || __scaleY != 1.0)
                {
                        matrix.scale(__scaleX, __scaleY);
                }

                // Apply translation from pivot and position
                if (__pivotX != 0.0 || __pivotY != 0.0 || __x != 0.0 || __y != 0.0)
                {
                        matrix.translate(__pivotX + __x, __pivotY + __y);
                }

                __transformationChanged = false;
        }

        /**
         * Adds the object to a parent container.
         * @internal
         */
        function setParent(newParent:DisplayObjectContainer):Void
        {
                var wasOnStage = isOnStage();
                this.parent = newParent;
                var isOnStageNow = isOnStage();

                if (wasOnStage && !isOnStageNow)
                {
                        dispatchEvent(new Event(Event.REMOVED_FROM_STAGE));
                }
                else if (!wasOnStage && isOnStageNow)
                {
                        dispatchEvent(new Event(Event.ADDED_TO_STAGE));
                }
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
         * Checks if this object is currently on the stage.
         */
        public function isOnStage():Bool
        {
                var current:DisplayObject = this;
                while (current.parent != null)
                {
                        current = current.parent;
                }
                return Std.isOfType(current, Stage);
        }

        /**
         * Converts a point from the local coordinate system to global (stage) coordinates.
         */
        public function localToGlobal(localPoint:{x:Float, y:Float}):{x:Float, y:Float}
        {
                sHelperPoint.x = localPoint.x;
                sHelperPoint.y = localPoint.y;

                var current:DisplayObject = this;
                while (current != null)
                {
                        var matrix = current.transformationMatrix;
                        var newX = matrix.a * sHelperPoint.x + matrix.c * sHelperPoint.y + matrix.tx;
                        var newY = matrix.b * sHelperPoint.x + matrix.d * sHelperPoint.y + matrix.ty;
                        sHelperPoint.x = newX;
                        sHelperPoint.y = newY;
                        current = current.parent;
                }

                return {x: sHelperPoint.x, y: sHelperPoint.y};
        }

        /**
         * Converts a point from global (stage) coordinates to the local coordinate system.
         */
        public function globalToLocal(globalPoint:{x:Float, y:Float}):{x:Float, y:Float}
        {
                // Get the transformation matrix from local to global
                var matrix = getTransformationMatrix(null);

                // Invert it to go from global to local
                matrix.invert();

                var localX = matrix.a * globalPoint.x + matrix.c * globalPoint.y + matrix.tx;
                var localY = matrix.b * globalPoint.x + matrix.d * globalPoint.y + matrix.ty;

                return {x: localX, y: localY};
        }

        /**
         * Returns a matrix that transforms coordinates from one coordinate system to another.
         */
        public function getTransformationMatrix(targetSpace:DisplayObject = null, resultMatrix:Matrix = null):Matrix
        {
                if (resultMatrix == null)
                {
                        resultMatrix = new Matrix();
                }
                else
                {
                        resultMatrix.identity();
                }

                // Build matrix from this object up to target space
                var current:DisplayObject = this;
                while (current != null && current != targetSpace)
                {
                        var localMatrix = current.transformationMatrix;
                        resultMatrix.prepend(localMatrix);
                        current = current.parent;
                }

                return resultMatrix;
        }

        /**
         * Returns the bounds of the object in the coordinate space of another object.
         */
        public function getBounds(space:DisplayObject = null, resultRect:Rectangle = null):Rectangle
        {
                if (resultRect == null)
                {
                        resultRect = new Rectangle();
                }

                // Get local bounds first
                var localBounds = getLocalBounds();

                if (space == null || space == this)
                {
                        resultRect.setTo(localBounds.x, localBounds.y, localBounds.width, localBounds.height);
                        return resultRect;
                }

                // Transform corners to target space
                var matrix = getTransformationMatrix(space);

                var topLeft = transformPoint(matrix, localBounds.x, localBounds.y);
                var topRight = transformPoint(matrix, localBounds.x + localBounds.width, localBounds.y);
                var bottomLeft = transformPoint(matrix, localBounds.x, localBounds.y + localBounds.height);
                var bottomRight = transformPoint(matrix, localBounds.x + localBounds.width, localBounds.y + localBounds.height);

                var minX = Math.min(Math.min(topLeft.x, topRight.x), Math.min(bottomLeft.x, bottomRight.x));
                var maxX = Math.max(Math.max(topLeft.x, topRight.x), Math.max(bottomLeft.x, bottomRight.x));
                var minY = Math.min(Math.min(topLeft.y, topRight.y), Math.min(bottomLeft.y, bottomRight.y));
                var maxY = Math.max(Math.max(topLeft.y, topRight.y), Math.max(bottomLeft.y, bottomRight.y));

                resultRect.setTo(minX, minY, maxX - minX, maxY - minY);
                return resultRect;
        }

        /**
         * Returns the bounds of the object in its local coordinate system.
         * Subclasses should override this to provide accurate bounds.
         */
        public function getLocalBounds(resultRect:Rectangle = null):Rectangle
        {
                if (resultRect == null)
                {
                        resultRect = new Rectangle();
                }
                resultRect.setTo(0, 0, 0, 0);
                return resultRect;
        }

        /** Helper function to transform a point by a matrix. */
        private function transformPoint(matrix:Matrix, x:Float, y:Float):{x:Float, y:Float}
        {
                return {
                        x: matrix.a * x + matrix.c * y + matrix.tx,
                        y: matrix.b * x + matrix.d * y + matrix.ty
                };
        }

        /**
         * Checks if a point intersects with this object.
         * The point must be in the local coordinate system of this object.
         */
        public function hitTest(localPoint:{x:Float, y:Float}):Bool
        {
                if (!__visible || !__touchable)
                {
                        return false;
                }

                var bounds = getLocalBounds();
                return localPoint.x >= bounds.x && localPoint.x <= bounds.x + bounds.width &&
                           localPoint.y >= bounds.y && localPoint.y <= bounds.y + bounds.height;
        }

        /**
         * Returns the object that appears frontmost at the given coordinates.
         */
        public function hitTestGlobal(globalPoint:{x:Float, y:Float}):DisplayObject
        {
                if (!__visible || !__touchable)
                {
                        return null;
                }

                var localPoint = globalToLocal(globalPoint);

                if (hitTest(localPoint))
                {
                        return this;
                }

                return null;
        }

        /**
         * Advances time for this object and its children.
         * Dispatches ENTER_FRAME event.
         */
        public function advanceTime(passedTime:Float):Void
        {
                if (isOnStage())
                {
                        dispatchEvent(new Event(Event.ENTER_FRAME));
                }
        }

        /**
         * Renders this object. Subclasses must implement this method.
         * This is an abstract method.
         */
        public function render(renderSupport:Dynamic):Void
        {
                // Abstract method - subclasses must implement
                throw new starling.errors.AbstractMethodError("Abstract method cannot be called");
        }

        /**
         * Disposes all resources used by this object.
         */
        public function dispose():Void
        {
                removeFromParent(false);
                removeEventListeners();
        }

        /**
         * Returns a string representation of this object.
         */
        public function toString():String
        {
                return '[starling.display.DisplayObject name="' + __name + '"]';
        }
}