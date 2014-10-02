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
package zarnekow.newsgroup

import com.google.common.base.Strings
import com.google.inject.AbstractModule
import com.google.inject.Guice
import com.google.inject.Inject
import java.io.BufferedReader
import java.io.FileInputStream
import java.io.InputStreamReader
import java.util.Set
import zarnekow.newsgroup.io.TxtReader
import zarnekow.newsgroup.mining.MiningModule
import zarnekow.newsgroup.mining.NewsgroupAnalyzer
import zarnekow.newsgroup.model.ModelModule
import zarnekow.newsgroup.model.NewsgroupRepository

class Analyzer {
	
	@Inject
	TxtReader txtReader
	
	@Inject
	NewsgroupRepository newsgroups
	
	@Inject
	Set<NewsgroupAnalyzer> analyzers
	
	def static void main(String[] args) {
		val injector = Guice.createInjector(new AnalyzerConfiguration)
		injector.getInstance(Analyzer).run
	}
	
	def void run() {
		println("Enter path to exported newsgroup data - empty line starts mining:")
		val reader = new BufferedReader(new InputStreamReader(System.in))
		var line = reader.readLine
		while(line != '') {
			new InputStreamReader(new FileInputStream(line), 'UTF-8') => [
				try {
					txtReader.readMessages(it)	
				} finally {
					close
				}
			]
			line = reader.readLine
		}
		for(analyzer: analyzers) {
			println(analyzer.description)
			println(Strings.repeat('=', analyzer.description.length))
			newsgroups.allNewsgroups.forEach [
				println(id)
				println(Strings.repeat('-', id.length))
				analyzer.process(it)
				println
			]
		}
	}
	
	
}

class AnalyzerConfiguration extends AbstractModule {
	
	override protected configure() {
		binder.install(new ModelModule)
		binder.install(new MiningModule)
		
	}
	
}