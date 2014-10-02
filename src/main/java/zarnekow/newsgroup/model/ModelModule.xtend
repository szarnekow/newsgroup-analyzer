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

import com.google.inject.AbstractModule
import zarnekow.newsgroup.model.MessageBuilder.MessageRepositoryImpl
import com.google.inject.Scopes

class ModelModule extends AbstractModule {
	
	override protected configure() {
		bind(MessageRepository).to(MessageRepositoryImpl)
		bind(MessageRepositoryImpl).in(Scopes.SINGLETON)
		bind(UserRepository).in(Scopes.SINGLETON)
		bind(NewsgroupRepository).in(Scopes.SINGLETON)
	}
	
}