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
import java.util.Date
import org.junit.After
import org.junit.Test
import org.junit.runner.RunWith
import zarnekow.newsgroup.AnalyzerConfiguration
import zarnekow.newsgroup.model.MessageBuilder
import zarnekow.newsgroup.model.MessageBuilder.MessageRepositoryImpl
import zarnekow.newsgroup.model.NewsgroupRepository
import zarnekow.newsgroup.model.UserRepository

import static org.junit.Assert.*

@RunWith(InjectingRunner)
@TestModules(AnalyzerConfiguration)
class MessageBuilderTest {
	
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
	def void testBuildEmptyMessage() {
		val builder = new MessageBuilder(repository)
		builder.id = "myMessage"
		val message = builder.message
		assertEquals("myMessage", message.id)
		assertTrue(message.children.empty)
		assertNull(message.date)
		assertNull(message.subject)
		assertNull(message.content)
		assertNull(message.user)
		assertTrue(message.newsgroups.empty)
		assertNull(message.parent)
	}
	
	@Test
	def void testBuildCompleteMessage() {
		val builder = new MessageBuilder(repository)
		builder.id = "myMessage"
		val newsgroup = newsgroupRepository.getOrCreate("newsgroup")
		builder.addNewsgroup(newsgroup)
		val user = userRepository.getOrCreate("user")
		builder.user = user
		val date = new Date()
		builder.date = date
		builder.content = "content"
		builder.subject = "subject"
		
		val message = builder.message
		assertEquals("myMessage", message.id)
		assertTrue(message.children.empty)
		assertEquals(date, message.date)
		assertEquals("subject", message.subject)
		assertEquals("content", message.content)
		assertEquals(newArrayList(newsgroup), message.newsgroups)
		assertEquals(user, message.user)
		assertNull(message.parent)
	}
	
	@Test
	def void testBuildMessageWithParent() {
		val childBuilder = new MessageBuilder(repository)
		childBuilder.id = "child"
		childBuilder.parent = 'parent'
		val child = childBuilder.message
		
		val parentBuilder = new MessageBuilder(repository)
		parentBuilder.id = "parent"
		val parent = parentBuilder.message
		
		assertSame(parent, child.parent)
		assertEquals(newArrayList(child), parent.children)
	}
	
	@Test(expected = NullPointerException)
	def void testReuseBuilder_01() {
		val builder = new MessageBuilder(repository)
		builder.id = "myMessage"
		builder.message
		builder.message
	}
	
	@Test(expected = NullPointerException)
	def void testReuseBuilder_02() {
		val builder = new MessageBuilder(repository)
		builder.id = "myMessage"
		builder.message
		builder.content = ''
	}
}