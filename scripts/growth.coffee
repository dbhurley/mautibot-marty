{spawn, exec} = require 'child_process'

execCommand = (msg, cmd) ->
  exec cmd, (error, stdout, stderr) ->
    msg.send error
    msg.send stdout
    msg.send stderr

module.exports = (robot) ->
  #
  # Get a count of downloads
  #
  robot.hear /mautic growth/i, (msg) ->
    exec "php /opt/mautibot/php/fetch_growth_counts.php", (err, stdout, stderr) ->
      data = JSON.parse(stdout);
      msg.send "SaaS Signups:\nhttps://marty.mautic.com/" + data.signup_image + "\n\n"
      msg.send "Downloads:\nhttps://marty.mautic.com/" + data.download_image

