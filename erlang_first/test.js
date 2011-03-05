var Bert = require('./bert').Bert,
    BertTuple = require('./bert').BertTuple,
    BertBinary = require('./bert').BertBinary
    
var puts = require('sys').puts

var term = [
    false,2, 
    new BertBinary([132,177,33,86,22,138,138,208,203,193,154,7,213,99,156,213].map(function(a){return String.fromCharCode(a)}).join('')),
    new BertTuple(
        [[
            new BertTuple([new BertBinary('name'), new BertBinary('Emma')]), 
            new BertTuple([new BertBinary('age'), 3])
        ]]
    ),
    []]

puts(Bert.pp_bytes(Bert.encode(term)))