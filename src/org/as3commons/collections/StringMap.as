/**
 * Copyright 2010-2011 The original author or authors.
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

	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	import org.as3commons.collections.framework.IIterator;
	import org.as3commons.collections.framework.IMap;
	import org.as3commons.collections.framework.core.MapIterator;
	import org.as3commons.collections.iterators.ArrayIterator;

	/**
	 * String map implementation.
	 * 
	 * <p>The <code>StringMap</code> maps literal keys to values.</p>
	 * 
	 * <p>You are still allowed to add complex or numeric keys. No error is thrown.</p>
	 * 
	 * <p>Complex keys are stored with their String representation such as
	 * <code>[object Object]</code>.</p>
	 * 
	 * <p>When you use keys containing numeric values (0, "0", 1, "1", -1, "-1", 1.5, "1.5"),
	 * you should have in mind that the keys implicitely get converted as follows:</p>
	 * 
	 * <ul>
	 * <li>Int <code>0</code> is stored and returned as int <code>0</code>.</li>
	 * <li>String <code>"0"</code> is stored and returned as int <code>"0"</code>.</li>
	 * <li>Int <code>1</code> is stored and returned as int <code>1</code>.</li>
	 * <li>String <code>"1"</code> is stored and returned as int <code>"1"</code>.</li>
	 * <li>Int <code>-1</code> is stored and returned as String <code>"-1"</code>.</li>
	 * <li>String <code>"-1"</code> is stored and returned as String <code>"-1"</code>.</li>
	 * <li>Int <code>1.5</code> is stored and returned as String <code>"1.5"</code>.</li>
	 * <li>String <code>"1.5"</code> is stored and returned as String <code>"1.5"</code>.</li>
	 * </ul>
	 * 
	 * <p>In any case, you are safe using the <code>StringMap</code> with non-numeric
	 * literals or non negative integer values.</p>
	 * 
	 * <p>Note to the universal type <code>* </code>. The <code>StringMap</code> still implements
	 * the <code>IMap</code> interface. This interface allows to pass and returns objects of the universal
	 * type <code>* </code>. This is not actually what we like, but since ActionScript does not
	 * support generics, there is no other way to define a base interface for all map
	 * implementations. If you are not comfortable with this, please make your own custom
	 * typed copy of this class.</p>
	 * 
	 * <p>In difference to the basic <code>Map</code> implementation, the <code>StringMap</code>
	 * maintains an object as its source and hence requires less memory.</p>
	 * 
	 * <p>See the <code>Map</code> documentation for more details.</p>
	 * 
	 * @author Jens Struwe 19.09.2011
	 * @see org.as3commons.collections.Map Basic map implementation - Basic map implementation description.
	 */
	public class StringMap extends Proxy implements IMap {

		/**
		 * The stringed key item map.
		 */
		protected var _map : Object;

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
		 * Map constructor.
		 */
		public function StringMap() {
			_map = new Object();
		}
		
		/*
		 * IMap
		 */

		/**
		 * @inheritDoc
		 */
		public function add(key : *, item : *) : Boolean {
			if (_map[key] !== undefined) return false;
			_map[key] = item;

			_size++;
			return true;
		}
		
		/**
		 * @inheritDoc
		 */
		public function replaceFor(key : *, item : *) : Boolean {
			if (_map[key] === undefined) return false;
			if (_map[key] === item) return false;
			_map[key] = item;
			return true;
		}
		
		/**
		 * @inheritDoc
		 */
		public function count(item : *) : uint {
			var count : uint = 0;
			var thisItem : *;
			for each (thisItem in _map) {
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
			return _map[key] !== undefined;
		}
		
		/**
		 * @inheritDoc
		 */
		public function itemFor(key : *) : * {
			return _map[key];
		}
		
		/**
		 * @inheritDoc
		 */
		public function keysToArray() : Array {
			var keys : Array = new Array();
			for (var string : String in _map) {
				keys.push(string);
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
			if (_map[key] === undefined) return undefined;
			var item : * = _map[key];
			delete _map[key];
			
			_size--;
			return item;
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeAll(item : *) : uint {
			var count : uint = 0;
			for (var string : String in _map) {
				if (_map[string] === item) {
					delete _map[string];
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
			for each (thisItem in _map) {
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
			for each (item in _map) {
				items.push(item);
			}
			return items;
		}
		
		/**
		 * @inheritDoc
		 */
		public function remove(item : *) : Boolean {
			for (var string : String in _map) {
				if (_map[string] === item) {
					delete _map[string];
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
			_map = new Object();
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
