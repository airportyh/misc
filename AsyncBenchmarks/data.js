var sys = require('sys'),
    http = require('http')
  

    
http.createServer(function(req, resp){
    resp.writeHead(200, {'Content-Type': 'text/plain'})
    //setTimeout(function(){
        
        for (var i = 0; i < 5000; i++){
            resp.write(i + ':' + new Date().getTime() + '\n', 'utf8')
        }
        resp.end()
    //}, 500)
}).listen(8081)

sys.puts('Server listening on 8081')

