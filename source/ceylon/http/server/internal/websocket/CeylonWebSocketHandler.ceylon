import ceylon.http.server {
    ServerException,
    EndpointBase
}
import ceylon.http.server.internal {
    Endpoints
}
import ceylon.http.server.websocket {
    WebSocketEndpoint,
    WebSocketFragmentedEndpoint,
    WebSocketChannel,
    WebSocketBaseEndpoint
}

import io.undertow.websockets.core {
    UtWebSocketChannel=WebSocketChannel
}
import io.undertow.websockets {
    WebSocketConnectionCallback
}
import io.undertow.websockets.spi {
    WebSocketHttpExchange
}

import org.xnio {
    IoUtils {
        safeClose
    }
}

by("Matej Lazar")
shared class CeylonWebSocketHandler() 
        satisfies WebSocketConnectionCallback {

    Endpoints endpoints = Endpoints();

    shared void addEndpoint(WebSocketBaseEndpoint endpoint) 
            => endpoints.add(endpoint);

    shared Boolean endpointExists(String requestPath) {
        if (endpoints.getEndpointMatchingPath(requestPath).size > 0) {
            return true;
        } else {
            return false;
        }
    }

    shared actual void onConnect(WebSocketHttpExchange exchange, 
            UtWebSocketChannel channel) {
        value webSocketChannel = DefaultWebSocketChannel(exchange, channel);
        EndpointBase? endpoint = endpoints.getEndpointMatchingPath(webSocketChannel.requestPath).first;
        if (is WebSocketBaseEndpoint endpoint) {
            try {
                endpoint.onOpen(webSocketChannel);
                channel.receiveSetter.set(frameHandler(endpoint, webSocketChannel));
                channel.resumeReceives();
            } catch (ServerException e) {
                safeClose(channel);
            }
        } else {
            throw ServerException("Endpoint should be defined.");
        }
    }

    CeylonWebSocketFrameHandler|CeylonWebSocketFragmentedFrameHandler frameHandler(
            WebSocketBaseEndpoint endpoint,
            WebSocketChannel webSocketChannel) {
        switch (endpoint)
        case (is WebSocketEndpoint) {
            return CeylonWebSocketFrameHandler(endpoint, webSocketChannel);
        }
        case (is WebSocketFragmentedEndpoint) {
            return CeylonWebSocketFragmentedFrameHandler(endpoint, webSocketChannel);
        }
    }
}
