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

import com.google.common.collect.ArrayListMultimap
import com.google.common.collect.ListMultimap
import com.google.inject.Inject
import java.util.Collection
import java.util.Date
import java.util.List
import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors
import zarnekow.newsgroup.model.MessageBuilder.MessageRepositoryImpl

class MessageBuilder {
	
	@Accessors(PUBLIC_GETTER)
	static class MessageImpl implements Message {
		String id
		@Accessors(NONE)
		String parentId
		User user
		Date date
		List<Newsgroup> newsgroups = newArrayList
		Map<String, String> otherHeaders = newLinkedHashMap
		String subject
		String content
		
		@Accessors(NONE)
		MessageRepository messageRepository
		
		new(MessageRepository messageRepository) {
			this.messageRepository = messageRepository
		}
		
		override getChildren() {
			return messageRepository.getChildren(id)
		}
		
		override hasParent() {
			parentId != null
		}
		
		override getParent() {
			if (parentId == null)
				return null
			val result = messageRepository.getMessage(parentId)
			return result
		}
		
		override toString() {
			id
		}
		
	}
	
	static class MessageRepositoryImpl implements MessageRepository {
		Map<String, Message> messages = newLinkedHashMap
		ListMultimap<String, Message> messagesByParent = ArrayListMultimap.create
		ListMultimap<String, Message> messagesByNewsgroup = ArrayListMultimap.create
		
		override getMessage(String id) {
			messages.get(id)
		}
		
		override getChildren(String parentId) {
			messagesByParent.get(parentId)
		}
		
		override getMessages(String newsgroupId) {
			messagesByNewsgroup.get(newsgroupId)
		}
		
		override getAllMessages() {
			return messages.values.unmodifiableView
		}
		
		def void clear() {
			messages.clear
			messagesByParent.clear
			messagesByNewsgroup.clear
		}
	}

	MessageRepositoryImpl messageRepository
	MessageImpl result
	
	@Inject
	new (MessageRepositoryImpl messageRepository) {
		this.messageRepository = messageRepository
		result = new MessageImpl(messageRepository)
	}
	
	def void setId(String messageId) {
		result.id = messageId
		messageRepository.messages.put(messageId, result)
	}
	
	def void setDate(Date date) {
		result.date = date
	}
	
	def void setParent(String parentId) {
		result.parentId = parentId
		messageRepository.messagesByParent.put(parentId, result)
	}
	
	def void addNewsgroup(Newsgroup newsgroup) {
		result.newsgroups.add(newsgroup)
		messageRepository.messagesByNewsgroup.put(newsgroup.id, result)
	}
	
	def void setUser(User user) {
		result.user = user
	}
	
	def void setSubject(String subject) {
		result.subject = subject
	}
	
	def void setContent(String content) {
		result.content = content
	}
	
	def void addAdditionalHeader(String key, String value) {
		result.otherHeaders.put(key, value)
	}
	
	def getMessage() {
		val result = this.result
		if (result == null) {
			throw new NullPointerException
		}
		this.result = null
		return result
	}
	
}

package interface MessageRepository {
	def Message getMessage(String id)
	def List<Message> getMessages(String newsgroupId)
	def List<Message> getChildren(String parentId)
	def Collection<Message> getAllMessages()
}

interface Message {
	def String getId()
	def Message getParent()
	def boolean hasParent()
	def List<Message> getChildren()
	def Date getDate()
	def User getUser()
	def List<Newsgroup> getNewsgroups()
	def String getSubject()
	def String getContent()
	def Map<String, String> getOtherHeaders()
}