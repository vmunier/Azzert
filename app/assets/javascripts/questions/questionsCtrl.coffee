angular.module('azzertApp').controller 'QuestionsCtrl', ($scope, titleService, questionResource) ->

  titleService.set("All Questions")

  $scope.questions = questionResource.query {}, () ->
    console.log("$scope.questions : ", $scope.questions)

  $scope.answers = [{text:""}, {text:""}]

  $scope.saveQuestion = () ->
    console.log $scope.questionName
    console.log "answers : ", $scope.answers
    formParams = {name: $scope.questionName}
    answerIdx = 0
    for answer in $scope.answers
      if answer.text != ""
        formParams["answers[#{answerIdx}]"] = answer.text
        answerIdx += 1

    console.log("formParams : ", formParams)
    questionResource.save formParams
    console.log "question saved"
