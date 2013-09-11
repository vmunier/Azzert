angular.module('azzertApp').service 'chartTimeService', () ->
  self = @

  pastHour = () ->
    updateDate( (d) -> d.setHours(d.getHours() - 1) )

  past24Hours = () ->
    updateDate( (d) -> d.setHours(d.getHours() - 24) )

  pastWeek = () ->
    updateDate( (d) -> d.setDate(d.getDate() - 7) )

  pastMonth = () ->
    updateDate( (d) -> d.setMonth(d.getMonth() - 1) )

  pastYear = () ->
    updateDate( (d) -> d.setFullYear(d.getFullYear() - 1) )

  # returns the date after updating it
  updateDate = (update) ->
    d = new Date()
    update(d)
    d

  self.chartTimeOptions = [
    label:"Any Time"
    value: 2
  ,
    label:"Past hour"
    value: pastHour
  ,
    # say past 24 hours because it is clearer to the user than past date
    label:"Past 24 hours"
    value: past24Hours
  ,
    label:"Past week"
    value: pastWeek
  ,
    label:"Past month"
    value: pastMonth
  ,
    label:"Past year"
    value: pastYear
  ]

  self
