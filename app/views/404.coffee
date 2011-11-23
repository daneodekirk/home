doctype 5
html ->
  head ->
    meta charset: 'utf-8'
    meta name:'viewport', content:'width=device-width'
    title -> 'Dane Odekirk'
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
      section '#main', style:'min-height:105px;', ->
        div '.row', ->
          div '#art.span16', ->
            h3 '.large', -> "#{yield -> a href:'/', -> '404'}"

      footer ".footer", ->
        div '.container', ->
          span '#help-out', -> "built and designed by Dane Odekirk. help out at #{ yield -> a href:'https://github.com/daneodekirk', -> 'github' }"
          span '.pull-right', -> 'put something interesting here'
