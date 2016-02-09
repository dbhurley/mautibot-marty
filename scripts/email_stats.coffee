{spawn, exec} = require 'child_process'

execCommand = (msg, cmd) ->
  exec cmd, (error, stdout, stderr) ->
    msg.send error
    msg.send stdout
    msg.send stderr

module.exports = (robot) ->
  robot.hear /email stats\s?($|today|yesterday$)/i, (msg) ->
    msg.send "This may take a minute as the mail log is parsed...\n"
    dateCommand = ''
    if msg.match[1]
      dateCommand = " -d #{msg.match[1]}"
    exec "ssh -t -i /root/.ssh/id_rsa root@mail.mautic.com 'pflogsumm --detail=5 --bounce-detail=0#{dateCommand} /var/log/mail.log'", (err, stdout, stderr) ->
      msg.send stdout