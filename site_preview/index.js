function createIFrameFor(site){
    var iframe = $('<iframe src="' + site + '"></iframe>')
    $(document.body).append(iframe)
    return iframe
}
$(function(){
    var sites = 
    [
        [
        'http://google.com',
        'http://tobyho.com',
        'http://yahoo.com'
        ]
        ,
        [
        'http://jquery.com',
        'http://digg.com',
        'http://ebay.com'
        ]
    ]
    var scale = 0.3
    var width = 800 * scale
    var height = 600 * scale
    var padding = 20
    sites.forEach(function(row, i){
        row.forEach(function(site, j){
            var iframe = createIFrameFor(site)
            iframe.css({
                top: (10 + j * (height + padding)) + 'px',
                left: (10 + i * (width + padding)) + 'px'})
        })
        
    })
})