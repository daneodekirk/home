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
        div '.page-header', ->
          h1 'dane odekirk'
      section '#main', ->
        div '.row', ->
          div '#art.span-one-third', ->
            h3 -> "#{yield -> a href:'https://plus.google.com/u/0/photos/114871092135242691110/albums/5668708009304041265', -> 'canvas'}
                    #{yield -> a '#expand.pull-right.help-block', href:'#', 'expanded view'}
                    #{yield -> a '#minify.pull-right.help-block',style:'display:none', href:'#', 'thumbnail view'}"
            div '.media-grid', ->
              ( a 'data-lrg':painting.lrg, ->
                img '.thumbnail', src:painting.src, 'data-med':painting.med ) for index,painting of @canvas
            
          div '#code.span-one-third', ->
            h3 -> a href:'http://github.com/daneodekirk', -> 'code'
            for repo, index of @code
              h6 repo
              (span ->
                a href:item.url, -> item.msg
                span '.help-block', -> item.date ) for item in index

          div '#me.span-one-third', ->
            h3 -> a href:'https://plus.google.com/u/0/114871092135242691110/posts', -> "me"
            ( a href:my.url, ->
              img src:my.src, width:40, height:40
              span class:'help-block me', -> my.content ) for index,my of @me

      footer ".footer", ->
        div '.container', ->
          span '#help-out', -> "built and designed by Dane Odekirk. help out at #{ yield -> a href:'https://github.com/daneodekirk', -> 'github' }"
          span '.pull-right', -> 'put something interesting here'

    script src:'https://s3.amazonaws.com/odekirk/lazyload.min.js'
    script src:'app.js'
