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
import org.junit.After
import org.junit.Test
import org.junit.runner.RunWith
import zarnekow.newsgroup.AnalyzerConfiguration
import zarnekow.newsgroup.model.NewsgroupRepository

import static org.junit.Assert.*

@RunWith(InjectingRunner)
@TestModules(AnalyzerConfiguration)
class NewsgroupRepositoryTest {

	@Inject
	NewsgroupRepository repository

	@After
	def void discard() {
		repository.clear
	}
	
	@Test def void testCreateSingleUser() {
		val user = repository.getOrCreate("newsgroup")
		assertNotNull(user)
		assertEquals(1, repository.allNewsgroups.size)
		assertTrue(repository.allNewsgroups.contains(user))
		assertSame(user, repository.getOrCreate("newsgroup"))
	}
	
	@Test def void testCreateTwoUsers() {
		val first = repository.getOrCreate("n1")
		val second = repository.getOrCreate("n2")
		assertNotSame(first, second)
		assertEquals(2, repository.allNewsgroups.size)
	}
}