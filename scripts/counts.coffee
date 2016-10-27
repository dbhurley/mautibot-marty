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
  # Get count for total
  #
  robot.hear /mautic total/i, (msg) ->
  	exec "php /opt/mautibot/php/fetch_download_counts.php", (err, stdout, stderr) ->
  		download_data = JSON.parse(stdout);
  		exec "php /opt/mautibot/php/fetch_hosted_counts.php", (err, stdout, stderr) ->
  			hosted_data = JSON.parse(stdout);
	  		total_userbase = +download_data.total + +hosted_data.total;
  			msg.send "In total there have been #{download_data.total} downloads and #{hosted_data.total} new cloud accounts, for a grand total of *#{total_userbase}* new accounts."

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
      total_downloads = data.total;
      msg.send "There has been #{data.total} total unique downloads with #{data.latest.download_count} for #{data.latest.title} and #{data.today} today. #{data.active} have been active within the last 30 days."
    exec "php /opt/mautibot/php/fetch_hosted_counts.php", (err, stdout, stderr) ->
      hosted_data = JSON.parse(stdout);
      message = "For SaaS, there are currently: \n"
      for k,v of hosted_data
        message = message + "    #{v} #{k}\n"

      msg.send message

  #
  # Get a total count of downloads and hosted
  #
  robot.hear /mautic github stats\s?(20\d\d-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01]))?\s?(20\d\d-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01]))?/i, (msg) ->
    fromDate = if typeof msg.match[1] != 'undefined' then msg.match[1] else ''
    toDate   = if typeof msg.match[4] != 'undefined' then msg.match[4] else ''

    exec "php /opt/mautibot/php/fetch_hubstat_counts.php #{fromDate} #{toDate}", (err, stdout, stderr) ->
      data    = JSON.parse(stdout);
      message = "Between #{data['fromDate']} and #{data['toDate']}\n\n"
      delete data['fromDate'];
      delete data['toDate'];

      message = message + "\n*Pull Requests:*\n"
      for k,v of data['prs']
          message = message + "    #{k} #{v}\n"
      delete data['prs']

      message = message + "\n*Top 10 Contributors:* (#{data['contributor_string']})\n"
      for user,groupStats of data['contributors']
        message = message + "\n    #{user}\n"
        for k,v of groupStats
          message = message + "        #{k} #{v}\n"
      delete data['contributors'];

      message = message + "\n*Comments*\n"
      for k,v of data['comments']
          message = message + "    #{k} #{v}\n"
      delete data['comments']

      message = message + "\n*Top 10 Commentators* (#{data['commenter_string']})\n"
      for user,count of data['commenters']
        message = message + "    #{user} #{count}\n"
      delete data['commenters'];

      msg.send message