(function() {
  LazyLoad.load(['https://s3.amazonaws.com/odekirk/socket.io.js', 'https://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js', 'https://s3.amazonaws.com/odekirk/imagesloaded.jquery.min.js'], function() {
    var socket;
    jQuery(function($) {
      var art, big, canvas, close, container;
      close = $('a.close');
      art = $('#art');
      canvas = $('.media-grid');
      big = $('#overlay');
      container = $('.container');
      canvas.delegate('a', 'click', function() {
        var src;
        container.addClass('large');
        src = $(this).data('lrg');
        big.html("<img class='well' style='display:none' src=" + src + " height='390' />").imagesLoaded(function(img) {
          img.css('margin-left', (960 - img.width()) / 2).fadeIn();
          return big.height(440);
        });
        return false;
      });
      close.click(function() {
        container.removeClass('large');
        big.height(0);
        return false;
      });
      return container.addClass('loaded');
    });
    socket = io.connect('http://localhost');
    socket.on('clear', function() {
      return $('#gallery, #post, #code').empty();
    });
    socket.on('painting', function(data) {
      return $('#gallery').append(data).imagesLoaded(function(images) {
        return $(images).parent().fadeIn(900);
      });
    });
    socket.on('post', function(data) {
      return $('#post').append(data).children().fadeIn(900);
    });
    socket.on('repo', function(data) {
      var repo, _results;
      _results = [];
      for (repo in data) {
        _results.push($('#code').append("<div id='" + repo + "' class='span-one-third'><h6>" + repo + "</h6></div>"));
      }
      return _results;
    });
    return socket.on('commits', function(data) {
      return $("#" + data.repo).append(data.html).children().fadeIn(900);
    });
  });
}).call(this);
