angular.module('azzertApp').factory 'questionResource', ($resource) ->

  $resource('/api/questions/:id', {id:'@id'} )
