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
            h3 -> text "art #{ yield -> a '.close', href:'#', -> 'x' }"
            div '.media-grid', ->
            
          div '#code.span-one-third', ->
            h3 -> "code"
            #(p class:'code') for number in [1..5]

          div '#me.span-one-third', ->
            h3 -> "me"


      footer ".footer", ->
        div '.container', ->
          span "built and designed by Dane Odekirk. help out at #{ yield -> a href:'https://github.com/daneodekirk', -> 'GitHub' }"
          span '.pull-right', -> 'put something interesting here'

    script src:'lazyload.js'
    coffeescript ->
      LazyLoad.load [
          'https://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js',
          'twipsy.js',
          'http://twitter.github.com/bootstrap/1.4.0/bootstrap-popover.js'
        ], ->
          jQuery ($) ->
            name = ''
            close = $('a.close')
            art = $('.media-grid')
            me = $('#me')

            $.getJSON '/canvas', (data) -> art.append "<a href='#'><img class='thumbnail' src='#{src}'/></a>" for index,src of data

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
              console.log el,index for el,index of data
              me.append "<a class='show' href='#{item.url}'>
                            <img src='#{item.src}' />
                          </a>" for el,item of data

              #$('#me a').popover placement:'below',html:true,animate:false


            $('#art').mouseenter (e) ->
              return if $(this).hasClass 'span16'
              $(this).toggleClass 'span-one-third span16'
              $(this).find('img').each (i,el) -> $(this).attr 'src', el.src.replace 's40-c', 's150'
              
              #$('#main').mouseleave (e) ->
              #  $('#art').toggleClass 'span-one-third span16'
              #  $(this).find('img').each (i,el) -> $(this).attr 'src', el.src.replace 's150', 's40-c'
              #  $(this).unbind 'mouseleave'
              #  close.unbind 'click'

              close.one 'click', (e) ->
                $('#art').toggleClass('span-one-third span16')
                  .find('img').each (i,el) -> $(this).attr 'src', el.src.replace 's150', 's40-c'
              #    $('#main').unbind 'mouseleave'

            #$('#art').one 'mouseenter', () ->
            #  LazyLoad.load 'https://raw.github.com/desandro/masonry/master/jquery.masonry.min.js', ->
            #    $('#art').masonry itemSelector:'.canvas', isAnimated:true, columnWidth:1, gutterWidth:0
