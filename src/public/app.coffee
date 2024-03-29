LazyLoad.load [
  'https://s3.amazonaws.com/odekirk/socket.io.js',
  'https://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js',
  'https://s3.amazonaws.com/odekirk/imagesloaded.jquery.min.js'
], ->
    jQuery ($) ->
      close = $('a.close')
      art = $('#art')
      canvas = $('#gallery')
      big = $('#overlay')
      container = $('.container')
      current_width = $(window).width()

      canvas.delegate 'a', 'click', () ->
        container.addClass 'large'
        src = $(this).data('lrg')
        big.html("<img class='well' style='display:none' src=#{src} height='390' />")
          .imagesLoaded (img) ->
            img.css('margin-left',(960-img.width())/2).fadeIn()
            big.height 440
        return false

      close.click () ->
        container.removeClass 'large'
        big.height 0
        return false

      container.addClass 'loaded'
      container.addClass 'landscape' if window.orientation % 180

      $(window).bind 'resize orientationchange', () -> 
        when 'resize'
          if $(this).width() < 960 and current_width > 960 
            socket.emit 'width', 'mobile'
            current_width = $(this).width()
          if $(this).width() >= 960 and current_width < 960 
            socket.emit 'width', 'desktop'
            current_width = $(this).width()
        when 'orientationchange'
          socket.emit 'width', "mobile#{window.orientation}"
          container.removeClass('landscape')
          container.addClass 'landscape' if window.orientation % 180

    #socket.io
    window.orientation = 'none'
    socket = io.connect '/'
    socket.emit 'width', if $(window).width() < 960 then "mobile-#{window.orientation}" else "desktop"
    socket.on 'clear', -> $('#gallery, #post, #code').empty()
    socket.on 'painting', (data) -> $('#gallery').append(data).imagesLoaded (images)-> $(images).parent().fadeIn 900
    socket.on 'post', (data) -> $('#post').append(data).children().fadeIn 900
    socket.on 'repo', (data) -> $('#code').append("<div id='#{repo}' class='span-one-third'><h6>#{repo}</h6></div>") for repo of data
    socket.on 'commits', (data) -> $("##{data.repo}").append(data.html).children().fadeIn 900

