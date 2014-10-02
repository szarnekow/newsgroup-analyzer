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
package zarnekow.newsgroup.mining

import java.util.Date
import java.util.Calendar

package class Dates {
	def toYear(Date date) {
		date.to(Calendar.YEAR)
	}
	
	def toMonth(Date date) {
		date.to(Calendar.MONTH)
	}
	
	def toDayOfWeek(Date date) {
		switch( day: date.to(Calendar.DAY_OF_WEEK)) {
			case 1: 7
			default: day - 1
		}
	}
	
	private def to(Date date, int field) {
		(Calendar.getInstance => [
			it.time = date
		]).get(field)
	}
}