(function() {
  LazyLoad.load(['https://s3.amazonaws.com/odekirk/socket.io.js', 'https://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js', 'https://s3.amazonaws.com/odekirk/imagesloaded.jquery.min.js', 'https://s3.amazonaws.com/odekirk/jquery.masonry.min.js'], function() {
    var socket;
    jQuery(function($) {
      var art, big, canvas, close, container, expand, minify;
      close = $('a.close');
      art = $('#art');
      canvas = $('.media-grid');
      big = $('#overlay');
      container = $('.container');
      expand = $('#expand');
      minify = $('#minify');
      expand.click(function(e) {
        expand.hide();
        art.toggleClass('span-one-third span16').width('98%');
        container.addClass('active');
        canvas.fadeOut(function() {
          canvas.find('img').each(function(i, el) {
            return $(this).attr('src', el.src.replace('s40-c', 's150'));
          }).imagesLoaded(function(imgs) {});
          canvas.fadeIn();
          return minify.show();
        });
        minify.one('click', function(e) {
          minify.hide();
          art.removeAttr('style').toggleClass('span-one-third span16').find('img').each(function(i, el) {
            return $(this).attr('src', el.src.replace('s150', 's40-c'));
          }).imagesLoaded(function() {
            return canvas.masonry('reload');
          });
          container.removeClass('active');
          expand.removeAttr('style');
          return false;
        });
        return false;
      });
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
      canvas.imagesLoaded(function() {
        return this.masonry({
          isAnimated: true
        });
      });
      return container.addClass('loaded');
    });
    socket = io.connect('http://localhost');
    socket.on('clear', function() {
      return $('#gallery').empty();
    });
    socket.on('painting', function(data) {
      return $('#gallery').append(data).imagesLoaded(function(images) {
        return $(images).fadeIn(900);
      });
    });
    return socket.on('post', function(data) {
      return $('#post').append(data).children().fadeIn(900);
    });
  });
}).call(this);
