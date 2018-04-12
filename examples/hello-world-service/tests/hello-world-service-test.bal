import ballerina/test;
import ballerina/io;

boolean serviceStarted;

function startService(){
    serviceStarted = test:startServices("hello-world-service");
}

@test:Config {
    before:"startService",
    after:"stopService"
}
function testFunc() {
    // Invoking the main function
    endpoint http:Client httpEndpoint { targets:[{ url:"http://localhost:9090" }] };
    // Chck whether the server is started
    test:assertTrue(serviceStarted, msg = "Unable to start the service");

    string response1 = "Hello, World!";

    http:Request req = new;
    // Send a GET request to the specified endpoint
    var response = httpEndpoint -> get("/hello/sayHello", req);
    match response {
        http:Response resp => {
            var res = check resp.getStringPayload();
            test:assertEquals(res, response1);
        }
        http:HttpConnectorError err => test:assertFail(msg = "Failed to call the endpoint:");
    }
}

function stopService(){
    test:stopServices("hello-world-service");
}