
angular.module('azzertApp', ['ui', 'ui.bootstrap', 'ngCookies', 'ngResource'])
  .config ($routeProvider) ->
    $routeProvider
      .when '/',
        redirectTo: '/questions'
      .when '/questions',
        controller: 'QuestionsCtrl'
        templateUrl: '/views/questions'
      .when '/questions/:id',
        controller: 'QuestionCtrl'
        templateUrl: '/views/question'
      .otherwise
        redirectTo: '/'
  .config ($locationProvider) ->
    $locationProvider.html5Mode(true)
