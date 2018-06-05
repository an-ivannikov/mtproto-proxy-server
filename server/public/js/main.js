function mainPageWidgetsInit () {
  twitterShareInit();
  gplusShareInit();
  facebookShareInit();
}

function twitterShareInit() {
  var e = document.createElement('script');
  e.type="text/javascript";
  e.async = true;
  e.src = '//platform.twitter.com/widgets.js';
  document.getElementsByTagName('head')[0].appendChild(e); //Twitter tracking
  if (!window.jQuery) {
    return;
  }
  jQuery(e).load(function() {
    twttr.events.bind('tweet', function (intent_event) {
      if (intent_event) {
        // console.log('tw');
        ga('send', 'event', 'Share', 'Twitter Share', document.location.href);
      }
    });

    twttr.events.bind('click', function (intent_event) {
      if (intent_event) {
        // console.log('tw cl');
        ga('send', 'event', 'Share', 'Twitter Click', document.location.href);
      }
    });
  });
}

var jsonpCallbacks = [];
function twitterCustomShareInit () {
  var btns = document.querySelectorAll
                ? document.querySelectorAll('.tl_twitter_share_btn')
                : [document.getElementById('tl_twitter_share_btn')];

  if (!btns.length) {
    return;
  }
  var head = document.getElementsByTagName('head')[0], i, script;
  for (i = 0; i < btns.length; i++) {
    (function (btn) {
      var status = btn.getAttribute('data-text'),
          url = btn.getAttribute('data-url') || location.toString() || 'https://telegram.org/',
          via = btn.getAttribute('data-via');

      script = document.createElement('script');
      script.type="text/javascript";
      script.async = true;
      script.src = 'https://cdn.api.twitter.com/1/urls/count.json?url=' + encodeURIComponent(url) + '&callback=jsonpCallbacks[' + jsonpCallbacks.length + ']&rnd=' + Math.random();
      head.appendChild(script);

      var urlEncoded = encodeURIComponent(url),
          popupUrl = 'https://twitter.com/intent/tweet?text=' + encodeURIComponent(status) + '&url=' + urlEncoded + '&via=' + encodeURIComponent(via);

      jsonpCallbacks.push(function (data) {
        var cnt = btn.getElementsByTagName('span')[0]
        if (cnt && data.count) {
          cnt.innerHTML = data.count;
          cnt.style.display = 'inline';
        }
      });

      btn.setAttribute('href', popupUrl);
      btn.href = popupUrl;

      btn.addEventListener('click', function (e) {
        var popupW = 550,
            popupH = 450,
            params = [
              'width=' + popupW,
              'height=' + popupH,
              'left=' + Math.round(screen.width / 2 - popupW / 2),
              'top=' + Math.round(screen.height / 2 - popupH / 2),
              'personalbar=0',
              'toolbar=0',
              'scrollbars=1',
              'resizable=1'
            ].join(','),
            popup = window.open(popupUrl, '_blank', params);

        if (popup) {
          try {
            popup.focus();
          } catch (e) {}
        }

        return cancelEvent(e);
      }, false);
    })(btns[i]);
  }
}

function facebookLikeTooltipFix () {
  document.getElementById('fb_widget_wrap').style.height = '192px';
}

function facebookShareInit () {
  window.fbAsyncInit = function() {
    FB.init({
      appId: '254098051407226',
      status: true,
      cookie: true,
      xfbml: true
    });
    FB.Event.subscribe('edge.create', function(targetUrl) {
      facebookLikeTooltipFix();
      ga('send', 'event', 'Share', 'Facebook Like', document.location.href);
    });

    FB.Event.subscribe('edge.remove', function(targetUrl) {
      ga('send', 'event', 'Share', 'Facebook Unlike', document.location.href);
    });
  };

  (function(d, s, id){
    var js, fjs = d.getElementsByTagName(s)[0];
    if (d.getElementById(id)) {return;}
    js = d.createElement(s); js.id = id;
    js.src = "//connect.facebook.net/en_US/all.js";
    fjs.parentNode.insertBefore(js, fjs);
  }(document, 'script', 'facebook-jssdk'));
}

function gplusShareInit () {
  (function() {
    var po = document.createElement('script'); po.type = 'text/javascript'; po.async = true;
    po.src = 'https://apis.google.com/js/plusone.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(po, s);
  })();
}

function gplusOnShare (o) {
  // console.log('g+', o);
  if (o && o.state == 'off') {
    ga('send', 'event', 'Share', 'GPlus Share', document.location.href);
  } else {
    ga('send', 'event', 'Share', 'GPlus Unshare', document.location.href);
  }
}

