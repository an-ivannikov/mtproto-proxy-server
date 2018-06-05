var express = require('express');
var router = express.Router();
var server_info = require('../server_info.json');
var proxy_links = require('../proxy_links.json');

/* GET home page. */
router.get('/', function(req, res, next) {

  res.render('index',
    {
      title: 'Free proxy (MTProxy MTPROTO) for Telegram Messenger',
      description: 'Free proxy (MTProxy MTPROTO) for Telegram Messenger',
      keywords: [ 'mtproxy', 'mtproto', 'telegram', 'proxy', 'free' ],
      links: proxy_links,
      server: server_info
    }
  );
});

module.exports = router;
