(function() {
  var Canvas, Image, ONEWEEK, STATIC, app, canvas, ctx, express, fs, githubify, gpluscontent, gplusimage, picasafy, port, request, url;
  express = require('express');
  app = express.createServer();
  fs = require('fs');
  url = require('url');
  request = require('request');
  Canvas = require('canvas');
  Image = Canvas.Image;
  canvas = new Canvas;
  ctx = canvas.getContext('2d');
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
    }));
    app.use(express.errorHandler());
    return app.use(express.compiler({
      src: "" + STATIC,
      enable: ['less']
    }));
  });
  app.get('/', function(request, response) {
    return response.render('index');
  });
  app.get('/canvas', function(req, res) {
    url = 'https://picasaweb.google.com/data/feed/api/user/114871092135242691110?alt=json&kind=photo';
    return request(url, function(err, data, body) {
      var entry, json, links;
      json = JSON.parse(body);
      links = (function() {
        var _i, _len, _ref, _results;
        _ref = json.feed.entry;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          entry = _ref[_i];
          _results.push(picasafy(entry.content.src));
        }
        return _results;
      })();
      return res.send(JSON.stringify(links));
    });
  });
  app.get('/code', function(req, res) {
    url = 'https://github.com/daneodekirk.json';
    return request(url, function(err, data, body) {
      var json, repo;
      json = JSON.parse(body);
      return res.send(JSON.stringify((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = json.length; _i < _len; _i++) {
          repo = json[_i];
          _results.push([
            {
              msg: githubify(repo),
              type: repo.type,
              url: repo.url
            }
          ][0]);
        }
        return _results;
      })()));
    });
  });
  app.get('/me', function(req, res) {
    url = "https://www.googleapis.com/plus/v1/people/114871092135242691110/activities/public?key=" + process.env.GPLUS;
    return request(url, function(err, data, body) {
      var item, json;
      json = JSON.parse(body);
      return res.send(JSON.stringify((function() {
        var _i, _len, _ref, _results;
        _ref = json.items;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
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
      })()));
    });
  });
  picasafy = function(url) {
    var new_url;
    new_url = url.split('/');
    new_url[new_url.length - 1] = 's40-c/';
    return new_url.join('/');
  };
  githubify = function(repo) {
    if (repo.type === 'PushEvent') {
      return repo.payload.shas[0][2];
    }
    if (repo.type === 'ForkEvent') {
      return "" + repo.repository.name + " forked!";
    }
    if (repo.type === 'CreateEvent') {
      return "" + repo.repository.name + " created!";
    }
    return repo.repository.name;
  };
  gplusimage = function(attachments) {
    if (attachments[0]) {
      return attachments[0].fullImage.url.replace('s0-d', 's40-c');
    }
  };
  gpluscontent = function(item) {
    if (item.verb === 'checkin') {
      return "Checked in at " + item.placeName;
    }
    return item.object.content;
  };
  port = process.env.PORT || 1123;
  app.listen(port);
  console.log("Server running on port " + (app.address().port));
}).call(this);
