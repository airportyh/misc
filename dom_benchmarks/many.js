$(function(){
    var start = new Date().getTime()
    for (var i = 0; i < 10000; i++){
        li = $('<li>' + i + '</li>').click(function(){
            alert($(this).text() + ' was clicked!')
        })
        $('#list').append(li)
    }
    var end = new Date().getTime()
    
    $('h1').html('Time elaspesd: ' + (end - start))
})