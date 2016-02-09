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
  robot.hear /download count/i, (msg) ->
    exec "php /opt/mautibot/php/fetch_download_counts.php", (err, stdout, stderr) ->
      data = JSON.parse(stdout);
      msg.send "There has been #{data.total} total unique downloads and #{data.latest.download_count} for #{data.latest.title}"

  #
  # Get a count of hosted instances
  #
  robot.hear /hosted count/i, (msg) ->
    exec "php /opt/mautibot/php/fetch_hosted_counts.php", (err, stdout, stderr) ->
      data = JSON.parse(stdout);
      message = "There are currently: \n"
      for k,v of data
        message = message + "    #{v} #{k}\n"

      msg.send message

  #
  # Get a total count of downloads and hosted
  #
  robot.hear /mautic userbase|dchc/i, (msg) ->
    exec "php /opt/mautibot/php/fetch_download_counts.php", (err, stdout, stderr) ->
      data = JSON.parse(stdout);
      msg.send "There has been #{data.total} total unique downloads and #{data.latest.download_count} for #{data.latest.title}"
    exec "php /opt/mautibot/php/fetch_hosted_counts.php", (err, stdout, stderr) ->
      data = JSON.parse(stdout);
      message = "There are currently: \n"
      for k,v of data
        message = message + "    #{v} #{k}\n"

      msg.send message