package io.confluent.demo.datamesh;

import org.apache.catalina.connector.RequestFacade;
import org.apache.catalina.connector.ResponseFacade;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.util.StringUtils;

import javax.servlet.*;
import java.io.IOException;

public class TrustedEndpointsFilter implements Filter {

    private int trustedPortNum = 0;
    private String trustedPathPrefix;
    private final Logger log = LoggerFactory.getLogger(getClass().getName());

    TrustedEndpointsFilter(String trustedPort, String trustedPathPrefix) {
        if (StringUtils.hasLength(trustedPort) &&
                StringUtils.hasLength(trustedPathPrefix) &&
                !"null".equals(trustedPathPrefix)) {

            trustedPortNum = Integer.valueOf(trustedPort);
            this.trustedPathPrefix = trustedPathPrefix;

        }
    }

    private boolean isRequestForTrustedEndpoint(ServletRequest servletRequest) {
        return ((RequestFacade) servletRequest).getRequestURI().startsWith(trustedPathPrefix);
    }

    @Override
    public void doFilter(final ServletRequest servletRequest,
                         final ServletResponse servletResponse,
                         final FilterChain filterChain) throws IOException, ServletException {

        if (trustedPortNum != 0) {
            if (isRequestForTrustedEndpoint(servletRequest) && servletRequest.getLocalPort() != trustedPortNum) {

                String uri = ((RequestFacade) servletRequest).getRequestURI();

                log.warn(String.format("denying request for trusted endpoint on untrusted port: %s", uri));
                ((ResponseFacade) servletResponse).setStatus(404);
                servletResponse.getOutputStream().close();
                return;
            }

            if (!isRequestForTrustedEndpoint(servletRequest) && servletRequest.getLocalPort() == trustedPortNum) {

                String uri = ((RequestFacade) servletRequest).getRequestURI();

                log.warn(String.format("denying request for untrusted endpoint on trusted port: %s", uri));
                ((ResponseFacade) servletResponse).setStatus(404);
                servletResponse.getOutputStream().close();
                return;
            }
        }

        filterChain.doFilter(servletRequest, servletResponse);

    }
}
