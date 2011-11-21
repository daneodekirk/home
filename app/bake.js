(function() {
  var NodeCache, ONEWEEK, STATIC, app, ck, day, express, feedcache, fs, githubify, gpluscontent, gplusimage, io, picasify, port, request, socket, url;
  ck = require('coffeekup');
  express = require('express');
  app = express.createServer();
  fs = require('fs');
  socket = require('socket.io');
  io = socket.listen(app);
  url = require('url');
  request = require('request');
  NodeCache = require('node-cache');
  feedcache = new NodeCache();
  ONEWEEK = 2629743000;
  STATIC = "" + (process.cwd()) + "/app/public";
  app.configure(function() {
    app.set('views', './app/views');
    app.set('view options', {
      layout: false
    });
    app.set('view engine', 'coffee');
    app.register('.coffee', require('coffeekup').adapters.express);
    app.use(express.static("" + STATIC, {
      maxAge: ONEWEEK
    }, {
      test: 'foobar'
    }));
    app.use(express.errorHandler());
    app.use(express.compiler({
      src: "" + STATIC,
      enable: ['less']
    }));
    return app.use(function(req, res, next) {
      res.header('Vary', 'Accept-Encoding');
      return next();
    });
  });
  app.get('/', function(req, res) {
    return feedcache.get('feeds', function(err, cache) {
      var feeds;
      if (cache.feeds === void 0) {
        feeds = {};
        url = 'https://picasaweb.google.com/data/feed/api/user/114871092135242691110/albumid/5668708009304041265?alt=json';
        return request(url, function(err, data, body) {
          var entry, json;
          json = JSON.parse(body);
          feeds.canvas = (function() {
            var _i, _len, _ref, _results;
            _ref = json.feed.entry;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              entry = _ref[_i];
              _results.push([
                {
                  src: picasify(entry.content.src, 's40-c'),
                  med: picasify(entry.content.src, 's150'),
                  lrg: picasify(entry.content.src, 'h390')
                }
              ][0]);
            }
            return _results;
          })();
          url = 'https://github.com/daneodekirk.json';
          return request(url, function(err, data, body) {
            var index, items, repo, _len;
            items = {};
            json = JSON.parse(body);
            for (index = 0, _len = json.length; index < _len; index++) {
              repo = json[index];
              if (index > 6) {
                continue;
              }
              if (!items[repo.repository.name]) {
                items[repo.repository.name] = [];
              }
              items[repo.repository.name].push({
                date: day(repo.created_at),
                msg: githubify(repo),
                type: repo.type,
                url: repo.url
              });
            }
            feeds.code = items;
            url = "https://www.googleapis.com/plus/v1/people/114871092135242691110/activities/public?key=" + process.env.GPLUS;
            return request(url, function(err, data, body) {
              var item;
              json = JSON.parse(body);
              feeds.me = (function() {
                var _i, _len2, _ref, _results;
                _ref = json.items;
                _results = [];
                for (_i = 0, _len2 = _ref.length; _i < _len2; _i++) {
                  item = _ref[_i];
                  _results.push([
                    {
                      url: item.url,
                      src: gplusimage(item.object.attachments),
                      content: gpluscontent(item)
                    }
                  ][0]);
                }
                return _results;
              })();
              feedcache.set("feeds", feeds, 3600);
              return res.render('index', {
                canvas: feeds.canvas,
                code: feeds.code,
                me: feeds.me
              });
            });
          });
        });
      } else {
        return res.render('index', {
          canvas: cache.feeds.canvas,
          code: cache.feeds.code,
          me: cache.feeds.me
        });
      }
    });
  });
  picasify = function(url, size) {
    var new_url, parts;
    parts = url.split('/');
    parts[parts.length - 1] = "" + size + "/";
    new_url = parts.join('/');
    if (size === 's40-c') {
      new_url += '?sz=40';
    }
    return new_url;
  };
  githubify = function(repo) {
    if (repo.type === 'PushEvent') {
      return repo.payload.shas[0][2];
    }
    if (repo.type === 'ForkEvent') {
      return "" + repo.repository.name + " forked!";
    }
    if (repo.type === 'CreateEvent') {
      return "" + repo.repository.name + " " + repo.payload.ref_type + " created!";
    }
    return repo.repository.name;
  };
  day = function(time) {
    var times;
    times = time.split(' ');
    return "" + times[0] + " at " + times[1];
  };
  gplusimage = function(attachments, size) {
    if (attachments[0]) {
      return "" + (attachments[0].fullImage.url.replace('s0-d/', '')) + "?sz=200";
    }
  };
  gpluscontent = function(item) {
    if (item.verb === 'checkin') {
      return "Checked in at " + item.placeName;
    }
    return "" + (item.title.split(' ').slice(0, 7).join(' ')) + "...";
  };
  io.sockets.on('connection', function(socket) {
    socket.emit('clear');
    url = 'https://picasaweb.google.com/data/feed/api/user/114871092135242691110/albumid/5668708009304041265?alt=json';
    request(url, function(err, data, body) {
      var entry, json, _i, _len, _ref, _results;
      json = JSON.parse(body);
      _ref = json.feed.entry;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        entry = _ref[_i];
        _results.push(socket.emit('painting', "<a data-lrg='" + (picasify(entry.content.src, 'h390')) + "'>\n  <img class='thumbnail' style='display:none' src=\"" + (picasify(entry.content.src, 's120-c')) + "\" data-med=\"" + (picasify(entry.content.src, 's150')) + "\"\n</a>"));
      }
      return _results;
    });
    url = "https://www.googleapis.com/plus/v1/people/114871092135242691110/activities/public?key=" + process.env.GPLUS;
    return request(url, function(err, data, body) {
      var item, json, _i, _len, _ref, _results;
      json = JSON.parse(body);
      _ref = json.items;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        _results.push(socket.emit('post', "<a style=\"display:none\" data-lrg='" + item.url + "'>\n  <img class='thumbnail' src=\"" + (gplusimage(item.object.attachments)) + "\" />\n</a>"));
      }
      return _results;
    });
  });
  port = process.env.PORT || 1123;
  app.listen(port);
  console.log("Server running on port " + (app.address().port));
}).call(this);
