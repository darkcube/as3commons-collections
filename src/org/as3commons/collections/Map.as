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
	import org.as3commons.collections.framework.IMap;
	import org.as3commons.collections.framework.core.MapIterator;
	import org.as3commons.collections.iterators.ArrayIterator;

	/**
	 * Basic map implementation.
	 * 
	 * <p><strong>Description</strong></p>
	 * 
	 * <p>The <code>Map</code> maintains a dictionary as its source.</p>
	 * 
	 * <p><strong>Runtime of operations</strong></p>
	 * 
	 * <ul>
	 * <li>Adding of items - constant runtime O(1).<br />
	 * <code>add()</code></li>
	 * <li>Key lookup operations - constant runtime O(1).<br />
	 * <code>hasKey(), itemFor(), replaceFor(), removeKey()</code></li>
	 * <li>Item lookup operations - linear runtime O(n).<br />
	 * <code>has(), count(), remove(), removeAll()</code></li>
	 * </ul>
	 * 
	 * <p><strong>Notes</strong></p>
	 * 
	 * <p>The <code>iterator()</code> method does not support (ignores) the cursor parameter.</p>
	 * 
	 * <p>The <code>iterator()</code> method retuns an <code>IMapIterator</code>.</p>
	 * 
	 * <p><code>null</code> is allowed for keys as well as for values.</p>
	 * 
	 * <p id="link_MapExample"><strong>Map example</strong></p>
	 * 
	 * <p> This example shows the specific behaviour of a <code>Map</code>.
	 * The general work with collections and iterators is more detailed illustrated
	 * in the <code>ArrayList</code> examples below.</p>
	 * 
	 * {{EXAMPLE: MapExample}}
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
	 * @see org.as3commons.collections.framework.IMap IMap interface - Detailed description of the base map features.
	 * @see org.as3commons.collections.framework.IMapIterator IMapIterator interface - Detailed description of the base map iterator features.
	 */
	public class Map extends Proxy implements IMap {

		/**
		 * The non string keys.
		 */
		protected var _keys : Dictionary;

		/**
		 * The items of the non string keys.
		 */
		protected var _items : Dictionary;

		/**
		 * The stringed key item map.
		 */
		protected var _stringMap : Object;

		/**
		 * The map size.
		 */
		protected var _size : uint = 0;
		
		/**
		 * Array for the proxy iterators currently being used.
		 * 
		 * We handle iterating over the collection multiple times at once by using this array
		 * as a stack, with the most recent iteration as the last item in the array.
		 */
		protected var _proxyIteratorCollection : Array = new Array();
		
		/**
		 * Array for the proxy key iterators currently being used.
		 * 
		 * We handle iterating over the collection multiple times at once by using this array
		 * as a stack, with the most recent iteration as the last item in the array.
		 */
		protected var _proxyKeyIteratorCollection : Array = new Array();
		
		/**
		 * Iterator used for the getProperty function implementation of the Proxy class
		 */
		protected var _proxyGetPropertyIterator : IIterator;
		
		/**
		 * Current index of the getProperty iterator
		 */
		protected var _proxyGetPropertyIteratorPosition : int;
		
		/**
		 * Map constructor.
		 */
		public function Map() {
			_items = new Dictionary();
			_keys = new Dictionary();
			_stringMap = new Object();
		}
		
		/*
		 * IMap
		 */

		/**
		 * @inheritDoc
		 */
		public function add(key : *, item : *) : Boolean {
			if (key is String) {
				if (_stringMap[key] !== undefined) return false;
				_stringMap[key] = item;

			} else {
				if (_keys[key] !== undefined) return false;
				_keys[key] = key;
				_items[key] = item;
			}
			
			_size++;
			return true;
		}
		
		/**
		 * @inheritDoc
		 */
		public function replaceFor(key : *, item : *) : Boolean {
			if (key is String) {
				if (_stringMap[key] === undefined) return false;
				if (_stringMap[key] === item) return false;
				_stringMap[key] = item;

			} else {
				if (_keys[key] === undefined) return false;
				if (_items[key] === item) return false;
				_items[key] = item;
			}
			return true;
		}
		
		/**
		 * @inheritDoc
		 */
		public function count(item : *) : uint {
			var count : uint = 0;
			var thisItem : *;
			for each (thisItem in _stringMap) {
				if (thisItem === item) {
					count++;
				}
			}
			for each (thisItem in _items) {
				if (thisItem === item) {
					count++;
				}
			}
			return count;
		}
		
		/**
		 * @inheritDoc
		 */
		public function hasKey(key : *) : Boolean {
			return key is String ? _stringMap[key] !== undefined : _keys[key] !== undefined;
		}
		
		/**
		 * @inheritDoc
		 */
		public function itemFor(key : *) : * {
			if (key is String) return _stringMap[key];
			return _items[key];
		}
		
		/**
		 * @inheritDoc
		 */
		public function keysToArray() : Array {
			var keys : Array = new Array();
			for (var string : String in _stringMap) {
				keys.push(string);
			}
			for each (var key : * in _keys) {
				keys.push(key);
			}
			return keys;
		}
		
		/**
		 * @inheritDoc
		 */
		public function keyIterator() : IIterator {
			return new ArrayIterator(keysToArray());
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeKey(key : *) : * {
			var item : *;
			if (key is String) {
				if (_stringMap[key] === undefined) return undefined;
				item = _stringMap[key];
				delete _stringMap[key];

			} else {
				if (_keys[key] === undefined) return undefined;
				item = _items[key];
				delete _keys[key];
				delete _items[key];
			}
			
			_size--;
			return item;
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeAll(item : *) : uint {
			var count : uint = 0;
			for (var string : String in _stringMap) {
				if (_stringMap[string] === item) {
					delete _stringMap[string];
					_size--;

					itemRemoved(string, item); // notify subclasses

					count++;
				}
			}
			for (var key : * in _items) {
				if (_items[key] === item) {
					delete _keys[key];
					delete _items[key];
					_size--;

					itemRemoved(string, item); // notify subclasses

					count++;
				}
			}
			return count;
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
			var thisItem : *;
			for each (thisItem in _stringMap) {
				if (thisItem === item) return true;
			}
			for each (thisItem in _items) {
				if (thisItem === item) return true;
			}
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function toArray() : Array {
			var items : Array = new Array();
			var item : *;
			for each (item in _stringMap) {
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
			for (var string : String in _stringMap) {
				if (_stringMap[string] === item) {
					delete _stringMap[string];
					_size--;

					itemRemoved(string, item); // notify subclasses

					return true;
				}
			}
			for (var key : * in _items) {
				if (_items[key] === item) {
					delete _keys[key];
					delete _items[key];
					_size--;

					itemRemoved(string, item); // notify subclasses

					return true;
				}
			}
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function clear() : Boolean {
			if (!_size) return false;
			_keys = new Dictionary();
			_items = new Dictionary();
			_stringMap = new Object();
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
			return new MapIterator(this);
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
				_proxyKeyIteratorCollection.push( keyIterator() );
				_proxyIteratorCollection.push( currentIterator );
			}
			else {
				currentIterator = _proxyIteratorCollection[_proxyIteratorCollection.length-1];
			}
			
			// Pop the iterator if it has no more elements
			if( !currentIterator.hasNext() ) {
				_proxyIteratorCollection.pop();
				_proxyKeyIteratorCollection.pop();
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
			var currentIterator:IIterator = _proxyKeyIteratorCollection[_proxyIteratorCollection.length-1];
			return currentIterator.next();
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
		
		/*
		 * Protected
		 */

		/**
		 * Template method to notify subclasses after an item has been removed.
		 * 
		 * @param item The removed item.
		 * @param node The former index of the removed item.
		 */
		protected function itemRemoved(key : *, item : *) : void {
			// hook
		}
	}
}
