angular.module('azzertApp').controller 'QuestionsCtrl', ($scope, $location, titleService, questionResource, debounce, autocompleteResource) ->

  $scope.MaxAnswers = 10
  $scope.questionName = ""

  titleService.set("All Questions")

  $scope.questions = []

  defaultQuestions = questionResource.query {}, () ->
    angular.copy(defaultQuestions, $scope.questions)
    console.log("default questions : ", defaultQuestions)

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

  searchAutocomplete = (keyword) ->
    autocompleteResource.search keyword:keyword, (response) ->
      questions = []
      for obj in response.hits.hits
        src = obj._source
        questions.push
          _id: src.questionId
          name: src.question
      angular.copy(questions, $scope.questions)

  debounceAutocomplete = debounce(1600)

  $scope.debouncedAutocomplete = (keyword) ->
    # the timeout is 400 ms once the keyword is longer than 5 chars
    timeout = Math.max(2400 - (keyword.length * 400), 400)
    $scope.autocomplete(keyword, timeout)

  $scope.autocomplete = (keyword, timeout) ->
    if keyword < 2
      angular.copy(defaultQuestions, $scope.questions)
    else
      debounceAutocomplete.exec( () ->
        response = searchAutocomplete(keyword)
        response
      , timeout)
