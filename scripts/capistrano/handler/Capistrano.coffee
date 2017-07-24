spawn   = require('child_process').spawn
carrier = require 'carrier'
{spawn, exec} = require 'child_process'

execCommand = (msg, cmd) ->
  exec cmd, (error, stdout, stderr) ->
    msg.send error
    msg.send stdout
    msg.send stderr

class Capistrano
  execute: (project, username, stage, command, msg, robot) ->
    exec "cd " + process.env.HUBOT_CAP_DIR + " && git pull && cd../ && bundle install"
    path = process.env.HUBOT_CAP_DIR + project
    process.chdir(path);

    env = Object.create( process.env );
    env.HOME = "/root/"
    env.PATH = "/usr/local/rvm/gems/ruby-2.3.0/bin:/usr/local/rvm/gems/ruby-2.3.0@global/bin:/usr/local/rvm/rubies/ruby-2.3.0/bin:" + env.PATH
    env.GEM_HOME = "/usr/local/rvm/gems/ruby-2.3.0"
    env.GEM_PATH = "/usr/local/rvm/gems/ruby-2.3.0:/usr/local/rvm/gems/ruby-2.3.0@global"
    env.USERNAME = username
    env.USER     = username

    msg.send "Executing `cap #{stage} #{command}` for `#{project}`. Please wait..."

    cap = spawn 'bundle', ['exec', 'cap', stage, command], { env: env, timeout: 0}

    # Get output then on exit, send to slack
    @output = ''
    @streamResult cap

    cap.on 'exit', (code) =>
      msgData = {
        channel: 'deployments'
        username: 'Marty the Deployer'
        icon_emoji: ':mautibot:'
        message: msg.message
        attachments: [
          {
            fallback: "Type `log [project] [stage]` to see full log",
            title: "Deployment log"
            fields: [
              {
                title: "Project"
                value: project
              },
              {
                title: "Stage"
                value: stage
              },
              {
                title: "Command"
                value: command
              }
            ]
            text: @output.trim()
            mrkdwn_in: ["text"]
          }
        ]
      }

      robot.adapter.customMessage msgData

      channelName = if msg.message.envelope
        msg.message.envelope.room
      else msg.message.room

      if channelName != 'deployments'
        msg.send "Done! Checkout <#G0ZCQHNNB|deployments> for the result."

  streamResult: (cap) ->
    capOut = carrier.carry cap.stdout
    capErr = carrier.carry cap.stderr

    capOut.on 'line', (line) =>
      @output += line + "\n"

    capErr.on 'line', (line) =>
      @output += "*" + line + "*\n"

module.exports = Capistrano
