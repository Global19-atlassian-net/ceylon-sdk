import java.net { URI }
import test.ceylon.http.server.websocketclient { WebSocketClient }
import ceylon.http.server.websocket { WebSocketChannel, CloseReason, WebSocketEndpoint }
import ceylon.test { assertTrue, assertEquals, test }
import ceylon.http.server { startsWith, started, Status, stopped, newServer }
import ceylon.buffer { ByteBuffer }
import io.netty.channel.nio { NioEventLoopGroup }
import io.netty.channel { EventLoopGroup }
import ceylon.buffer.charset { utf8 }
import io.netty.handler.codec.http.websocketx { WebSocketHandshakeException }

by("Matej Lazar")
shared class TestWebSocketServer() extends ServerTest(){

    variable Boolean onOpenCalled = false;
    variable Boolean onTextCalled = false;
    variable Boolean onBinaryCalled = false;
    variable Boolean onCloseCalled = false;
    variable Integer messagesReceived = 0;
    
    
    void onOpen(WebSocketChannel channel) {
        onOpenCalled = true;
        //TODO log
        print("server: Channel opened.");
        assertTrue(channel.open(), "Channel should be open.");
    }
    
    void onClose(WebSocketChannel channel, CloseReason closeReason) {
        onCloseCalled = true;
        assertEquals(10, messagesReceived, "Invalid number of received messages.");
        
        //TODO log
        print("server: Closing channel...");
    }
    
    void onError(WebSocketChannel webSocketChannel, Throwable? throwable) {
        //TODO
    }

    shared actual {WebSocketEndpoint+} endpoints =>
    [WebSocketEndpoint {
        path = startsWith("/websocket");
        onOpen => onOpen;
        onClose => onClose;
        onError => onError;
        onText = void (WebSocketChannel channel, String text) {
            onTextCalled = true;
            print("Server received: ``text``");
            assertEquals("Message #``messagesReceived.string``", text);
            messagesReceived++;
            channel.sendText(text.uppercased);
        };
        onBinary = void (WebSocketChannel channel, ByteBuffer binary) {
            onBinaryCalled = true;
            String data = utf8.decode(binary);
            print("Server received binary message: ``data``");
            value encoded = utf8.encodeBuffer(data.uppercased);
            channel.sendBinary(encoded);
        };}
        ];
    
    
    test
    shared void testWebSocket() {
        URI uri = URI("ws://localhost:8080/websocket");
        EventLoopGroup group = NioEventLoopGroup(); 
        
        try {
            value client = WebSocketClient(uri);
            client.connect(group);
            client.sendMessages();
            client.sendBinaryMessages();
            client.sendPing();
            client.sendClose();
            
            client.waitForClose();
            
            assertTrue(onOpenCalled, "Endpoints method onOpen was not called");
            assertTrue(onTextCalled, "Endpoints method onText was not called");
            assertTrue(onBinaryCalled, "Endpoints method onBinary was not called");
            assertTrue(onCloseCalled, "Endpoints method onClose was not called");
            
            value client2 = WebSocketClient(URI("ws://localhost:8080/notfoundwebsocket"));
            variable String exception = "";
            try {
                client2.connect(group);
            } catch (WebSocketHandshakeException e) {
                exception = e.message;
            }
            if (!exception.contains("404 Not Found")) {
                throw AssertionError("Expected WebSocketHandshakeException with 404 Not Found.");
            }
        } finally {
            group.shutdownGracefully();
        } 
    }
    
}
