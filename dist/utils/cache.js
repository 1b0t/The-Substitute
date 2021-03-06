// Generated by CoffeeScript 1.10.0
(function() {
  var client, config, redis;

  redis = require('redis');

  config = require('../config.json');

  client = redis.createClient();

  client.on("error", function(error) {
    return console.log("Error " + error);
  });

  module.exports = {
    save: function(url, data, expire) {
      if (expire == null) {
        expire = config.cache_expires_after_seconds;
      }
      client.set(url, data, redis.print);
      client.expire(url, expire);
    },
    load: function(url, callback) {
      client.get(url, function(err, data) {
        if (data != null) {
          callback(data);
        } else {
          callback(null);
        }
        if (err != null) {
          return callback(null);
        }
      });
    }
  };

}).call(this);
