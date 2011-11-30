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
	
	import org.as3commons.collections.LinkedSet;
	import org.as3commons.collections.framework.ICollectionFx;
	import org.as3commons.collections.framework.IComparator;
	import org.as3commons.collections.framework.core.LinkedNode;
	import org.as3commons.collections.framework.core.as3commons_collections;
	import org.as3commons.collections.fx.events.FxCollectionEvent;
	import org.as3commons.collections.fx.events.SetEvent;
	import org.as3commons.collections.fx.iterators.LinkedSetIteratorFx;

	/**
	 * Bindable version of the <code>LinkedSet</code> implementation.
	 * 
	 * <p><strong><code>LinkedSetFx</code> event kinds</strong></p>
	 * 
	 * <ul>
	 * <li><code>FxCollectionEvent.ITEM_ADDED</code></li>
	 * <li><code>FxCollectionEvent.ITEM_REPLACED</code></li>
	 * <li><code>FxCollectionEvent.ITEM_REMOVED</code></li>
	 * <li><code>FxCollectionEvent.RESET</code></li>
	 * </ul>
	 * 
	 * <p id="link_LinkedSetFxExample"><strong>LinkedSetFx example</strong></p>
	 * 
	 * {{EXAMPLE: LinkedSetFxExample}}
	 * 
	 * @author Jens Struwe 25.03.2010
	 * @see org.as3commons.collections.fx.events.SetEvent SetEvent - Description of the set event properties.
	 * @see org.as3commons.collections.LinkedSet LinkedSet - LinkedSet description and usage examples.
	 */
	public class LinkedSetFx extends LinkedSet implements ICollectionFx {
		
		use namespace as3commons_collections;

		/**
		 * Event dispatcher.
		 */
		private var _eventDispatcher : IEventDispatcher;

		/**
		 * LinkedSetFx constructor.
		 */
		public function LinkedSetFx() {
			_eventDispatcher = new EventDispatcher(this);
		}

		/*
		 * IOrderedSet
		 */

		/**
		 * @inheritDoc
		 */
		override public function addFirst(item : *) : Boolean {
			var added : Boolean = super.addFirst(item);
			if (added) {
				dispatchEvent(new LinkedSetFxEvent(
					FxCollectionEvent.ITEM_ADDED,
					this,
					item,
					firstNode_internal
				));
				dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.ADD));
			}
			return added;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function addLast(item : *) : Boolean {
			var added : Boolean = super.addLast(item);
			if (added) {
				dispatchEvent(new LinkedSetFxEvent(
					FxCollectionEvent.ITEM_ADDED,
					this,
					item,
					lastNode_internal
				));
				dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.ADD));
			}
			return added;
		}
		
		override public function replace(oldItem : *, item : *) : Boolean {
			var replaced : Boolean = super.replace(oldItem, item);
			if (replaced) {
				dispatchEvent(new LinkedSetFxEvent(
					FxCollectionEvent.ITEM_REPLACED, this,
					item,
					getNode(item)
				));
				dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.REPLACE));
			}
			return replaced;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function reverse() : Boolean {
			var reversed : Boolean = super.reverse();
			if (reversed) {
				dispatchEvent(new SetEvent(FxCollectionEvent.RESET, this));
				dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.RESET));
			}
			return reversed;
		}

		/**
		 * @inheritDoc
		 */
		override public function sortCollection(comparator : IComparator) : Boolean {
			var sorted : Boolean = super.sortCollection(comparator);
			if (sorted) {
				dispatchEvent(new SetEvent(FxCollectionEvent.RESET, this));
				dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.RESET));
			}
			return sorted;
		}

		/**
		 * @inheritDoc
		 */
		override public function removeFirst() : * {
			var first : LinkedNode = firstNode_internal;
			var item : * = super.removeFirst();
			if (item !== undefined) {
				dispatchEvent(new LinkedSetFxEvent(
					FxCollectionEvent.ITEM_REMOVED,
					this,
					first.item,
					firstNode_internal
				));
				dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.REMOVE));
				return first.item;
			}
			return undefined;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function removeLast() : * {
			var last : LinkedNode = lastNode_internal;
			var item : * = super.removeLast();
			if (item !== undefined) {
				dispatchEvent(new LinkedSetFxEvent(
					FxCollectionEvent.ITEM_REMOVED,
					this,
					last.item
				));
				dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.REMOVE));
				return last.item;
			}
			return undefined;
		}
		
		/*
		 * ISet
		 */
		
		/**
		 * @inheritDoc
		 */
		override public function add(item : *) : Boolean {
			var added : Boolean = super.add(item);
			if (added) {
				dispatchEvent(new LinkedSetFxEvent(
					FxCollectionEvent.ITEM_ADDED,
					this,
					item,
					getNode(item)
				));
				dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.ADD));
			}
			return added;
		}
		
		/*
		 * ICollection
		 */
		
		/**
		 * @inheritDoc
		 */
		override public function clear() : Boolean {
			var removed : Boolean = super.clear();
			if (removed) {
				dispatchEvent(new SetEvent(FxCollectionEvent.RESET, this));
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
			var node : LinkedNode = _items[undefined];
			return new LinkedSetIteratorFx(this, node);
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
		override protected function addNodeAfter(previous : LinkedNode, node : LinkedNode) : void {
			super.addNodeAfter(previous, node);
			dispatchEvent(new LinkedSetFxEvent(
				FxCollectionEvent.ITEM_ADDED,
				this,
				node.item,
				node
			));
			dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.ADD));
		}

		/**
		 * @inheritDoc
		 */
		override protected function addNodeBefore(next : LinkedNode, node : LinkedNode) : void {
			super.addNodeBefore(next, node);
			dispatchEvent(new LinkedSetFxEvent(
				FxCollectionEvent.ITEM_ADDED,
				this,
				node.item,
				node
			));
			dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.ADD));
		}

		/**
		 * @inheritDoc
		 */
		override protected function removeNode(node : LinkedNode) : void {
			var nextNode : LinkedNode = node.right;
			super.removeNode(node);
			dispatchEvent(new LinkedSetFxEvent(
				FxCollectionEvent.ITEM_REMOVED,
				this,
				node.item,
				nextNode
			));
			dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.REMOVE));
		}
	}
}

import org.as3commons.collections.framework.ICollectionIterator;
import org.as3commons.collections.framework.ISet;
import org.as3commons.collections.framework.core.LinkedNode;
import org.as3commons.collections.fx.events.SetEvent;

internal class LinkedSetFxEvent extends SetEvent {
	
	public var nextNode : LinkedNode;

	public function LinkedSetFxEvent(
		theKind : String,
		theSet : ISet,
		theItem : * = undefined,
		theNextNode : LinkedNode = null
	) {
		nextNode = theNextNode;
		
		super(theKind, theSet, theItem);
	}

	override public function iterator() : ICollectionIterator {
		if (kind == RESET) return null;
		
		if (nextNode) return set.iterator(nextNode.item) as ICollectionIterator;
		var iterator : ICollectionIterator = set.iterator() as ICollectionIterator;
		iterator.end();
		return iterator;
	}
}
