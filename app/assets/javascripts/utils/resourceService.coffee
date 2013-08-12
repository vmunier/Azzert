# The expecting response from save and delete is neither an array nor a json object, it is a string.
# As angular resource returns always an array or a json object, even if responseType is set to text,
# this resourceService transforms the response to store it in a simple object.
angular.module('azzertApp').service 'resourceService', () ->
  self = @

  # data is a string, store it in a simple json object
  simpleTransformResponse = (data, headers) ->
    data: data

  self.simpleTransformResponse = simpleTransformResponse
