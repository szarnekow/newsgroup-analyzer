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

import com.google.inject.Inject
import java.util.Collection
import java.util.Map
import java.util.TreeMap
import zarnekow.newsgroup.model.Message
import zarnekow.newsgroup.model.Newsgroup

interface NewsgroupAnalyzer {
	def String getDescription()
	def void process(Newsgroup group)
}

class TotalNumberOfMessages implements NewsgroupAnalyzer {
	
	override getDescription() {
		'Total number of messages'
	}
	
	override process(Newsgroup group) {
		println(group.allMessages.size)
	}
	
}

class MessagesPerTimeUnit implements NewsgroupAnalyzer {
	
	@Inject
	extension Dates
	
	override getDescription() {
		'Total Messages per Time Unit'
	}
	
	override process(Newsgroup group) {
		process(group.allMessages)
	}
	
	def process(Iterable<Message> messages) {
		messages.process [ size ]
	}
	
	def process(Iterable<Message> messages, (Collection<Message>)=>int counter) {
		messages.sortBy[date].reverseView.groupBy[ date.toYear ].forEach[ year, msgs |
			println('''«year»: «counter.apply(msgs)»''')
			print('Q1 - Q4: ')
			msgs.groupBy[ switch(date.toMonth) {
				case 0,
				case 1,
				case 2: 'Q1'
				case 3,
				case 4,
				case 5: 'Q2'
				case 6,
				case 7,
				case 8: 'Q3'
				case 9,
				case 10,
				case 11: 'Q4'
			} ].sort.forEach[quarter, perQuarter |
				print(''' «counter.apply(perQuarter)»''')
			]
			println
			print('Jan - Dec: ')
			msgs.groupBy[ date.toMonth ].sort.forEach[month, perMonth |
				print(''' «counter.apply(perMonth)»''')
			]
			println
			print('Mon - Sun: ')
			msgs.groupBy[ date.toDayOfWeek ].sort.forEach[day, perWeekday |
				print(''' «counter.apply(perWeekday)»''')
			]
			println
		]
	}
	
	def <K extends Comparable<? super K>, V> sort(Map<K, V> map) {
		new TreeMap(map)
	}
	
}

class NewUsersPerTimeUnit implements NewsgroupAnalyzer {
	
	@Inject
	MessagesPerTimeUnit messagesPerTimeUnit
	
	override getDescription() {
		'New Users per Time Unit'
	}
	
	override process(Newsgroup group) {
		val byUser = group.allMessages.sortBy[date].groupBy[ user ]
		messagesPerTimeUnit.process(byUser.mapValues[ head ].values)
	}
}

class DistinctUsersPerTimeUnit implements NewsgroupAnalyzer {
	
	@Inject
	MessagesPerTimeUnit messagesPerTimeUnit
	
	override getDescription() {
		'Distinct Users per Time Unit'
	}
	
	override process(Newsgroup group) {
		messagesPerTimeUnit.process(group.allMessages) [
			map [ user ].toSet.size
		]
	}
}

class MessagesWithoutResponse implements NewsgroupAnalyzer {
	
	@Inject
	MessagesPerTimeUnit messagesPerTimeUnit
	
	override getDescription() {
		'Messages Without Response per Time Unit'
	}
	
	override process(Newsgroup group) {
		messagesPerTimeUnit.process(group.allMessages.filter[
			!hasParent && children.empty
		])
	}
}

class NewThreadsPerTimeUnit implements NewsgroupAnalyzer {
	
	@Inject
	MessagesPerTimeUnit messagesPerTimeUnit
	
	override getDescription() {
		'New threads per Time Unit'
	}
	
	override process(Newsgroup group) {
		messagesPerTimeUnit.process(group.allMessages) [
			filter[ !hasParent ].size
		]
	}
}

class NewUserQuestionsWithoutResponse implements NewsgroupAnalyzer {
	
	@Inject
	MessagesPerTimeUnit messagesPerTimeUnit
	
	override getDescription() {
		'New Users Questions Without Response per Time Unit'
	}
	
	override process(Newsgroup group) {
		val byUser = group.allMessages.sortBy[date].groupBy[ user ].filter[ $1.size == 1 ]
		messagesPerTimeUnit.process(byUser.mapValues[ head ].values) [
			filter[
				!hasParent && children.empty
			].size
		]
	}
}

class UsersWithMoreThanOneMessagePerTimeUnit implements NewsgroupAnalyzer {
	
	@Inject
	MessagesPerTimeUnit messagesPerTimeUnit
	
	override getDescription() {
		'Users with more than one message per Time Unit'
	}
	
	override process(Newsgroup group) {
		messagesPerTimeUnit.process(group.allMessages) [
			groupBy [ user ].filter[ $1.size > 1 ].size
		]
	}
}