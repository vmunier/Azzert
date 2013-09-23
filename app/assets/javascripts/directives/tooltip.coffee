angular.module('azzertApp').directive "tooltip", ->
  restrict: "A"
  link: (scope, element, attrs) ->
    $(element).attr("title", scope.$eval(attrs.tooltip)).tooltip()
