express = require 'express'
app = express.createServer()
fs = require 'fs'

url = require 'url'
request = require 'request'

NodeCache = require 'node-cache'
feedcache = new NodeCache()

ONEWEEK = 2629743000
STATIC = "#{process.cwd()}/app/public"

app.configure ()->
  app.set 'views', './app/views'
  app.set 'view options', { layout : false }
  app.set 'view engine', 'coffee'
  app.register '.coffee', require('coffeekup').adapters.express

  app.use express.static "#{STATIC}", { maxAge: ONEWEEK }, { test:'foobar'}
  app.use express.errorHandler()
  app.use express.compiler { src:"#{STATIC}", enable:['less'] }

  app.use (req,res,next) ->
    res.header 'Vary', 'Accept-Encoding'
    next()

app.get '/', (req, res) ->
  feedcache.get 'feeds', (err, cache) ->
    if cache.feeds is undefined
      #console.log 'no cache '
      feeds = {}
      url = 'https://picasaweb.google.com/data/feed/api/user/114871092135242691110/albumid/5668708009304041265?alt=json'
      request url, (err, data, body) ->
        json = JSON.parse body
        feeds.canvas = ( [{
          src:picasify(entry.content.src, 's40-c'),
          med:picasify(entry.content.src, 's150'),
          lrg:picasify(entry.content.src, 'h390')
        }][0] for entry in json.feed.entry )

        url = 'https://github.com/daneodekirk.json'
        request url, (err, data, body) ->
          items = {}
          json = JSON.parse body
          for repo,index in json
            continue if index > 6
            items[repo.repository.name] = [] if not items[repo.repository.name]
            items[repo.repository.name].push
              date:day(repo.created_at),
              msg:githubify(repo),
              type:repo.type,
              url:repo.url
          feeds.code = items

          url = "https://www.googleapis.com/plus/v1/people/114871092135242691110/activities/public?key=#{process.env.GPLUS}"
          request url, (err, data, body) ->
            json = JSON.parse body
            feeds.me = ([ {
              url:item.url,
              src:gplusimage(item.object.attachments),
              content:gpluscontent(item)
            } ][0] for item in json.items)
            feedcache.set "feeds", feeds, 3600 #, () -> console.log 'successful save in cache'
            res.render 'index', canvas: feeds.canvas, code:feeds.code, me:feeds.me
    else
      #console.log 'found in cache'
      res.render 'index', canvas: cache.feeds.canvas, code:cache.feeds.code, me:cache.feeds.me

picasify = (url, size) ->
  parts = url.split '/'
  parts[parts.length - 1] = "#{size}/"
  new_url = parts.join('/')
  new_url += '?sz=40' if size is 's40-c'
  return new_url

githubify = (repo) ->
  return repo.payload.shas[0][2] if repo.type is 'PushEvent'
  return "#{repo.repository.name} forked!" if repo.type is 'ForkEvent'
  return "#{repo.repository.name} #{repo.payload.ref_type} created!" if repo.type is 'CreateEvent'
  repo.repository.name

day = (time) ->
  times = time.split(' ')
  "#{times[0]} at #{times[1]}"

gplusimage = (attachments, size) ->
  return "#{attachments[0].fullImage.url.replace('s0-d/', '')}?sz=40" if attachments[0]
  #sz = if size is 's40-c' then 'sz=40' else ''
  #return "#{attachments[0].fullImage.url.replace('s0-d', size)}#{sz}" if attachments[0]

gpluscontent = (item) ->
  return "Checked in at #{item.placeName}" if item.verb is 'checkin'
  #item.object.content
  "#{item.title.split(' ').slice(0,7).join ' '}..."

port = process.env.PORT or 1123
app.listen port
console.log "Server running on port #{app.address().port}"
