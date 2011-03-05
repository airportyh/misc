// Will be a complete reformatter in javascript similar to the Yajl reformatter
var sys = require('sys');
var yajl = require('./src/yajl');

function usage() {
    sys.error( "Usage: %s <filename>\n"
               +"    -m Minimize json rather than beautify (default)\n"
               +"    -u allow invalid UTF8 inside strings during parsing\n");
    process.exit(1);
}

var conf = {
    beautify: 1,
    indentString: "  "
};

var cfg = {
    allowComments: 1,
    checkUTF8: 1
};

if( process.ARGV.length == 3 ) {
    if( process.ARGV[2] == "-m" )
        conf.beautify = 0;
    else if( process.ARGV[2] == "-u" )
        cfg.checkUTF8 = 0;
    else
        usage();
}
else if( process.ARGV.length != 2 ) {
    usage();
}

var handle = yajl.createHandle();
handle.addListener( "null", function() {
    sys.debug("null");
});

handle.addListener( "boolean", function(b) {
    sys.debug(b);
});

handle.addListener( "number", function(n) {
    sys.debug("Num: " + n);
});

handle.addListener( "string", function(s) {
    sys.debug("String: " + s);
});

handle.addListener( "mapKey", function(k) {
    sys.debug("Key: " + k );
});

handle.addListener( "startMap", function() {
    sys.debug("{");
});

handle.addListener( "endMap", function() {
    sys.debug("}");
});

handle.addListener( "startArray", function() {
    sys.debug("[");
});

handle.addListener( "endArray", function() {
    sys.debug("]");
});

handle.addListener( "error", function( errorString ) {
    sys.error("Error parsing json: " + errorString );
});

var done = false;

stdin = process.openStdin();
stdin.addListener( "data", function( data ) {
    handle.parse(data.toString());
});
stdin.addListener( "end", function() {
    handle.parseComplete();
});
