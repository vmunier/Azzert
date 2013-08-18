angular.module('azzertApp').controller 'QuestionsCtrl', ($scope, $location, titleService, questionResource) ->

  $scope.MaxAnswers = 10
  $scope.questionName = ""

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

  saveSuccess = (questionIdData) ->
    questionId = questionIdData.data
    $location.path("/questions/#{questionId}")

  $scope.saveQuestion = () ->
    formParams = {name: $scope.questionName}
    answers = excludeEmptyAnswers()
    for answer, i in answers
      formParams["answers[#{i}]"] = answer.text

    questionResource.save formParams, saveSuccess

  excludeEmptyAnswers = () ->
    $scope.answers.filter((answer) -> answer.text != "")

  $scope.invalidQuestionForm = () ->
    excludeEmptyAnswers().length == 0 or $scope.questionName == ""
