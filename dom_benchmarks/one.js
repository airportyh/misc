$(function(){
    var start = new Date().getTime()
    
    var markup = ''
    for (var i = 0; i < 10000; i++){
        markup += '<li>' + i + '</li>'
    }
    $('#list').html(markup)
    
    var middle = new Date().getTime()
    
    
    
    $('#list li').click(function(){
        alert($(this).text() + ' was clicked!')
    })
    
    var end = new Date().getTime()
    
    $('h1').html('Time elaspesd: ' + (end - start) + ', ' + (end - middle))
})