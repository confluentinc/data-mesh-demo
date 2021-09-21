package io.confluent.demo.datamesh;

import org.apache.catalina.connector.Connector;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.web.ServerProperties;
import org.springframework.boot.autoconfigure.web.servlet.TomcatServletWebServerFactoryCustomizer;
import org.springframework.boot.web.embedded.tomcat.TomcatServletWebServerFactory;
import org.springframework.boot.web.server.WebServerFactoryCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.util.StringUtils;

import java.util.HashSet;
import java.util.Set;

//@Configuration
public class TrustedPortConfiguration {

    @Value("${server.port:8080}")
    private String serverPort;

    @Value("${management.port:${server.port:8080}}")
    private String managementPort;

    @Value("${server.trustedPort:null}")
    private String trustedPort;

    private Connector[] additionalConnector() {

        if (!StringUtils.hasLength(this.trustedPort)) {
            return null;
        }

        Set<String> defaultPorts = new HashSet<>();
        defaultPorts.add(this.serverPort);
        defaultPorts.add(this.managementPort);

        if (!defaultPorts.contains(this.trustedPort)) {
            Connector connector = new Connector("org.apache.coyote.http11.Http11NioProtocol");
            connector.setScheme("http");
            connector.setPort(Integer.valueOf(trustedPort));
            return new Connector[]{ connector };
        } else {
            return new Connector[]{};
        }
    }

    private class TomcatMultiConnectorServletWebServerFactoryCustomizer extends TomcatServletWebServerFactoryCustomizer {
        private final Connector[] additionalConnectors;

        TomcatMultiConnectorServletWebServerFactoryCustomizer(ServerProperties serverProperties,
                                                              Connector[] additionalConnectors) {
            super(serverProperties);
            this.additionalConnectors = additionalConnectors;
        }

        @Override
        public void customize(TomcatServletWebServerFactory factory) {
            super.customize(factory);

            if (additionalConnectors != null && additionalConnectors.length > 0) {
                factory.addAdditionalTomcatConnectors(additionalConnectors);
            }
        }
    }

    @Bean
    public WebServerFactoryCustomizer servletContainer() {
        return new TomcatMultiConnectorServletWebServerFactoryCustomizer(
                new ServerProperties(),
                this.additionalConnector());
    }
}