function blogRecentNewsInit () {
  if (document.querySelectorAll) {
    var sideImages = document.querySelectorAll('.blog_side_image_wrap');
    var sideImage, parent, i;
    var len = len = sideImages.length;
    for (i = 0; i < len; i++) {
      sideImage = sideImages[i];
      parent = sideImage.parentNode.parentNode;
      if (parent) {
        parent.insertBefore(sideImage, parent.firstChild);
      }
    }
  }

  var moreBtn = document.getElementById('tlb_blog_head_more_link');
  if (!moreBtn) {
    return false;
  }

  var activeClassName = 'tlb_blog_head_recent_active';
  moreBtn.addEventListener('click', function (event) {
    var parent = this.parentNode;
    var className = parent.className;
    if (className.indexOf(activeClassName) == -1) {
      className += ' ' + activeClassName;
    } else {
      className = className.replace(' ' + activeClassName, '');
    }
    parent.className = className;

    return cancelEvent(event);
  });
}

function cancelEvent (event) {
  event = event || window.event;
  if (event) event = event.originalEvent || event;

  if (event.stopPropagation) event.stopPropagation();
  if (event.preventDefault) event.preventDefault();

  return false;
}

function trackDlClick (element, event) {
  var href = element.getAttribute('href'),
      track = element.getAttribute('data-track') || false;

  if (!track) {
    return;
  }

  var trackData = track.toString().split('/');

  ga('send', 'event', trackData[0], trackData[1], href);

  if ((element.getAttribute('target') || '').toLowerCase() != '_blank') {
    setTimeout(function() { location.href = href; }, 200);
    return false;
  }
}

var toTopWrapEl,
    toTopEl,
    pageContentWrapEl,
    curVisible,
    curShown = false;
function backToTopInit () {
  pageContentWrapEl = document.getElementById('dev_page_content_wrap');
  if (!pageContentWrapEl) {
    return false;
  }
  var t = document.createElement('div');

  t.innerHTML = '<div class="back_to_top"><i class="icon icon-to-top"></i>Go up</div>';
  toTopEl = t.firstChild;
  t.innerHTML = '<a class="back_to_top_wrap" onclick="backToTopGo()"></a>';
  toTopWrapEl = t.firstChild;

  toTopWrapEl.appendChild(toTopEl);
  document.body.appendChild(toTopWrapEl);

  if (window.addEventListener) {
    window.addEventListener('resize', backToTopResize, false);
    window.addEventListener('scroll', backToTopScroll, false);
  }
  backToTopResize();
}

function backToTopGo () {
  window.scroll(0, 0);
  backToTopScroll();
}

function backToTopResize () {
  var left = getXY(pageContentWrapEl)[0],
      dwidth = Math.max(window.innerWidth, document.documentElement.clientWidth, 0),
      dheight = Math.max(window.innerHeight, document.documentElement.clientHeight);

  curVisible = pageContentWrapEl && left > 130 && dwidth > 640;
  toTopWrapEl.style.width = left + 'px';
  toTopEl.style.height = dheight + 'px';
  backToTopScroll();
}

function backToTopScroll () {
  var st = window.pageYOffset || document.body.scrollTop || document.documentElement.scrollTop || document.documentElement.scrollTop;
  if ((st > 400 && curVisible) != curShown) {
    curShown = !curShown;
    toTopWrapEl.className = 'back_to_top_wrap' + (curShown ? ' back_to_top_shown' : '');
  }
}

function getXY (obj) {
  if (!obj) return [0, 0];

  var left = 0, top = 0;
  if (obj.offsetParent) {
    do {
      left += obj.offsetLeft;
      top += obj.offsetTop;
    } while (obj = obj.offsetParent);
  }
  return [left, top];
}


var onDdBodyClick,
    currentDd;
function dropdownClick (element, event) {
  var parent = element.parentNode;
  var isOpen = (parent.className || '').indexOf('open') > 0;
  if (currentDd && currentDd != parent) {
    dropdownHide(currentDd);
  }
  if (!isOpen) {
    parent.className = (parent.className || '') + ' open';
    if (!onDdBodyClick) {
      window.addEventListener('click', dropdownPageClick, false);
    }
    currentDd = parent;
  } else {
    dropdownHide(currentDd);
    currentDd = false;
  }
  event.cancelBubble = true;
  return false;
}

function dropdownHide (parent) {
  parent.className = parent.className.replace(' open', '');
}

