// Generated by CoffeeScript 1.10.0
(function() {
  var cache, config, https, keys, utils;

  https = require('https');

  utils = require('../utils/utils');

  cache = require('../utils/cache');

  keys = require('./keys.json');

  config = require('../config.json');

  module.exports = {
    mediaType: {
      Movie: "movies",
      Show: "shows"
    },
    fetchIDs: function(mediaType, trakt_id_or_slug, callback) {
      var options, traktRequestCallback, url;
      options = {
        host: 'api.trakt.tv',
        path: "/" + mediaType + "/" + trakt_id_or_slug,
        headers: {
          "Content-Type": "application/json",
          "trakt-api-version": 2,
          "trakt-api-key": keys.TRAKT_CLIENT_ID
        }
      };
      url = utils.buildURLwithOptions(options);
      traktRequestCallback = function(response) {
        var data;
        data = '';
        response.on('data', function(chunk) {
          return data += chunk;
        });
        return response.on('end', function() {
          var json;
          if (response.statusCode === 200) {
            json = JSON.parse(data);
            if (json != null) {
              cache.save(url, data);
              return callback(json, null);
            } else {
              return callback(null, {
                success: false,
                message: "empty response; could not parse json"
              });
            }
          } else {
            return callback(null, {
              success: false,
              message: "[trakt#request-failed] " + url
            });
          }
        });
      };
      cache.load(url, function(cachedData) {
        var json;
        if (cachedData != null) {
          json = JSON.parse(cachedData);
          if (json != null) {
            callback(json, null);
            return;
          }
        }
        return https.request(options, traktRequestCallback).end();
      });
    }
  };

}).call(this);
