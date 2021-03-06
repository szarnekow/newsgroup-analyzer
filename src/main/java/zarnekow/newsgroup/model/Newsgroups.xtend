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
package zarnekow.newsgroup.model

import com.google.inject.Inject
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data

class NewsgroupRepository extends Repository<Newsgroup> {
	
	@Inject
	MessageRepository messagesRepository;
	
	override createObject(String id) {
		new Newsgroup(id, messagesRepository)
	}
	
	def getAllNewsgroups() {
		return allInstances
	}
	
}

@Data
class Newsgroup {
	String id
	@Accessors(NONE)
	MessageRepository messageRepository
	
	def getMessage(String id) {
		val result = messageRepository.getMessage(id)
		if (result == null || !result.newsgroups.contains(this)) {
			return null
		}
		return result
	}
	
	def getUsers() {
		allMessages.map [ user ].toSet
	}
	
	def getAllMessages() {
		messageRepository.getMessages(id).unmodifiableView
	}
}