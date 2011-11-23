doctype 5
html ->
  head ->
    meta charset: 'utf-8'
    meta name:'viewport', content:'width=device-width'
    title -> 'Cake'
    ie 'lt IE9', ->
      script src: 'http://html5shim.googlecode.com/svn/trunk/html5.js', type:'text/javascript'
    
    link rel: 'stylesheet', href: 'https://s3.amazonaws.com/odekirk/bootstrap.1.4.0.css'
    link rel: 'stylesheet', href: 'app.css'

  body ->
    div '.container', ->
      div '#overlay', ->
      a '.close', href:'#', -> 'x'
      section ->
        div '.name.page-header', ->
          h1 'dane odekirk'
      section '#main', ->
        div '.row', ->
          div '#art.span16', ->
            h3 '.large', -> "#{yield -> a href:'https://plus.google.com/u/0/photos/114871092135242691110/albums/5668708009304041265', -> 'canvas'}"
            div '#gallery.media-grid', ->

          div '#me.span16', ->
            h3 '.large', -> a href:'https://plus.google.com/u/0/114871092135242691110/posts', -> "me"
            div '#post.media-grid', ->

          div '.span16', ->
            h3 '.large', -> a href:'http://github.com/daneodekirk', -> 'code'
            div '#code.row', ->

      footer ".footer", ->
        div '.container', ->
          span '#help-out', -> "built and designed by Dane Odekirk. help out at #{ yield -> a href:'https://github.com/daneodekirk', -> 'github' }"
          span '.pull-right', -> 'put something interesting here'

    script src:'https://s3.amazonaws.com/odekirk/lazyload.min.js'
    script src:'app.js'
