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
      msg.send "SaaS Signups:\n"
      msg.send "https://marty.mautic.com/" + data.signup_image + "\n"
      message = "Month\tCount\t% Diff\n"
      for k,v of data.signups
        message = message + v.date + "\t" + v.count + "\t" + v.diff + "%\n"
      msg.send message

      msg.send "\n\nDownloads:\n"
      msg.send "https://marty.mautic.com/" + data.download_image + "\n"
      message = "Month\tCount\t% Diff\n"
      for k,v of data.downloads
        message = message + v.date + "\t" + v.count + "\t" + v.diff + "%\n"
      msg.send message