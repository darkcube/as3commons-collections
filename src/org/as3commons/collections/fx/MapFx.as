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
package org.as3commons.collections.fx {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ISort;
	import mx.collections.IViewCursor;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	
	import org.as3commons.collections.Map;
	import org.as3commons.collections.framework.ICollectionFx;
	import org.as3commons.collections.fx.events.FxCollectionEvent;
	import org.as3commons.collections.fx.iterators.MapIteratorFx;

	/**
	 * Bindable version of the <code>Map</code> implementation.
	 * 
	 * <p><strong><code>MapFx</code> event kinds</strong></p>
	 * 
	 * <ul>
	 * <li><code>FxCollectionEvent.ITEM_ADDED</code></li>
	 * <li><code>FxCollectionEvent.ITEM_REPLACED</code></li>
	 * <li><code>FxCollectionEvent.ITEM_REMOVED</code></li>
	 * <li><code>FxCollectionEvent.RESET</code></li>
	 * </ul>
	 * 
	 * <p><strong>Note</strong></p>
	 * 
	 * <p>As of the absence of any order of the <code>Map</code> collection, the <code>iterator()</code>
	 * method of the event dispatched by the <code>MapFx</code> returns always <code>null</code>.</p>
	 * 
	 * <p id="link_MapFxExample"><strong>MapFx example</strong></p>
	 * 
	 * {{EXAMPLE: MapFxExample}}
	 * 
	 * @author Jens Struwe 24.03.2010
	 * @see org.as3commons.collections.fx.events.MapEvent MapEvent - Description of the map event properties.
	 * @see org.as3commons.collections.Map Map - Map description and usage examples.
	 */
	public class MapFx extends Map implements ICollectionFx {

		/**
		 * Event dispatcher.
		 */
		private var _eventDispatcher : IEventDispatcher;

		/**
		 * MapFx constructor.
		 */
		public function MapFx() {
			_eventDispatcher = new EventDispatcher(this);
		}
		
		/*
		 * IMap
		 */

		/**
		 * @inheritDoc
		 */
		override public function add(key : *, item : *) : Boolean {
			var added : Boolean = super.add(key, item);
			if (added) {
				dispatchEvent(new MapFxEvent(
					FxCollectionEvent.ITEM_ADDED,
					this,
					key,
					item
				));
				dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.ADD));
			}
			return added;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function replaceFor(key : *, item : *) : Boolean {
			var replaced : Boolean = super.replaceFor(key, item);
			if (replaced) {
				dispatchEvent(new MapFxEvent(
					FxCollectionEvent.ITEM_REPLACED,
					this,
					key,
					item
				));
				dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.REPLACE));
			}
			return replaced;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function removeKey(key : *) : * {
			var item : * = super.removeKey(key);
			if (item !== undefined) {
				dispatchEvent(new MapFxEvent(
					FxCollectionEvent.ITEM_REMOVED,
					this,
					key,
					item
				));
				dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.REMOVE));
			}
			return item;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function clear() : Boolean {
			var removed : Boolean = super.clear();
			if (removed) {
				dispatchEvent(new MapFxEvent(
					FxCollectionEvent.RESET,
					this
				));
				dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.RESET));
			}
			return removed;
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
		 * ICollectionView
		 */
		
		/**
		 * @inheritDoc
		 */
		public function get length():int
		{
			return size;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get filterFunction():Function
		{
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set filterFunction(value:Function):void {}
		
		/**
		 * @inheritDoc
		 */
		public function get sort():ISort
		{
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set sort(value:ISort):void {}
		
		/**
		 * @inheritDoc
		 */
		public function createCursor():IViewCursor
		{
			return new MapIteratorFx(this);
		}
		
		/**
		 * @inheritDoc
		 */
		public function contains(item:Object):Boolean
		{
			return has(item);
		}
		
		/**
		 * @inheritDoc
		 */
		public function disableAutoUpdate():void {}
		
		/**
		 * @inheritDoc
		 */
		public function enableAutoUpdate():void {}
		
		/**
		 * @inheritDoc
		 */
		public function itemUpdated(item:Object, property:Object = null,
									oldValue:Object = null, newValue:Object = null):void {}
		
		/**
		 * @inheritDoc
		 */
		public function refresh():Boolean
		{
			return true;
		}
	
		/*
		 * Protected
		 */

		/**
		 * @inheritDoc
		 */
		override protected function itemRemoved(key : *, item : *) : void {
			dispatchEvent(new MapFxEvent(
				FxCollectionEvent.ITEM_REMOVED,
				this,
				key,
				item
			));
			dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.REMOVE));
		}
	}
}

import org.as3commons.collections.framework.ICollectionIterator;
import org.as3commons.collections.framework.IMap;
import org.as3commons.collections.fx.events.MapEvent;

internal class MapFxEvent extends MapEvent {
	public function MapFxEvent(theKind : String, theMap : IMap, theKey : * = undefined, theItem : * = undefined) {
		super(theKind, theMap, theKey, theItem);
	}
	override public function iterator() : ICollectionIterator {
		return null;
	}
}
