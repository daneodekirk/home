doctype 5
html ->
  head ->
    meta charset: 'utf-8'
    title -> 'Cake'
    ie 'lt IE9', ->
      script src: 'http://html5shim.googlecode.com/svn/trunk/html5.js', type:'text/javascript'
    
    link rel: 'stylesheet', href: 'https://s3.amazonaws.com/heroku-cdn/blueprint.min.css'
    link rel: 'stylesheet', href: 'app.css'

  body ->
    div '.container', ->
      section ->
        div '.page-header', ->
          h1 'header'
      section '#main', ->
        div '.row', ->
          div '#art.span-one-third', ->
            h3 -> "#{yield -> a href:'https://plus.google.com/u/0/photos/114871092135242691110/albums/5668708009304041265', -> 'art'} #{ yield -> a '.close', href:'#', -> 'x' }"
            div '.media-grid', ->
            
          div '#code.span-one-third', ->
            h3 -> a href:'http://github.com/daneodekirk', -> 'code'

          div '#me.span-one-third', ->
            h3 -> a href:'https://plus.google.com/u/0/114871092135242691110/posts', -> "me"


      footer ".footer", ->
        div '.container', ->
          span '#help-out', -> "built and designed by Dane Odekirk. help out at #{ yield -> a href:'https://github.com/daneodekirk', -> 'GitHub' }"
          span '.pull-right', -> 'put something interesting here'

    script src:'lazyload.js'
    coffeescript ->
      LazyLoad.load [
          'https://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js',
          'https://raw.github.com/desandro/imagesloaded/master/jquery.imagesloaded.js',
          'https://raw.github.com/desandro/masonry/master/jquery.masonry.min.js'
        ], ->
          jQuery ($) ->
            name = ''
            close = $('a.close')
            art = $('.media-grid')
            me = $('#me')

            $.getJSON '/canvas', (data) ->
              art.append "<a href='#'><img class='thumbnail' src='#{src}'/></a>" for index,src of data
              art.masonry isAnimated:true
              art.imagesLoaded (imgs) -> this.masonry 'reload'

            $.getJSON '/code', (data) ->
              count = 0
              el = $('#code')
              for repo,index of data
                return if count > 7
                el.append "<h6>#{repo}</h6>"
                for item,i in index
                  count++
                  continue if count > 7
                  el.append "<span class='#{item.type}'>
                                   <a href=#{item.url}>#{item.msg}</a>
                                   <span class='help-block'>#{item.date}</h5>
                                 </span>"

            $.getJSON '/me', (data) ->
              me.append "<a href='#{item.url}'>
                            <img style='float:left;clear:left;' src='#{item.src}' />
                            <span class='help-block me'>#{item.content}</span>
                          </a>" for el,item of data
            #close.bind 'click', (e) ->
            #  close.toggleClass('expanded')
            #  sizes = ['s40-c', 's150']
            #  sizes.reverse() if close.hasClass 'expanded'
            #  close.html (if close.hasClass 'expanded' then 'x' else 'expand')

            #  $('#art').toggleClass('span-one-third span16')

            #  $('.media-grid').fadeOut () ->
            #    $(this).find('img').each (i,el) -> $(this).attr 'src', el.src.replace 's40-c', 's150'
            #    $(this).fadeIn()
            #    $(window).trigger 'resize'

            $('#art').mouseenter (e) ->
              return if $(this).hasClass 'span16'
              $(this).toggleClass('span-one-third span16').width('98%')
              art.fadeOut () ->
                art.find('img').each((i,el) -> $(this).attr 'src', el.src.replace 's40-c', 's150')
                  .imagesLoaded (imgs) -> art.masonry 'reload'
                art.fadeIn()
             
             #$('#main').mouseleave (e) ->
             #  $('#art').toggleClass 'span-one-third span16'
             #  $(this).find('img').each (i,el) -> $(this).attr 'src', el.src.replace 's150', 's40-c'
             #  $(this).unbind 'mouseleave'
             #  close.unbind 'click'

              close.one 'click', (e) ->
                $('#art').removeAttr('style').toggleClass('span-one-third span16')
                  .find('img').each (i,el) -> $(this).attr 'src', el.src.replace 's150', 's40-c'
                $(window).trigger 'resize'
              #    $('#main').unbind 'mouseleave'
