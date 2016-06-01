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
      msg.send "There has been #{data.total} total unique downloads with #{data.latest.download_count} for #{data.latest.title} and #{data.today} today. #{data.active} have been active within the last 30 days."

  #
  # Get count for today
  #
  robot.hear /mautic daily/i, (msg) ->
  	exec "php /opt/mautibot/php/fetch_download_counts.php", (err, stdout, stderr) ->
  		download_data = JSON.parse(stdout);
  		exec "php /opt/mautibot/php/fetch_hosted_counts.php", (err, stdout, stderr) ->
  			hosted_data = JSON.parse(stdout);
	  		total_daily = +download_data.today + +hosted_data.today;
  			msg.send "Today there has been #{download_data.today} downloads and #{hosted_data.today} new cloud accounts, for a total of #{total_daily} new accounts."

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
      msg.send "There has been #{data.total} total unique downloads with #{data.latest.download_count} for #{data.latest.title} and #{data.today} today. #{data.active} have been active within the last 30 days."
    exec "php /opt/mautibot/php/fetch_hosted_counts.php", (err, stdout, stderr) ->
      data = JSON.parse(stdout);
      message = "For SaaS, there are currently: \n"
      for k,v of data
        message = message + "    #{v} #{k}\n"

      msg.send message