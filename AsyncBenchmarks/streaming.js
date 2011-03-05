var sys = require('sys'),
    http = require('http')

var host = 'feeds.delicious.com'
var uri = '/v2/json/airportyh?count=100'

function request(host, port, verb, uri, data, callback, context){
    var client = http.createClient(port, host)
    var request = client.request(verb, uri, {'host': host})
    if (verb != 'GET')
  	  request.write(JSON.stringify(data), "utf8");
  	request.addListener('response', function(response) {
  	    var responseBody = ""
  		response.setBodyEncoding("utf8")
  		response.addListener("data", function(chunk) {
  		    responseBody += chunk
  		})
  		response.addListener("end", function() {
  			if (callback)
  			  callback.call(context, responseBody, response.statusCode)
  		})
  	})
  	request.end()
}
  

    
http.createServer(function(req, resp){
    resp.writeHead(200, {'Content-Type': 'text/html'})
    resp.write('<!DOCTYPE html>', 'utf8')
    resp.write('<html><head><title>Predictions</title></head><body><h1>Predictions</h1><ul>')
    
    function writeLine(line){
        var parts = line.split(':')
        resp.write('<li><a href="' + parts[0] + '">' + parts[1] + '</a></li>')
    }
    
    var port = 8081
    var host = 'localhost'
    var verb = 'GET'
    var uri = '/'
    var data = null
    var client = http.createClient(port, host)
    var request = client.request(verb, uri, {'host': host})
  	request.addListener('response', function(response) {
  		response.setBodyEncoding("utf8")
  		response.addListener("data", function(line) {
  		    writeLine(line)
  		})
  		response.addListener("end", function() {
  			resp.end('</ul></body></html>')
  		})
  	})
  	request.end()
}).listen(8080)

sys.puts('Server listening on 8080')

