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
	import mx.events.CollectionEvent;
	
	import org.as3commons.collections.framework.ICollectionFx;
	import org.as3commons.collections.framework.core.ArrayListIterator;
	import org.as3commons.collections.fx.ArrayListFx;
	
	/**
	 * Implementation of the <code>ArrayList</code> iterator that also implements <code>IViewCursor</code>.
	 * 
	 * @author Timothy Lusk 11.29.2011
	 */
	public class ArrayListIteratorFx extends ArrayListIterator implements IViewCursor {
		
		/**
		 * Event dispatcher.
		 */
		private var _eventDispatcher : IEventDispatcher;
		
		/**
		 * The collection to enumerate.
		 */
		protected var _fxCollection : ICollectionFx;
		
		/**
		 * ArrayListIteratorFx constructor.
		 * 	
		 * <p>If <code>index</code> is specified, the iterator returns the item at that
		 * index with the first call to <code>next()</code> and the item at <code>index -1</code>
		 * with the first call to <code>previous()</code>.</p>
		 * 
		 * @param array The list.
		 * @param index Start position of enumeration.
		 */
		public function ArrayListIteratorFx(theSet : ArrayListFx, index : uint = 0) {
			_eventDispatcher = new EventDispatcher(this);
			_fxCollection = theSet;
			super(theSet, index);
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
			return _next == -1 && _current == -1;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get beforeFirst():Boolean
		{
			return _next != -1 && _current == -1;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get bookmark():CursorBookmark
		{
			return new ArrayListIteratorBookmark(CursorBookmark.CURRENT.value, index);
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
			if (length == 0)
			{
				end();
				return;
			}
			
			var newIndex:int = _current;
			if(bookmark == CursorBookmark.FIRST)
			{
				newIndex = 0;
			}
			else if(bookmark == CursorBookmark.LAST)
			{
				newIndex = _array.length - 1;
			}
			else if (bookmark != CursorBookmark.CURRENT)
			{
				newIndex = ArrayListIteratorBookmark(bookmark).currentIndex;
			}
			
			newIndex += offset;
			
			if (newIndex >= _array.length)
			{
				end();
			}
			else if (newIndex < 0)
			{
				start();
			}
			else
			{
				_current = newIndex;
				_next = _current >= _array.length - 1 ? -1 : _current + 1;
			}
		}
	}
}

import mx.collections.CursorBookmark;

/**
 *  @private
 *  Encapsulates the positional aspects of a cursor within an ArrayListIteratorFx.
 *  Only the ArrayListIteratorFx should construct this.
 */
internal class ArrayListIteratorBookmark extends CursorBookmark
{
	private var _currentIndex:int;
	
	/**
	 *  @private
	 */
	public function ArrayListIteratorBookmark(value:Object,
											  currentIndex:int)
	{
		super(value);
		this._currentIndex = currentIndex;
	}
	
	public function get currentIndex():int
	{
		return _currentIndex;
	}
}