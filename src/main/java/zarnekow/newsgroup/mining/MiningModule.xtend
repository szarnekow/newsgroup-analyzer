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

import com.google.inject.AbstractModule
import com.google.inject.multibindings.Multibinder

class MiningModule extends AbstractModule {
	
	override protected configure() {
		val multiBinder = Multibinder.newSetBinder(binder, NewsgroupAnalyzer)
		multiBinder.addBinding.to(TotalNumberOfMessages)
		multiBinder.addBinding.to(MessagesPerTimeUnit)
		multiBinder.addBinding.to(NewUsersPerTimeUnit)
		multiBinder.addBinding.to(DistinctUsersPerTimeUnit)
		multiBinder.addBinding.to(MessagesWithoutResponse)
		multiBinder.addBinding.to(NewUserQuestionsWithoutResponse)
		multiBinder.addBinding.to(UsersWithMoreThanOneMessagePerTimeUnit)
		multiBinder.addBinding.to(NewThreadsPerTimeUnit)
	}
	
}