function dropdownPageClick (event) {
  if (currentDd) {
    dropdownHide(currentDd);
    currentDd = false;
  }
}

function escapeHTML (html) {
  html = html || '';
  return html.replace(/&/g, '&amp;')
             .replace(/>/g, '&gt;')
             .replace(/</g, '&lt;')
             .replace(/"/g, '&quot;')
             .replace(/'/g, '&apos;');
}

function videoTogglePlay(el) {
  if (el.paused) {
    el.play();
  } else {
    el.pause();
  }
}

function getDevPageNav() {
  // console.time('page nav');
  var menu = $('<ul class="nav navbar-nav navbar-default"></ul>');
  var lastLi = false;
  var items = 0;
  $('a.anchor').each(function (k, anchor) {
    var parentTag = anchor.parentNode.tagName;
    var matches = parentTag.match(/^h([34])$/i);
    var anchorName = anchor.name;
    if (!matches || !anchorName) {
      return;
    }
    anchor.id = anchor.name;
    var level = parseInt(matches[1]);
    var li = $('<li><a href="#'+ anchorName +'" data-target="#'+ anchorName +'">' + escapeHTML(anchor.nextSibling.textContent) + '</a></li>');
    if (level == 3) {
      li.appendTo(menu);
      lastLi = li;
    } else {
      // console.log(lastLi);
      if (!lastLi) {
        return;
      }
      var subMenu = $('ul', lastLi)[0] || $('<ul class="nav"></ul>').appendTo(lastLi);
      // console.log(subMenu);
      li.appendTo(subMenu);
    }
    items++;
  });
  // console.log(items, menu);
  // console.timeEnd('page nav');
  if (items < 2) {
    return false;
  }

  return menu;
}

function initDevPageNav() {
  window.hasDevPageNav = true;
  var menu = getDevPageNav();
  if (!menu) {
    return;
  }
  var sideNavCont = $('#dev_side_nav_cont');
  if (!sideNavCont.length) {
    sideNavCont = $('#dev_page_content_wrap');
  }
  var sideNavWrap = $('<div class="dev_side_nav_wrap"></div>').prependTo(sideNavCont);
  var sideNav = $('<div class="dev_side_nav"></div>').appendTo(sideNavWrap);
  menu.appendTo(sideNav);
  $('body').css({position: 'relative'}).scrollspy({ target: '.dev_side_nav' });

  $('body').on('activate.bs.scrollspy', function () {
    $('.dev_side_nav > ul').affix('checkPosition');
    var active_el = $('.dev_side_nav li.active').get(-1);
    if (active_el) {
      if (active_el.scrollIntoViewIfNeeded) {
        active_el.scrollIntoViewIfNeeded();
      } else if (active_el.scrollIntoView) {
        active_el.scrollIntoView(false);
      }
    }
  });
  $('body').trigger('activate.bs.scrollspy');

  updateMenuAffix(menu);
}

function updateDevPageNav() {
  if (!window.hasDevPageNav) {
    return;
  }
  var menu = getDevPageNav() || $('<ul></ul>');
  $('.dev_side_nav > ul').replaceWith(menu);
  $('body').scrollspy('refresh');
  updateMenuAffix(menu);
}

function updateMenuAffix(menu) {
  menu.affix({
    offset: {
      top: function () {
        return $('.dev_side_nav_wrap').offset().top;
      },
      bottom: function () {
        return (this.bottom = $('.footer_wrap').outerHeight(true) + 20)
      }
    }
  })
}


function initScrollVideos(desktop) {
  var videos = document.querySelectorAll
                ? document.querySelectorAll('video.tl_blog_vid_autoplay')
                : [];

  window.pageVideos = Array.prototype.slice.apply(videos);
  if (!pageVideos.length) {
    return;
  }
  window.pageVideosPlaying = {};

  var index = 1;
  for (var i = 0; i < pageVideos.length; i++) {
    var videoEl = pageVideos[i];
    videoEl.setAttribute('vindex', index++);
    if (desktop) {
      videoEl.removeAttribute('controls');
    }
    videoEl.autoplay = false;
    videoEl.removeAttribute('autoplay');
    videoEl.setAttribute('preload', 'auto');
    videoEl.preload = 'auto';
  }
  if (!desktop) {
    return;
  }

  window.addEventListener('scroll', checkScrollVideos, false);
  window.addEventListener('resize', checkScrollVideos, false);
  setTimeout(checkScrollVideos, 1000);
}

function checkScrollVideos() {
  var w = window,
      d = document,
      e = d.documentElement,
      g = d.getElementsByTagName('body')[0],
      winWidth = w.innerWidth || e.clientWidth || g.clientWidth,
      winHeight = w.innerHeight|| e.clientHeight|| g.clientHeight,
      scrollTop = e.scrollTop || g.scrollTop || w.pageYOffset;

  for (var i = 0; i < pageVideos.length; i++) {
    var videoEl = pageVideos[i];
    var curIndex = videoEl.getAttribute('vindex');
    var posY = getFullOffsetY(videoEl);
    var height = videoEl.offsetHeight;
    // console.log(scrollTop, winHeight, posY, height);

    if (posY > scrollTop && posY + height < scrollTop + winHeight) {
      if (!pageVideosPlaying[curIndex]) {
        pageVideosPlaying[curIndex] = true;
        console.log('play', videoEl);
        videoEl.play();
      }
    } else {
      if (pageVideosPlaying[curIndex]) {
        delete pageVideosPlaying[curIndex];
        console.log('pause', videoEl);
        videoEl.pause();
      }
    }
  }
}

function getFullOffsetY(el) {
  var offsetTop = el.offsetTop || 0;
  if (el.offsetParent) {
    offsetTop += getFullOffsetY(el.offsetParent);
  }
  return offsetTop;
}

function redraw(el) {
  el.offsetTop + 1;
}

function initRipple() {
  if (!document.querySelectorAll) return;
  var rippleTextFields = document.querySelectorAll('.textfield-item input.form-control');
  for (var i = 0; i < rippleTextFields.length; i++) {
    (function(rippleTextField) {
      function onTextRippleStart(e) {
        if (document.activeElement === rippleTextField) return;
        var rect = rippleTextField.getBoundingClientRect();
        if (e.type == 'touchstart') {
          var clientX = e.targetTouches[0].clientX;
        } else {
          var clientX = e.clientX;
        }
        var ripple = rippleTextField.parentNode.querySelector('.textfield-item-underline');
        var rippleX = (clientX - rect.left) / rippleTextField.offsetWidth * 100;
        ripple.style.transition = 'none';
        redraw(ripple);
        ripple.style.left = rippleX + '%';
        ripple.style.right = (100 - rippleX) + '%';
        redraw(ripple);
        ripple.style.left = '';
        ripple.style.right = '';
        ripple.style.transition = '';
      }
      rippleTextField.addEventListener('mousedown', onTextRippleStart);
      rippleTextField.addEventListener('touchstart', onTextRippleStart);
    })(rippleTextFields[i]);
  }
  var rippleHandlers = document.querySelectorAll('.ripple-handler');
  for (var i = 0; i < rippleHandlers.length; i++) {
    (function(rippleHandler) {
      function onRippleStart(e) {
        var rippleMask = rippleHandler.querySelector('.ripple-mask');
        if (!rippleMask) return;
        var rect = rippleMask.getBoundingClientRect();
        if (e.type == 'touchstart') {
          var clientX = e.targetTouches[0].clientX;
          var clientY = e.targetTouches[0].clientY;
        } else {
          var clientX = e.clientX;
          var clientY = e.clientY;
        }
        var rippleX = (clientX - rect.left) - rippleMask.offsetWidth / 2;
        var rippleY = (clientY - rect.top) - rippleMask.offsetHeight / 2;
        var ripple = rippleHandler.querySelector('.ripple');
        ripple.style.transition = 'none';
        redraw(ripple);
        ripple.style.transform = 'translate3d(' + rippleX + 'px, ' + rippleY + 'px, 0) scale3d(0.2, 0.2, 1)';
        ripple.style.opacity = 1;
        redraw(ripple);
        ripple.style.transform = 'translate3d(' + rippleX + 'px, ' + rippleY + 'px, 0) scale3d(1, 1, 1)';
        ripple.style.transition = '';

        function onRippleEnd(e) {
          ripple.style.transitionDuration = '.2s';
          ripple.style.opacity = 0;
          document.removeEventListener('mouseup', onRippleEnd);
          document.removeEventListener('touchend', onRippleEnd);
          document.removeEventListener('touchcancel', onRippleEnd);
        }
        document.addEventListener('mouseup', onRippleEnd);
        document.addEventListener('touchend', onRippleEnd);
        document.addEventListener('touchcancel', onRippleEnd);
      }
      rippleHandler.addEventListener('mousedown', onRippleStart);
      rippleHandler.addEventListener('touchstart', onRippleStart);
    })(rippleHandlers[i]);
  }
}
