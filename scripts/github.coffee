module.exports = (robot) ->
  robot.hear /gh #(.*)|GH #(.*)/i, (msg) ->
    msg.send "https://github.com/mautic/mautic/issues/#{msg.match[1]}"