module.exports = (robot) ->
  robot.respond /msg #(.*) say (.*)/i, (msg) ->
    channelName = escape(msg.match[1])
    content = msg.match[2]
    query = {channel: "#" + channelName, text: content, username: "Mautibot", as_user: false, icon_emoji: ":mautibot:", link_names: true}
    msg.http('https://slack.com/api/chat.postMessage?token=xoxp-2558748822-2558748846-11094344100-32b9b92bff').query(query)
    .get() (error, response, body) ->
      if error
        msg.send "Got a problem #{error}"
        return
      response = JSON.parse(body)
      msg.send "Message delivered."
