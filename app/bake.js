(function() {
  var ONEWEEK, STATIC, app, express, port;
  express = require('express');
  app = express.createServer();
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
  port = process.env.PORT || 1123;
  app.listen(port);
  console.log("Server running on port " + (app.address().port));
}).call(this);
