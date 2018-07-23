/*
 * Copyright 2018 Enkel Informatica
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package br.com.enkel.hystrixproxy.commands;

import java.io.FileInputStream;
import java.io.IOException;
import java.nio.charset.Charset;

import org.apache.commons.io.IOUtils;
import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.HttpVersion;
import org.apache.http.StatusLine;
import org.apache.http.entity.StringEntity;
import org.apache.http.message.BasicStatusLine;
import org.apache.http.message.BasicHeader;
import org.apache.http.Header;
import org.apache.http.util.EntityUtils;
import org.mockito.Mockito;

import com.netflix.config.DynamicPropertyFactory;
import com.netflix.hystrix.HystrixCommand;

/***
 * Implemetação customizada de um {@link HystrixCommand}
 * Implementa fallback que realiza carga de um response mock;
 */
public abstract class ProxyCircuitBreakerCommand extends HystrixCommand<HttpResponse> {

	public ProxyCircuitBreakerCommand(Setter setter) {
		super(setter);
	}

	/**
	 * Subclasses deste comando precisam implementar este método
	 * @return
	 * @throws Exception
	 */
	protected abstract HttpResponse doRun() throws Exception;

	/**
	 *
	 */
	@Override
	protected final HttpResponse run() throws Exception {
		HttpResponse response = doRun();

		if (this.isResponseTimedOut()){
			//Caso o Hystrix interrompa a execução do comando antes do HTTP timeout,
			//o response precisa ser consumido de alguma forma para garantir a devolução da conexão ao pool.
			EntityUtils.consume(response.getEntity());
			return null;
		}

		return response;
	}

	/***
	 * Implementação de fallback
	 * Verifica se o comando tem a opção de fallback habilitada
	 */
	@Override
	protected final HttpResponse getFallback() {
		return this.createMockedResponse();
	}

	/***
	 * Tenta criar um payload mock a partir do conteúdo de um arquivo referenciado
	 * nas propriedades do Hystrix
	 */
	private HttpResponse createMockedResponse() {
		String mockPayloadLocation = DynamicPropertyFactory.getInstance()
				.getStringProperty(String.format("hystrix.command.%s.fallback.payload.location", this.getCommandKey().name()), null)
				.get();
		if (mockPayloadLocation == null || mockPayloadLocation.isEmpty()) {
			String path = this.getCommandKey().name().substring(0, this.getCommandKey().name().indexOf("-"));
			mockPayloadLocation = DynamicPropertyFactory.getInstance()
			.getStringProperty(String.format("hystrix.command.%s.fallback.payload.location", path), null)
			.get();
		}

		if (mockPayloadLocation != null) {
			try {
				FileInputStream inputStream = new FileInputStream(mockPayloadLocation);
				try{
					String content = IOUtils.toString(inputStream, Charset.defaultCharset());
					
					HttpResponse response = Mockito.mock(HttpResponse.class);

					//headers
					StatusLine statusLine = new BasicStatusLine(new HttpVersion(1, 1), mockPayloadLocation.endsWith(".xml") ? HttpStatus.SC_INTERNAL_SERVER_ERROR : HttpStatus.SC_SERVICE_UNAVAILABLE, "");
					Mockito.when(response.getStatusLine()).thenReturn(statusLine);
					Mockito.when(response.getEntity()).thenReturn(new StringEntity(content));
					Mockito.when(response.getAllHeaders()).thenReturn(new Header[] {new BasicHeader("Mock-Payload", "true"), new BasicHeader("Content-Type", mockPayloadLocation.endsWith(".xml") ? "text/xml" : "application/json")});

					return response;
				}
				finally{
					inputStream.close();
				}

			} catch (IOException e) {
				throw new UnsupportedOperationException("Mocked Payload not found");
			}
		}
		else {
			throw new UnsupportedOperationException("Mocked Payload not found");
		}
	}

}
