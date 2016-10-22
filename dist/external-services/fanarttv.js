// Generated by CoffeeScript 1.10.0
(function() {
  var cache, config, https, keys, utils;

  https = require('https');

  utils = require('../utils/utils');

  cache = require('../utils/cache');

  keys = require('./keys.json');

  config = require('../config.json').fanarttv;

  module.exports = {
    mediaType: {
      Movie: "movies",
      Show: "tv"
    },
    fetchImageMetaData: function(mediaType, imdb_id, callback, season_number, episode_number) {
      var fanarttvRequestCallback, options, processData, url;
      if (season_number == null) {
        season_number = null;
      }
      if (episode_number == null) {
        episode_number = null;
      }
      if ((episode_number != null) || (season_number != null)) {
        callback(null, {
          service: "fanarttv",
          status: 501,
          message: "not implemented"
        });
        return;
      }
      processData = function(json) {
        var alias, key, ref, relevantInfo;
        relevantInfo = {};
        ref = config.asset_mapping[mediaType];
        for (key in ref) {
          alias = ref[key];
          if (alias != null) {
            if ((json[key] != null) && (json[key][0] != null) && json[key][0]["url"]) {
              relevantInfo[alias] = {
                original: json[key][0]["url"]
              };
            } else {
              relevantInfo[alias] = null;
            }
          }
        }
        relevantInfo.service = "fanarttv";
        return relevantInfo;
      };
      options = {
        host: 'webservice.fanart.tv',
        path: "/v3/" + mediaType + "/" + imdb_id + "?api_key=" + keys.FANART_TV_API_KEY,
        headers: {
          "Content-Type": "application/json"
        }
      };
      url = utils.buildURLwithOptions(options);
      fanarttvRequestCallback = function(response) {
        var data;
        data = '';
        response.on('data', function(chunk) {
          return data += chunk;
        });
        return response.on('end', function() {
          var info, json;
          if (response.statusCode === 200) {
            json = JSON.parse(data);
            if (json != null) {
              info = processData(json);
              cache.save(url, JSON.stringify(info));
              return callback(info, null);
            } else {
              return callback(null, {
                service: "fanarttv",
                message: "[fanarttv]empty response; could not parse json"
              });
            }
          } else {
            return callback(null, {
              service: "fanarttv",
              message: "[fanarttv#request-failed] " + url
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
        return https.request(options, fanarttvRequestCallback).end();
      });
    }
  };

}).call(this);
