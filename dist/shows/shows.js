// Generated by CoffeeScript 1.10.0
(function() {
  var mediaFetchRequest, self;

  mediaFetchRequest = require('../common/mediaFetchRequest');

  self = module.exports = {
    get: function(req, res, next) {
      mediaFetchRequest.get(req, res, next, mediaFetchRequest.mediaType.Shows);
    },
    getMultiple: function(req, res, next) {
      mediaFetchRequest.getMultiple(req, res, next, mediaFetchRequest.mediaType.Shows);
    }
  };

}).call(this);
