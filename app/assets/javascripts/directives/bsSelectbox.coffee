# Bootstrap dropbox directive
# found here : http://jsfiddle.net/M32pj/1/
angular.module('azzertApp').directive 'bsSelectbox', ($compile, $timeout, $parse) ->
  restrict: "A"
  priority: 100
  transclude: true
  scope:
    themodel: "=ngModel"
    thearray: "@ngOptions"
    defaultval: "@bsSelectbox"

  template: "<div class=\"bs-selectbox\" style=\"display:inline;\">" + "<div class=\"btn-group\">" + "<button class=\"btn dropdown-toggle\" data-toggle=\"dropdown\" type=\"button\">" + "{{display}} " + "<span class=\"caret\"></span>" + "</button>" + "<ul class=\"dropdown-menu\">" + "<li ng-show=\"defaultval\">" + "<a href=\"#\" ng-click=\"change(false)\"> <span>{{defaultval}}</span> </a>" + "</li>" + "<li ng-show=\"defaultval\" class=\"divider\"></li>" + "<li ng-repeat=\"itm in elements\">" + "<a href=\"#\" ng-click=\"change(itm)\">" + "<span>{{itm.label}}</span>" + "</a>" + "</li>" + "</ul>" + "</div>" + "<div style=\"display:none;\" class=\"bs-selectbox-transclude\" ng-transclude></div>" + "</div>"
  link: (scope, element, attrs) ->
    scope.display = "--"
    scope.elements = []
    scope.element = angular.element(".bs-selectbox").index(element)
    attrs.$observe "bsSelectbox", (value) ->
      scope.display = value  if value

    attrs.$observe "ngOptions", (value, element) ->
      if angular.isDefined(value)
        match = undefined
        loc = {}
        NG_OPTIONS_REGEXP = /^\s*(.*?)(?:\s+as\s+(.*?))?(?:\s+group\s+by\s+(.*))?\s+for\s+(?:([\$\w][\$\w\d]*)|(?:\(\s*([\$\w][\$\w\d]*)\s*,\s*([\$\w][\$\w\d]*)\s*\)))\s+in\s+(.*)$/
        if match = value.match(NG_OPTIONS_REGEXP)
          displayFn = $parse(match[2] or match[1])
          valueName = match[4] or match[6]
          valueFn = $parse((if match[2] then match[1] else valueName))
          valuesFn = $parse(match[7])
          collection = valuesFn(scope.$parent) or []
          angular.forEach collection, (value, key) ->
            loc[valueName] = collection[key]
            scope.elements.push
              label: displayFn(scope.$parent, loc)
              value: valueFn(scope.$parent, loc)



    scope.$watch "themodel", ->
      scope.setdefault()

    scope.setdefault = ->
      angular.forEach scope.elements, (value, key) ->
        scope.display = value.label  if value.value is scope.themodel


    scope.change = (itm) ->
      unless itm
        scope.display = scope.defaultval
        scope.themodel = ""
      else
        scope.display = itm.label
        scope.themodel = itm.value

    elements = element.find(".bs-selectbox-transclude").children()
    if angular.isObject(elements) and elements.length
      angular.forEach elements, (value, key) ->
        scope.elements.push
          label: value.label
          value: value.value


      scope.setdefault()

  replace: true
