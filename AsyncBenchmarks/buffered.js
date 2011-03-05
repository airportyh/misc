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
    request('localhost', 8081, 'GET', '/', null, function(data){
        data.split('\n').forEach(function(row){
            if (!row) return
            var parts = row.split(':')
            resp.write('<li><a href="' + parts[0] + '">' + parts[1] + '</a></li>')
        })
        resp.write('</ul></body></html>')
        resp.end()
    })
}).listen(8080)

sys.puts('Server listening on 8080')

