// Generated by CoffeeScript 1.10.0
(function() {
  var cache, config, https, keys, self, utils;

  https = require('https');

  utils = require('../utils/utils');

  cache = require('../utils/cache');

  keys = require('./keys.json');

  config = require('../config.json').tmdb;

  self = module.exports = {
    mediaType: {
      Movie: "movie",
      Show: "tv"
    },
    fetchImageMetaData: function(mediaType, tvdb_id, callback, season_number, episode_number) {
      var TMDB_API_VERSION, TMDB_BASE_URL, fetchConfiguration, fetchImageMetaData, processData;
      if (season_number == null) {
        season_number = null;
      }
      if (episode_number == null) {
        episode_number = null;
      }
      TMDB_BASE_URL = "api.themoviedb.org";
      TMDB_API_VERSION = "3";
      fetchConfiguration = function(callback) {
        var options, tmdbConfigurationCallback, url;
        options = {
          host: TMDB_BASE_URL,
          path: "/" + TMDB_API_VERSION + "/configuration?api_key=" + keys.TMDB_API_KEY,
          headers: {
            "Content-Type": "application/json"
          }
        };
        url = utils.buildURLwithOptions(options);
        tmdbConfigurationCallback = function(response) {
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
                cache.save(url, JSON.stringify(json), 86400);
                return fetchImageMetaData(callback, json);
              } else {
                return callback(null, {
                  success: false,
                  service: "tmdb",
                  message: "[TMDB#configuration] empty response; could not parse json"
                });
              }
            } else {
              return callback(null, {
                success: false,
                service: "tmdb",
                message: "[TMDB#request-failed] " + url
              });
            }
          });
        };
        return cache.load(url, function(cachedData) {
          var json;
          if (cachedData != null) {
            json = JSON.parse(cachedData);
            if (json != null) {
              fetchImageMetaData(callback, json);
            }
          } else {
            console.info("[TMDB] " + url);
            return https.request(options, tmdbConfigurationCallback).end();
          }
        });
      };
      processData = function(json, configuration) {
        var alias, baseURL, i, key, len, ref, ref1, relevantInfo, size;
        relevantInfo = {};
        if ((configuration["images"] != null) && (configuration["images"]["secure_base_url"] != null)) {
          baseURL = configuration["images"]["secure_base_url"];
          ref = config.asset_mapping;
          for (key in ref) {
            alias = ref[key];
            if ((json[key] != null) && (json[key][0] != null) && (json[key][0]["file_path"] != null)) {
              if ((key.slice(0, -1) != null) && (configuration["images"][key.slice(0, -1) + "_sizes"] != null)) {
                relevantInfo[alias] = {};
                ref1 = configuration["images"][key.slice(0, -1) + "_sizes"];
                for (i = 0, len = ref1.length; i < len; i++) {
                  size = ref1[i];
                  relevantInfo[alias][size] = baseURL + [size] + json[key][0]["file_path"];
                }
              } else {
                relevantInfo[alias] = {
                  original: baseURL + "original" + json[key][0]["file_path"]
                };
              }
            } else {
              relevantInfo[alias] = null;
            }
          }
        }
        relevantInfo.service = "tmdb";
        return relevantInfo;
      };
      fetchImageMetaData = function(callback, configuration) {
        var options, tmdbRequestCallback, url;
        options = {
          host: TMDB_BASE_URL,
          path: "/" + TMDB_API_VERSION + "/" + mediaType + "/" + tvdb_id + "/images?api_key=" + keys.TMDB_API_KEY,
          headers: {
            "Content-Type": "application/json"
          }
        };
        if (season_number != null) {
          options.path = "/" + TMDB_API_VERSION + "/tv/" + tvdb_id + "/season/" + season_number + "/images?api_key=" + keys.TMDB_API_KEY + "&language=en";
        }
        if ((season_number != null) && (episode_number != null)) {
          options.path = "/" + TMDB_API_VERSION + "/tv/" + tvdb_id + "/season/" + season_number + "/episode/" + episode_number + "/images?api_key=" + keys.TMDB_API_KEY;
          console.log(options.path);
        }
        url = utils.buildURLwithOptions(options);
        tmdbRequestCallback = function(response) {
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
                info = processData(json, configuration);
                cache.save(url, JSON.stringify(info));
                return callback(info, null);
              } else {
                return callback(null, {
                  success: false,
                  service: "tmdb",
                  message: "empty response; could not parse json"
                });
              }
            } else {
              return callback(null, {
                success: false,
                service: "tmdb",
                message: "[TMDB#request-failed] " + url
              });
            }
          });
        };
        return cache.load(url, function(cachedData) {
          var json;
          if (cachedData != null) {
            json = JSON.parse(cachedData);
            if (json != null) {
              callback(json, null);
              return;
            }
          }
          return https.request(options, tmdbRequestCallback).end();
        });
      };
      fetchConfiguration(callback);
    }
  };

}).call(this);
