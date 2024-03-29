(function() {
  var ONEWEEK, STATIC, app, ck, day, express, fs, githubify, gpluscontent, gplusimage, io, port, request, socket, url;
  ck = require('coffeekup');
  express = require('express');
  app = express.createServer();
  fs = require('fs');
  socket = require('socket.io');
  io = socket.listen(app);
  io.configure(function() {
    io.set('log level', 1);
    io.set('transports', ['xhr-polling']);
    return io.set('polling duration', 10);
  });
  url = require('url');
  request = require('request');
  ONEWEEK = 2629743000;
  STATIC = "" + (process.cwd()) + "/app/public";
  app.configure(function() {
    app.set('views', './app/views');
    app.set('view options', {
      layout: false
    });
    app.set('view engine', 'coffee');
    app.register('.coffee', require('coffeekup').adapters.express);
    app.use(express.favicon("" + STATIC + "/favicon.ico", {
      maxAge: 0
    }));
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
      var host;
      host = req.headers.host;
      if (!!~host.indexOf('www.')) {
        return res.redirect("http://" + (host.replace('www.', '')) + req.url);
      }
      res.header('Vary', 'Accept-Encoding');
      return next();
    });
  });
  app.get('/', function(req, res) {
    return res.render('index');
  });
  app.get('*', function(req, res) {
    return res.render('404', {
      status: 404,
      url: req.url
    });
  });
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
    var image;
    image = attachments[0].objectType === 'photo' ? attachments[0] : attachments[1];
    if (attachments[0]) {
      return "" + (image.fullImage.url.replace('s0-d/', '')) + "?sz=" + size;
    }
  };
  gpluscontent = function(item) {
    if (item.verb === 'checkin') {
      return "Checked in at " + item.placeName;
    }
    return "" + (item.title.split(' ').slice(0, 23).join(' ')) + "...";
  };
  io.sockets.on('connection', function(socket) {
    return socket.on('width', function(device) {
      var size;
      if (!!~device.indexOf('mobile')) {
        size = !!~device.indexOf('90') ? {
          large: 200,
          small: 120
        } : {
          large: 390,
          small: 70
        };
      } else {
        size = {
          large: 390,
          small: 200
        };
      }
      socket.emit('clear');
      url = "https://picasaweb.google.com/data/feed/api/user/114871092135242691110/albumid/5668708009304041265?thumbsize=" + size.large + "&alt=json";
      request(url, function(err, data, body) {
        var entry, json, _i, _len, _ref, _results;
        json = JSON.parse(body);
        _ref = json.feed.entry;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          entry = _ref[_i];
          _results.push(socket.emit('painting', "<a style='display:none' data-lrg=\"" + (entry.media$group.media$thumbnail[0].url.replace("s" + size.large, "h" + size.large)) + "\">\n  <img class='thumbnail' style='' src=\"" + entry.content.src + "?sz=" + size.small + "\" />\n  <span><p>" + entry.summary.$t + "</p></span>\n</a>"));
        }
        return _results;
      });
      url = "https://www.googleapis.com/plus/v1/people/114871092135242691110/activities/public?key=" + process.env.GPLUS;
      request(url, function(err, data, body) {
        var item, json, _i, _len, _ref, _results;
        json = JSON.parse(body);
        _ref = json.items;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          item = _ref[_i];
          _results.push(socket.emit('post', "<a href=\"" + item.url + "\" style=\"display:none\">\n  <img class='thumbnail' src=\"" + (gplusimage(item.object.attachments, size.small)) + "\" />\n  <span><p>" + (gpluscontent(item)) + "</p></span>\n</a>"));
        }
        return _results;
      });
      url = 'https://github.com/daneodekirk.json';
      return request(url, function(err, data, body) {
        var json, owner, repo, repos, _results;
        repos = {};
        json = JSON.parse(body);
        json.map(function(a, b) {
          if (a.type !== "ForkEvent") {
            return repos[a.repository.name] = a.repository.owner;
          }
        });
        socket.emit('repo', repos);
        _results = [];
        for (repo in repos) {
          owner = repos[repo];
          url = "https://api.github.com/repos/" + owner + "/" + repo + "/commits";
          _results.push(request(url, function(err, data, body) {
            var index, item, _len, _results2;
            repo = this.uri.pathname.split('/').slice(-2, -1);
            owner = this.uri.pathname.split('/').slice(-3, -2);
            json = JSON.parse(body);
            _results2 = [];
            for (index = 0, _len = json.length; index < _len; index++) {
              item = json[index];
              _results2.push((index < 6 ? socket.emit('commits', {
                repo: repo,
                html: "<span style=\"display:none\">\n  <a href='http://github.com/" + owner + "/" + repo + "/compare/" + item.parents[0].sha + "..." + item.sha + "'> " + item.commit.message + " </a>\n  <span class='help-block'> " + item.commit.committer.date + " </span>\n</span>"
              }) : void 0));
            }
            return _results2;
          }));
        }
        return _results;
      });
    });
  });
  port = process.env.PORT || 1123;
  app.listen(port);
  console.log("Server running on port " + (app.address().port));
}).call(this);
