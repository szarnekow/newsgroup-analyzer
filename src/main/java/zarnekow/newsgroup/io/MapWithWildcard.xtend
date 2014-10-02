/**
 * Copyright (C) 2014 Sebastian Zarnekow
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package zarnekow.newsgroup.io

import java.util.Map
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

package class MapWithWildcard<K, V> {
	
	Map<K, V> map = newHashMap
	
	val V defaultValue

	@FinalFieldsConstructor	
	new() {
	}
	
	def void put(K k, V v) {
		map.put(k, v)
	}
	
	def V get(K k) {
		return map.get(k) ?: defaultValue
	}
	
}