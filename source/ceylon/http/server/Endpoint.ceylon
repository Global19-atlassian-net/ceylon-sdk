import ceylon.http.common {
    Method
}

"Synchronous web endpoint."
by("Matej Lazar")
shared class Endpoint(Matcher path, service, 
    {Method*} acceptMethod)  
        extends HttpEndpoint(path, acceptMethod) {
    
    "Process the request."
    shared void service(Request request, Response response);
    
}