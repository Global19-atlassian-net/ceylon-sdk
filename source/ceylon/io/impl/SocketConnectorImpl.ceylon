import ceylon.io {
    Socket,
    SocketAddress,
    Selector,
    SocketConnector,
    SslSocketConnector,
    SslSocket
}

import java.net {
    InetSocketAddress
}
import java.nio.channels {
    SocketChannel {
        openSocket=open
    },
    JavaSelector=Selector,
    SelectionKey
}

shared class SocketConnectorImpl(SocketAddress address) 
        satisfies SocketConnector{
    
    shared SocketChannel channel = openSocket();
    
    shared default actual Socket connect() {
        channel.connect(InetSocketAddress(address.address, 
            address.port));
        return createSocket();
    }
    
    shared default Socket createSocket() => SocketImpl(channel);
    
    shared actual void connectAsync(Selector selector, 
        void connect(Socket socket), Anything(Exception)? connectFailure = null) {
        channel.configureBlocking(false);
        channel.connect(InetSocketAddress(address.address, 
            address.port));
        selector.addConnectListener(this, connect, connectFailure);
    }
    
    shared actual void close() => channel.close();
    
    shared default SelectionKey register(JavaSelector selector, 
        Integer ops, Object attachment)
            => channel.register(selector, ops, attachment);
    
    shared default void interestOps(SelectionKey key, Integer ops) 
            => key.interestOps(ops);
}

shared class SslSocketConnectorImpl(SocketAddress address) 
        extends SocketConnectorImpl(address)
    satisfies SslSocketConnector {

    shared actual SslSocket connect() {
        channel.connect(InetSocketAddress(address.address, 
            address.port));
        return createSocket();
    }
    
    shared actual SslSocket createSocket() => SslSocketImpl(channel);
}