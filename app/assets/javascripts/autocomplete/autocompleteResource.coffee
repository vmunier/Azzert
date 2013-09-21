angular.module('azzertApp').factory 'autocompleteResource', ($resource) ->

  $resource('/api/autocomplete/:keyword', {keyword:'@keyword'},
    search:
      method: 'GET'
  )
