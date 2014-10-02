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

import com.google.common.collect.AbstractIterator
import com.google.common.collect.Iterators
import com.google.common.collect.PeekingIterator
import com.google.inject.Inject
import com.google.inject.Provider
import java.io.BufferedReader
import java.io.Reader
import java.text.SimpleDateFormat
import java.util.List
import java.util.Locale
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import zarnekow.newsgroup.model.Message
import zarnekow.newsgroup.model.MessageBuilder
import zarnekow.newsgroup.model.NewsgroupRepository
import zarnekow.newsgroup.model.UserRepository

class TxtReader {
	@Inject
	UserRepository users
	
	@Inject
	NewsgroupRepository newsgroups
	
	@Inject
	Provider<MessageBuilder> messageBuilderProvider
	
	def List<Message> readMessages(Reader reader) {
		val buffy = new BufferedReader(reader)
		return new ReaderSession(Iterators.peekingIterator(new AbstractIterator<String>() {
			override protected computeNext() {
				val result = buffy.readLine
				if (result == null) {
					return endOfData
				}
				return result
			}
		}), users, newsgroups, messageBuilderProvider).process
	}
	
}

class ReaderSession {
	
	static val dateFormat = new SimpleDateFormat("EEE, d MMM yyyy HH:mm:ss Z '('z')'", Locale.ENGLISH)
	
	val processors = new MapWithWildcard<String, (String, String)=>void> [
		messageBuilder.addAdditionalHeader($0, $1)
	] => [
		put('From') [
			messageBuilder.user = users.getOrCreate($1.trim)
		]
		put('Newsgroups') [
			val newsgroupIds = $1.split(",")
			newsgroupIds.forEach [
				messageBuilder.addNewsgroup(newsgroups.getOrCreate(trim))
			]
		]
		put('NNTP-Posting-Date') [
			messageBuilder.date = dateFormat.parse($1)
		]
		put('Subject') [
			messageBuilder.subject = $1
		]
		put('Lines') [
			lineCount = Integer.parseInt($1)
			messageBuilder.addAdditionalHeader($0, $1)
		]
		put('References') [
			messageBuilder.parent = $1.split('\\s+').head
		]
		put('Message-ID') [
			messageBuilder.id = $1
		]
	]
	
	val List<Message> result = newArrayList
	val PeekingIterator<String> lines
	val UserRepository users
	val NewsgroupRepository newsgroups
	val Provider<MessageBuilder> messageBuilderProvider
	
	int lineCount
	MessageBuilder messageBuilder

	@FinalFieldsConstructor	
	new() {
	}
	
	def process() {
		while(true) {
			this.messageBuilder = messageBuilderProvider.get
			processMessage
			if (lines.hasNext) {
				skipUntilNextMessage
			} else {
				return result
			}
		}
	}
	
	def skipUntilNextMessage() {
		while(lines.hasNext) {
			val next = lines.peek
			if (next.startsWith('Path: ')) {
				return
			}
			lines.next
		}
	}
	
	def void processMessage() {
		while(lines.hasNext) {
			val line = lines.next
			if (line.isEmpty) {
				readContent
				return
			} else {
				val colon = line.indexOf(': ')
				if (colon == -1) {
					throw new IllegalStateException(line)
				}
				val key = line.substring(0, colon)
				var value = line.substring(colon + 2)
				while (lines.hasNext && (lines.peek.startsWith(' ') || lines.peek.startsWith('\t'))) {
					value = value + lines.next
				}
				processors.get(key).apply(key, value)
			}
		}
	}
	
	def readContent() {
		val content = new StringBuilder
		while(lineCount > 0) {
			content.append(lines.next)
			content.append('\n')
			lineCount--
		}
		messageBuilder.content = content.toString
		result.add(messageBuilder.message)
		messageBuilder = null
	}
	
	def readLine(String prefix) {
		val line = lines.next
		if (!line.startsWith(prefix)) {
			throw new IllegalStateException(line)
		}
		return line.substring(prefix.length)
	}
	
}