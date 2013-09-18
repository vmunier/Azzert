# Returns an exec function, that, as long as it continues to be invoked, will not be triggered.
# The function will be called after it stops being called for N milliseconds.
angular.module('azzertApp').factory 'debounce', ($timeout, $q) ->
  (wait) ->
    self =
      timeout: undefined
      deferred: $q.defer()

    exec = (func) ->
      context = this
      args = arguments
      later = () ->
        self.timeout = undefined
        self.deferred.resolve(func.apply(context, args))
        self.deferred = $q.defer()

      if self.timeout?
        $timeout.cancel(self.timeout)
      self.timeout = $timeout(later, wait)
      self.deferred.promise
    exec: exec
