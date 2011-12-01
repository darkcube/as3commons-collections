/**
 * Copyright 2011 The original author or authors.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.as3commons.collections.fx.iterators {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.CursorBookmark;
	import mx.collections.ICollectionView;
	import mx.collections.IViewCursor;
	
	import org.as3commons.collections.framework.ICollectionFx;
	import org.as3commons.collections.framework.core.LinkedMapIterator;
	import org.as3commons.collections.framework.core.LinkedMapNode;
	import org.as3commons.collections.fx.LinkedMapFx;
	
	/**
	 * Implementation of the <code>LinkedMap</code> iterator that also implements <code>IViewCursor</code>.
	 * 
	 * @author Timothy Lusk 11.29.2011
	 */
	public class LinkedMapIteratorFx extends LinkedMapIterator implements IViewCursor {
		
		/**
		 * Event dispatcher.
		 */
		private var _eventDispatcher : IEventDispatcher;
		
		/**
		 * The collection to enumerate.
		 */
		protected var _fxCollection : ICollectionFx;
		
		/**
		 * LinkedMapIteratorFx constructor.
		 * 
		 * <p>If <code>next</code> is specified, the iterator returns the item of that
		 * node with the first call to <code>next()</code> and its predecessor
		 * with the first call to <code>previous()</code>.</p>
		 * 
		 * @param orderedMap The map to be enumerated.
		 * @param next The node to start the iteration with.
		 */
		public function LinkedMapIteratorFx(theSet : LinkedMapFx, next : LinkedMapNode = null) {
			_eventDispatcher = new EventDispatcher(this);
			_fxCollection = theSet;
			super(theSet, next);
		}
		
		/*
		 * IEventDispatcher
		 */
		
		/**
		 * @inheritDoc
		 */
		public function dispatchEvent(event : Event) : Boolean {
			return _eventDispatcher.dispatchEvent(event);
		}
		
		/**
		 * @inheritDoc
		 */
		public function hasEventListener(type : String) : Boolean {
			return _eventDispatcher.hasEventListener(type);
		}
		
		/**
		 * @inheritDoc
		 */
		public function willTrigger(type : String) : Boolean {
			return _eventDispatcher.willTrigger(type);
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeEventListener(type : String, listener : Function, useCapture : Boolean = false) : void {
			_eventDispatcher.removeEventListener(type, listener, useCapture);
		}
		
		/**
		 * @inheritDoc
		 */
		public function addEventListener(type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false) : void {
			_eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		/*
		 * IIterator
		 */
		
		/**
		 * @inheritDoc
		 */
		public function get afterLast():Boolean
		{
			return _next == null && _current == null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get beforeFirst():Boolean
		{
			return _next != null && _current == null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get bookmark():CursorBookmark
		{
			return new LinkedMapIteratorBookmark(CursorBookmark.CURRENT.value, _current);
		}
		
		/**
		 * @inheritDoc
		 */
		public function get current():Object
		{
			return currentItem;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get view():ICollectionView
		{
			return _fxCollection;
		}
		
		/**
		 * @inheritDoc
		 */
		public function findAny(values:Object):Boolean
		{
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function findFirst(values:Object):Boolean
		{
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function findLast(values:Object):Boolean
		{
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function insert(item:Object):void {}
		
		/**
		 * @inheritDoc
		 */
		public function moveNext():Boolean
		{
			var validItem:Boolean = hasNext();
			next();
			return validItem;
		}
		
		/**
		 * @inheritDoc
		 */
		public function movePrevious():Boolean
		{
			var validItem:Boolean = hasPrevious();
			previous();
			return validItem;
		}
		
		/**
		 * @inheritDoc
		 */
		public function remove():Object
		{
			var item:* = currentItem;
			removeItem();
			return item;
		}
		
		/**
		 * @inheritDoc
		 */
		public function seek(bookmark:CursorBookmark, offset:int = 0, prefetch:int = 0):void
		{
			if (_collection.size == 0)
			{
				end();
				return;
			}
			
			if(bookmark == CursorBookmark.FIRST)
			{
				start();
				next();
			}
			else if(bookmark == CursorBookmark.LAST)
			{
				end();
				previous();
			}
			else if (bookmark != CursorBookmark.CURRENT)
			{
				_current = LinkedMapIteratorBookmark(bookmark).currentNode;
				if( _current != null )
				{
					_next = _current.right;
				}
			}
			
			if( offset >= 0 )
			{
				for( var offsetIncrease:int = 0; offsetIncrease < offset; offsetIncrease++ )
				{
					next();
				}
			}
			else
			{
				offset = -offset;
				for( var offsetDecrease:int = 0; offsetDecrease < offset; offsetDecrease++ )
				{
					previous();
				}
			}
		}
	}
}

import mx.collections.CursorBookmark;

import org.as3commons.collections.framework.core.LinkedNode;

/**
 *  @private
 *  Encapsulates the positional aspects of a cursor within an LinkedMapIteratorBookmark.
 *  Only the LinkedMapIteratorBookmark should construct this.
 */
internal class LinkedMapIteratorBookmark extends CursorBookmark
{
	private var _currentNode:LinkedNode;
	
	/**
	 *  @private
	 */
	public function LinkedMapIteratorBookmark(value:Object,
											  currentNode:LinkedNode)
	{
		super(value);
		_currentNode = currentNode;
	}
	
	public function get currentNode():LinkedNode
	{
		return _currentNode;
	}
}