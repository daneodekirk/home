LazyLoad.load [
  'https://s3.amazonaws.com/odekirk/socket.io.js',
  'https://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js',
  'https://s3.amazonaws.com/odekirk/imagesloaded.jquery.min.js',
  'https://s3.amazonaws.com/odekirk/jquery.masonry.min.js'
], ->
    jQuery ($) ->
      close = $('a.close')
      art = $('#art')
      canvas = $('.media-grid')
      big = $('#overlay')
      container = $('.container')
      expand = $('#expand')
      minify = $('#minify')

      expand.click (e) ->
        expand.hide()
        art.toggleClass('span-one-third span16').width('98%')
        container.addClass 'active'
        canvas.fadeOut () ->
          canvas.find('img').each((i,el) -> $(this).attr 'src', el.src.replace 's40-c', 's150')
            .imagesLoaded (imgs) -> #canvas.masonry 'reload'
          canvas.fadeIn()
          minify.show()

        minify.one 'click', (e) ->
          minify.hide()
          art.removeAttr('style').toggleClass('span-one-third span16')
            .find('img').each((i,el) -> $(this).attr 'src', el.src.replace 's150', 's40-c')
              .imagesLoaded () -> canvas.masonry 'reload'
          container.removeClass 'active'
          expand.removeAttr('style')
          return false
        return false

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

      canvas.imagesLoaded () -> this.masonry isAnimated:true
      container.addClass 'loaded'


    #socket.io
    socket = io.connect 'http://localhost'
    socket.on 'clear', -> $('#gallery, #post, #code').empty()
    socket.on 'canvas height', (data) -> $('#art').css 'min-height', data
    socket.on 'painting', (data) -> $('#gallery').append(data).imagesLoaded (images)-> $(images).parent().fadeIn 900
    socket.on 'post', (data) -> $('#post').append(data).children().fadeIn 900
    socket.on 'repo', (data) -> $('#code').append("<div id='#{repo}' class='span-one-third'><h6>#{repo}</h6></div>") for repo of data
    socket.on 'commits', (data) -> $("##{data.repo}").append(data.html).children().fadeIn 900

