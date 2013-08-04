angular.module('azzertApp').controller 'QuestionsCtrl', ($scope, titleService, questionResource) ->

  titleService.set("All Questions")

  $scope.questions = questionResource.query {}, () ->
    console.log("$scope.questions : ", $scope.questions)
