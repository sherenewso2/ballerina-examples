import ballerina/http;
import ballerina/runtime;
import ballerina/io;

endpoint http:Listener failoveruEP {
    port:9090
};

endpoint http:Listener backendEP {
    port:8080
};

endpoint http:Client backendClientEP {
    lbMode: {
        failoverCodes : [400, 404, 500],
        interval : 0
    },
    targets: [
             {url: "http://localhost:300000/mock"},
             {url: "http://localhost:8080/echo"},
             {url: "http://localhost:8080/mock"}],
    timeoutMillis:5000
};

@http:ServiceConfig {
    basePath:"/fo"
}
service<http:Service> failover bind failoveruEP {

    @http:ResourceConfig {
        methods:["GET", "POST"],
        path:"/"
    }
    doFailover (endpoint client, http:Request request) {
        http:Response response = new;
        http:HttpConnectorError err = {};
        var backendRes = backendClientEP -> post("/", request);
        match backendRes {
            http:Response res => {
            _ = client -> respond(res);}
        http:HttpConnectorError err1 => {
            response = new;
            response.statusCode = 500;
            response.setStringPayload(err1.message);
            _ = client -> respond(response);}
        }
    }
}

@http:ServiceConfig {
    basePath:"/echo"
}
service<http:Service> echo bind backendEP{
    @http:ResourceConfig {
        methods:["POST", "PUT", "GET"],
        path:"/"
    }
    echoResource (endpoint ep, http:Request req) {
        http:Response outResponse = new;
        runtime:sleepCurrentWorker(30000);
        outResponse.setStringPayload("echo Resource is invoked");
        _ = ep -> respond(outResponse);
    }
}

@http:ServiceConfig {
    basePath:"/mock"
}
service<http:Service> mock  bind backendEP{
    @http:ResourceConfig {
        methods:["POST", "PUT", "GET"],
        path:"/"
    }
    mockResource (endpoint ep, http:Request req) {
        http:Response outResponse = new;
        outResponse.setStringPayload("Mock Resource is Invoked.");
        _ = ep -> respond(outResponse);
    }
}
