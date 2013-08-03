
angular.module('azzertApp', [])
  .config ($routeProvider) ->
    $routeProvider
      .when '/',
        redirectTo: '/questions'
      .when '/questions',
        controller: 'QuestionsCtrl'
      .when '/questions/:name',
        controller: 'QuestionCtrl'
      .otherwise
        redirectTo: '/'
