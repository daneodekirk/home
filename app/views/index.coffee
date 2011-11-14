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
            h3 -> "art"
            div '.wrapper', ->
              (span class:'canvas') for number in [1..16]

          div '#code.span-one-third', ->
            h3 -> "code"
            (p class:'code') for number in [1..5]

          div '#me.span-one-third', ->
            h3 -> "me"
            (span class:'me') for number in [1..16]


      footer ".footer", ->
        div '.container', ->
          span "built and designed by Dane Odekirk. help out at #{ yield -> a href:'https://github.com/daneodekirk', -> 'GitHub' }"
          span '.pull-right', -> 'put something interesting here'

    script src:'http://cdn.wonko.com/lazyload/1.0.4/lazyload-min.js'
    coffeescript ->
      LazyLoad.load [
          'https://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js',
          'http://twitter.github.com/bootstrap/1.4.0/bootstrap-twipsy.js',
          'http://twitter.github.com/bootstrap/1.4.0/bootstrap-popover.js'
        ], ->
          jQuery ($) ->
            name = ''

            $.getJSON '/canvas', (data) -> ( $(el).prepend "<img src='#{data[index]}'/>" if data[index] ) for el,index in $('.canvas')

            $.getJSON '/code', (data) -> ( $(el).prepend "<span class='#{data[index].type}'>
                                                            <h5>#{data[index].repo}</h5>
                                                            <a href=#{data[index].url}>#{data[index].msg}</a>
                                                            <span class='help-block'>#{data[index].date}</h5>
                                                          </span>" ) for el,index in $('.code')

            $.getJSON '/me', (data) ->
              ( $(el).prepend "<a href='#{data[index].url}' data-content='#{data[index].content}'>
                                <img src='#{data[index].src}' />
                              </a>" if data[index]) for el,index in $('.me')

              $('#me a').popover placement:'below',html:true,animate:false

            #$('#art').mouseenter (e) ->
            #  return if $(this).hasClass 'span16'
            #  $(this).toggleClass 'span-one-third span16'
            #  $(this).find('img').each (i,el) -> $(this).attr 'src', el.src.replace 's80', 's150'
            #  
            #  $('#main').mouseleave (e) ->
            #    $('#art').toggleClass 'span-one-third span16'
            #    $(this).find('img').each (i,el) -> $(this).attr 'src', el.src.replace 's150', 's80'
            #    $(this).unbind 'mouseleave'



            #$('#art').one 'mouseenter', () ->
            #  LazyLoad.load 'https://raw.github.com/desandro/masonry/master/jquery.masonry.min.js', ->
            #    $('#art').masonry itemSelector:'.canvas', isAnimated:true, columnWidth:1, gutterWidth:0
