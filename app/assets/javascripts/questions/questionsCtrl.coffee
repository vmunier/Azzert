angular.module('azzertApp').controller 'QuestionsCtrl', ($scope, titleService, questionResource) ->

  $scope.MaxAnswers = 10

  titleService.set("All Questions")

  $scope.questions = questionResource.query {}, () ->
    console.log("$scope.questions : ", $scope.questions)

  emptyAnswer = () ->
    {text:""}

  $scope.answers = [emptyAnswer(), emptyAnswer()]

  $scope.checkToPushEmptyAnswer = () ->
    lastAnswer = $scope.answers[$scope.answers.length - 1]
    if lastAnswer.text != "" and $scope.answers.length < $scope.MaxAnswers
      $scope.answers.push(emptyAnswer())

  $scope.saveQuestion = () ->
    formParams = {name: $scope.questionName}
    answerIdx = 0
    for answer in $scope.answers
      if answer.text != ""
        formParams["answers[#{answerIdx}]"] = answer.text
        answerIdx += 1

    console.log("formParams : ", formParams)
    questionResource.save formParams
