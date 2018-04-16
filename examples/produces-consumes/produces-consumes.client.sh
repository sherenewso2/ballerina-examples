# Run the following curl command to invoke the service.
$ curl -v http://localhost:9092/infoService -H "Accept:application/xml" -H "Content-Type:application/json" -d '{"name":"Ballerina"}'
# The server response. 
<name>Ballerina</name>
