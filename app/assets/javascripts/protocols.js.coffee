# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  substringMatcher = (strs) ->
    findMatches = (q, cb) ->
      matches = undefined
      substrRegex = undefined
      
      # an array that will be populated with substring matches
      matches = []
      
      # regex used to determine if a string contains the substring `q`
      substrRegex = new RegExp(q, "i")
      
      # iterate through the pool of strings and for any string that
      # contains the substring `q`, add it to the `matches` array
      $.each strs, (i, str) ->
        
        # the typeahead jQuery plugin expects suggestions to a
        # JavaScript object, refer to typeahead docs for more info
        matches.push value: str  if substrRegex.test(str)
        return

      cb matches
      return

  # protocols = $('.protocols_search_values').val()
  # protocols = [{"value":"Test Title","short_title":"Test Title","sparc_id":5},{"value":"Test Title","short_title":"Test Title","sparc_id":5}] 
  protocols = [{"value": "Tyler Smith", "firstname": "Tyler", "lastname": "Smith", "id": "33"}]

  $("#search_box .typeahead").typeahead
    hint: true
    highlight: true
    minLength: 1
  ,
    name: "protocols"
    displayKey: "value"
    source: substringMatcher(protocols)

