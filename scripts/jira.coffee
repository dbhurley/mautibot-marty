module.exports = (robot) ->
  robot.respond /create issue titled (.*) about (.*) with priority (.*)/i, (msg) ->
    user = "mautibot"
    pass = "mautibot"
    auth = 'Basic ' + new Buffer(user + ':' + pass).toString('base64')
    data = JSON.stringify({
      fields: {
        project: {
          key: "MAU"
        }
        summary: msg.match[1]
        description: msg.match[2]
        issuetype: {
          name: "Task"
        }
        priority: {
          name: msg.match[3]
        }
      }
    })
    msg.http('https://webspark.atlassian.net/rest/api/2/issue')
    .headers(Authorization: auth, 'Content-Type': 'Application/json')
    .post(data) (error, response, body) ->
      data = JSON.parse(body)
      msg.send "Ok, I created a new issue (#{data.key}) for you https://webspark.atlassian.net/browse/#{data.key}"

  robot.respond /update issue (.*) set status (.*)/i, (msg) ->
    user = "mautibot"
    pass = "mautibot"
    issue = msg.match[1]
    url = "https://webspark.atlassian.net/rest/api/2/issue/#{issue}/transitions?expand=transitions.fields"
    switch msg.match[2]
      when "Open" then status = "1"
      when "In Progress" then status = "3"
      when "Reopened" then status = "4"
      when "Resolved" then status = "5"
      when "Closed" then status = "6"
      when "Done" then status = "10002"
      when "In Development" then status = "10003"

    auth = 'Basic ' + new Buffer(user + ':' + pass).toString('base64')
    data = JSON.stringify({
      "transition": {
        "id": "#{status}"
      }
    })
    msg.http(url)
    .headers(Authorization: auth, 'Content-Type': 'Application/json')
    .post(data) (error, response, body) ->
      if response = 204
#msg.send url
        msg.send "Ok, I updated the issue with a new status of #{msg.match[2]}"
#data = JSON.parse(body)
#msg.send data.toString()
#msg.send "Ok, I updated issue (#{data.key}) for you with status #{status} https://webspark.atlassian.net/browse/#{data.key}"