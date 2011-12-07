ck = require 'coffeekup'
express = require 'express'
app = express.createServer()
fs = require 'fs'

socket = require 'socket.io'
io = socket.listen app
io.configure () ->
  io.set 'log level', 1
  io.set 'transports', ['xhr-polling']
  io.set 'polling duration', 10

url = require 'url'
request = require 'request'

ONEWEEK = 2629743000
STATIC = "#{process.cwd()}/app/public"

app.configure ()->
  app.set 'views', './app/views'
  app.set 'view options', { layout : false }
  app.set 'view engine', 'coffee'
  app.register '.coffee', require('coffeekup').adapters.express

  app.use express.favicon "#{STATIC}/favicon.ico", { maxAge: 0 }
  app.use express.static "#{STATIC}", { maxAge: ONEWEEK }, { test:'foobar'}
  app.use express.errorHandler()
  app.use express.compiler { src:"#{STATIC}", enable:['less'] }

  app.use (req,res,next) ->
    host = req.headers.host
    return res.redirect "http://#{host.replace 'www.', ''}#{req.url}" if !!~ host.indexOf 'www.'
    res.header 'Vary', 'Accept-Encoding'
    next()

app.get '/', (req, res) -> res.render 'index'
app.get '*', (req, res) -> res.render '404', status:404, url:req.url

githubify = (repo) ->
  return repo.payload.shas[0][2] if repo.type is 'PushEvent'
  return "#{repo.repository.name} forked!" if repo.type is 'ForkEvent'
  return "#{repo.repository.name} #{repo.payload.ref_type} created!" if repo.type is 'CreateEvent'
  repo.repository.name

day = (time) ->
  times = time.split(' ')
  "#{times[0]} at #{times[1]}"

gplusimage = (attachments, size) ->
  return "#{attachments[0].fullImage.url.replace('s0-d/', '')}?sz=#{size}" if attachments[0]

gpluscontent = (item) ->
  return "Checked in at #{item.placeName}" if item.verb is 'checkin'
  "#{item.title.split(' ').slice(0,23).join ' '}..."


#socket.io

io.sockets.on 'connection', (socket) ->
  socket.on 'width', (device) ->

    #size = if 'mobile' in device then large:200, small:70 else large:390, small:200

    if !!~ device.indexOf 'mobile' 
      size = if !!~ device.indexOf '90' then large:200, small:120 else large:390, small:70
    else 
      size = large:390, small:200
      
    socket.emit 'clear'

    url = "https://picasaweb.google.com/data/feed/api/user/114871092135242691110/albumid/5668708009304041265?thumbsize=#{size.large}&alt=json"
    request url, (err, data, body) ->
      json = JSON.parse body
      socket.emit 'painting', """
        <a style='display:none' data-lrg="#{entry.media$group.media$thumbnail[0].url.replace("s#{size.large}","h#{size.large}")}">
          <img class='thumbnail' style='' src="#{entry.content.src}?sz=#{size.small}" />
          <span><p>#{entry.summary.$t}</p></span>
        </a>
      """ for entry in json.feed.entry

    url = "https://www.googleapis.com/plus/v1/people/114871092135242691110/activities/public?key=#{process.env.GPLUS}"
    request url, (err, data, body) ->
      json = JSON.parse body
      socket.emit 'post', """
        <a href="#{item.url}" style="display:none">
          <img class='thumbnail' src="#{gplusimage(item.object.attachments, size.small)}" />
          <span><p>#{gpluscontent(item)}</p></span>
        </a>
      """ for item in json.items

    # this is no fun :(
    url = 'https://github.com/daneodekirk.json'
    request url, (err, data, body) ->
      repos = {}
      json = JSON.parse body
      json.map (a,b) -> repos[a.repository.name] = a.repository.owner if a.type isnt "ForkEvent"

      socket.emit('repo', repos)
       
      for repo,owner of repos
        url = "https://api.github.com/repos/#{owner}/#{repo}/commits"
        request url, (err, data, body) ->
          repo  = @uri.pathname.split('/')[-2..-2]
          owner = @uri.pathname.split('/')[-3..-3]
          json = JSON.parse body
          (socket.emit('commits', repo:repo, html:"""
            <span style="display:none">
              <a href='http://github.com/#{owner}/#{repo}/compare/#{item.parents[0].sha}...#{item.sha}'> #{item.commit.message} </a>
              <span class='help-block'> #{item.commit.committer.date} </span>
            </span>
          """) if index < 6) for item,index in json

port = process.env.PORT or 1123
app.listen port
console.log "Server running on port #{app.address().port}"
