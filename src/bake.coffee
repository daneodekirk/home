express = require 'express'
app = express.createServer()

ONEWEEK = 2629743000
STATIC = "#{process.cwd()}/app/public"

app.configure ()->
  app.set 'views', './app/views'
  app.set 'view options', { layout : false }
  app.set 'view engine', 'coffee'
  app.register '.coffee', require('coffeekup').adapters.express

  app.use express.static "#{STATIC}", { maxAge: ONEWEEK }
  app.use express.errorHandler()
  app.use express.compiler { src:"#{STATIC}", enable:['less'] }

app.get '/', (request, response) ->
  response.render 'index'

port = process.env.PORT or 1123
app.listen port
console.log "Server running on port #{app.address().port}"
