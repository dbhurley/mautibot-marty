module.exports = (robot) ->
  robot.hear /linklist/i, (msg) ->
    msg.http('https://slack.com/api/search.messages?token=xoxp-2558748822-2558748846-4455327223-fafe87&query=http%20-drop%2C%20-twitter%2C%20-github%2C%20-mautic.org%20%20in%3Aallyde%20from%3A%40dbhurley%20&pretty=1')
    .get() (error, response, body) ->
      if error
        msg.send "Got a problem #{error}"
        return
      response = JSON.parse(body)
      matches = response.messages.matches
      message = ""
      for k, v of matches
        message += v.text
      msg.send "#{message}"
