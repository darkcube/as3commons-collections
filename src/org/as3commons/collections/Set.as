/**
 * Copyright 2010 The original author or authors.
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
package org.as3commons.collections {
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	import org.as3commons.collections.framework.IIterator;
	import org.as3commons.collections.framework.ISet;
	import org.as3commons.collections.framework.core.SetIterator;

	/**
	 * Basic set implementation.
	 * 
	 * <p><strong>Description</strong></p>
	 * 
	 * <p>The <code>Set</code> maintains a dictionary as its source.</p>
	 * 
	 * <p><strong>Runtime of operations</strong></p>
	 * 
	 * <ul>
	 * <li>Adding of items - constant runtime O(1).<br />
	 * <code>add()</code></li>
	 * <li>Item lookup operations - constant runtime O(1).<br />
	 * <code>has(), remove()</code></li>
	 * </ul>
	 * 
	 * <p><strong>Notes</strong></p>
	 * 
	 * <p>The <code>iterator()</code> method does not support (ignores) the cursor parameter.</p>
	 * 
	 * <p>The <code>iterator()</code> method retuns an <code>ISetIterator</code>.</p>
	 * 
	 * <p><code>null</code> is allowed.</p>
	 * 
	 * <p id="link_SetExample"><strong>Set example</strong></p>
	 * 
	 * <p>This example shows the specific behaviour of a <code>Set</code>.
	 * The general work with collections and iterators is more detailed illustrated
	 * in the <code>ArrayList</code> examples below.</p>
	 * 
	 * {{EXAMPLE: SetExample}}
	 * 
	 * <p id="link_ArrayListExample"><strong>ArrayList example</strong></p>
	 * 
	 * {{EXAMPLE: ArrayListExample}}
	 * 
	 * <p id="link_ArrayListIteratorExample"><strong>ArrayListIterator example</strong></p>
	 * 
	 * {{EXAMPLE: ArrayListIteratorExample}}
	 * 
	 * @author Jens Struwe 24.03.2010
	 * @see org.as3commons.collections.framework.ISet ISet interface - Detailed description of the base set features.
	 * @see org.as3commons.collections.framework.ISetIterator ISetIterator interface - Detailed description of the base set iterator features.
	 */
	public class Set extends Proxy implements ISet {

		/**
		 * The non string items.
		 */
		private var _items : Dictionary;

		/**
		 * The string items.
		 */
		private var _stringItems : Object;

		/**
		 * The set size.
		 */
		private var _size : uint = 0;
		
		/**
		 * Array for the proxy iterators currently being used.
		 * 
		 * We handle iterating over the collection multiple times at once by using this array
		 * as a stack, with the most recent iteration as the last item in the array.
		 */
		private var _proxyIteratorCollection : Array = new Array();
		
		/**
		 * Iterator used for the getProperty function implementation of the Proxy class
		 */
		protected var _proxyGetPropertyIterator : IIterator;
		
		/**
		 * Current index of the getProperty iterator
		 */
		protected var _proxyGetPropertyIteratorPosition : int;
		
		/**
		 * Set constructor.
		 */
		public function Set() {
			_items = new Dictionary();
			_stringItems = new Object();
		}
		
		/*
		 * ISet
		 */

		/**
		 * @inheritDoc
		 */
		public function add(item : *) : Boolean {
			if (item is String) {
				if (_stringItems[item] !== undefined) return false;
				_stringItems[item] = item;

			} else {
				if (_items[item] !== undefined) return false;
				_items[item] = item;
			}
			
			_size++;
			return true;
		}
		
		/*
		 * ICollection
		 */
		
		/**
		 * @inheritDoc
		 */
		public function get size() : uint {
			return _size;
		}
		
		/**
		 * @inheritDoc
		 */
		public function has(item : *) : Boolean {
			if (item is String) return _stringItems[item] !== undefined;
			return _items[item] !== undefined;
		}
		
		/**
		 * @inheritDoc
		 */
		public function toArray() : Array {
			var items : Array = new Array();
			var item : *;
			for each (item in _stringItems) {
				items.push(item);
			}
			for each (item in _items) {
				items.push(item);
			}
			return items;
		}
		
		/**
		 * @inheritDoc
		 */
		public function remove(item : *) : Boolean {
			if (item is String) {
				if (_stringItems[item] === undefined) return false;
				delete _stringItems[item];

			} else {
				if (_items[item] === undefined) return false;
				delete _items[item];
			}
			
			_size--;
			return true;
		}
		
		/**
		 * @inheritDoc
		 */
		public function clear() : Boolean {
			if (!_size) return false;
			_items = new Dictionary();
			_stringItems = new Object();
			_size = 0;
			return true;
		}
		
		/*
		 * IIterable
		 */

		/**
		 * @inheritDoc
		 */
		public function iterator(cursor : * = undefined) : IIterator {
			return new SetIterator(this);
		}
		
		/*
		 * Proxy
		 */
		
		/**
		 *  @inheritDoc
		 */
		override flash_proxy function getProperty(name:*):*
		{
			if (name is QName)
				name = name.localName;
			
			var index:int = -1;
			try
			{
				// If caller passed in a number such as 5.5, it will be floored.
				var n:Number = parseInt(String(name));
				if (!isNaN(n))
					index = int(n);
			}
			catch(e:Error) // localName was not a number
			{
			}
			
			if (index == -1)
			{
				throw new Error("unknownProperty: " + name);
			}
			else
			{
				// If the item to discover isn't the next item, reset the iterator
				if( _proxyGetPropertyIterator == null || _proxyGetPropertyIteratorPosition != index || !_proxyGetPropertyIterator.hasNext() )
				{
					_proxyGetPropertyIteratorPosition = 0;
					_proxyGetPropertyIterator = iterator();
					while( _proxyGetPropertyIterator.hasNext() && _proxyGetPropertyIteratorPosition < index )
					{
						_proxyGetPropertyIterator.next();
						_proxyGetPropertyIteratorPosition++;
					}
				}
				
				// Get the item if it exists and is the next item
				if( _proxyGetPropertyIteratorPosition == index && _proxyGetPropertyIterator.hasNext() )
				{
					_proxyGetPropertyIteratorPosition++;
					return _proxyGetPropertyIterator.next();
				}
			}
			
			return null;
		}
		
		/**
		 *  @inheritDoc
		 */
		override flash_proxy function nextNameIndex(index:int):int {
			var currentIterator:IIterator;
			
			// Get the current iterator off the array stack
			if( index == 0 ) {
				currentIterator = iterator();
				_proxyIteratorCollection.push( currentIterator );
			}
			else {
				currentIterator = _proxyIteratorCollection[_proxyIteratorCollection.length-1];
			}
			
			// Pop the iterator if it has no more elements
			if( !currentIterator.hasNext() ) {
				_proxyIteratorCollection.pop();
				return 0;
			}
			else {
				return index + 1;
			}
		}
		
		/**
		 *  @inheritDoc
		 */
		override flash_proxy function nextName(index:int):String {
			return (index - 1).toString();
		}
		
		/**
		 *  @inheritDoc
		 */
		override flash_proxy function nextValue(index:int):* {
			var currentIterator:IIterator = _proxyIteratorCollection[_proxyIteratorCollection.length-1];
			return currentIterator.next();
		}    
		
		/**
		 *  @inheritDoc
		 */
		override flash_proxy function callProperty(name:*, ... rest):* {
			return null;
		}
	}
}
