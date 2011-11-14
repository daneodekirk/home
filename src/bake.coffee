express = require 'express'
app = express.createServer()
fs = require 'fs'

url = require 'url'
request = require 'request'

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

app.get '/canvas', (req, res) ->
  url = 'https://picasaweb.google.com/data/feed/api/user/114871092135242691110/albumid/5668708009304041265?alt=json'
  request url, (err, data, body) ->
    json = JSON.parse body
    #links =  ( picasafy entry.media$group.media$content[0] for entry in json.feed.entry )
    links =  ( picasafy entry.content.src for entry in json.feed.entry )
    res.send JSON.stringify links

app.get '/code', (req, res) ->
  lastrepo = ''
  url = 'https://github.com/daneodekirk.json'
  request url, (err, data, body) ->
    json = JSON.parse body
    items = ( [ {
      repo: repo.repository.name,
      date:repo.repository.pushed_at,
      msg:githubify(repo),
      type:repo.type,
      url:repo.url
    } ][0] for repo,index in json )
    res.send JSON.stringify items
     
app.get '/me', (req, res) ->
  url = "https://www.googleapis.com/plus/v1/people/114871092135242691110/activities/public?key=#{process.env.GPLUS}"
  request url, (err, data, body) ->
    json = JSON.parse body
    res.send JSON.stringify ( [ {
      url:item.url,
      src:gplusimage(item.object.attachments),
      content:gpluscontent(item)
    } ][0] for item in json.items)

picasafy = (url) ->
  new_url = url.split '/'
  new_url[new_url.length - 1] = 's80/'
  new_url.join('/')

githubify = (repo) ->
  return repo.payload.shas[0][2] if repo.type is 'PushEvent'
  return "#{repo.repository.name} forked!" if repo.type is 'ForkEvent'
  return "#{repo.repository.name} created!" if repo.type is 'CreateEvent'
  repo.repository.name

gplusimage = (attachments) ->
  return attachments[0].fullImage.url.replace 's0-d', 's80' if attachments[0]

gpluscontent = (item) ->
  return "Checked in at #{item.placeName}" if item.verb is 'checkin'
  item.object.content

port = process.env.PORT or 1123
app.listen port
console.log "Server running on port #{app.address().port}"
