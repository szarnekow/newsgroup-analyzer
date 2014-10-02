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
package zarnekow.newsgroup.tests

import com.google.inject.Inject
import java.io.InputStreamReader
import java.io.StringReader
import org.junit.After
import org.junit.Test
import org.junit.runner.RunWith
import zarnekow.newsgroup.AnalyzerConfiguration
import zarnekow.newsgroup.io.TxtReader
import zarnekow.newsgroup.model.MessageBuilder.MessageRepositoryImpl
import zarnekow.newsgroup.model.NewsgroupRepository
import zarnekow.newsgroup.model.UserRepository

import static org.junit.Assert.*

@RunWith(InjectingRunner)
@TestModules(AnalyzerConfiguration)
class TxtReaderTest {
	@Inject
	TxtReader txtReader
	
	@Inject
	MessageRepositoryImpl repository
	@Inject
	UserRepository userRepository
	@Inject
	NewsgroupRepository newsgroupRepository
	
	@After
	def void discard() {
		repository.clear
		userRepository.clear
		newsgroupRepository.clear
	}
	
	@Test
	def void testReadMinimalMessage() {
		val messageString = '''
			Path: path
			From: from
			Newsgroups: newsgroup
			Subject: subject
			Date: Fri, 9 Apr 2010 03:49:54 +0000 (UTC)
			Organization: n/a
			Lines: 1
			Message-ID: <hpm852$6lf$2@acme.org>
			Xref: xref
			
			content
		'''
		val reader = new StringReader(messageString)
		val messages = txtReader.readMessages(reader)
		assertEquals(1, messages.size)
	}
	
	@Test
	def void testReadOneMessage() {
		doReadMessages('/messages/OneMessage.txt', 1)
	}
	
	def doReadMessages(String path, int expected) {
		val inputStream = getClass.getResourceAsStream(path)
		val reader = new InputStreamReader(inputStream, 'UTF-8')
		try {
			val messages = txtReader.readMessages(reader)
			assertEquals(expected, messages.size)
			return messages	
		} finally {
			reader.close
		}
	}
	
	@Test
	def void testReadTwoMessages() {
		val messages = doReadMessages('/messages/TwoMessages.txt', 2)
		assertEquals('''
			
			No, won't work.
			
		'''.toString, messages.head.content)
	}
	
}	
