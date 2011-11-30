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
package org.as3commons.collections.framework {
	import flash.events.IEventDispatcher;
	
	import mx.collections.ICollectionView;

	/**
	 * Bindable collection marker interface.
	 * 
	 * @author Jens Struwe 22.03.2010
	 * @see org.as3commons.collections.fx.events.CollectionEvent CollectionEvent - Collection event description and usage examples. 
	 */
	public interface ICollectionFx extends ICollection, IEventDispatcher, ICollectionView {
	}
}
