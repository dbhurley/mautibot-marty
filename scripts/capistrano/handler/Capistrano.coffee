spawn   = require('child_process').spawn
carrier = require 'carrier'

class Capistrano
  execute: (project, username, stage, command, msg) ->
    path = process.env.HUBOT_CAP_DIR + project
    process.chdir(path);

    env = Object.create( process.env );
    env.HOME = "/root/"
    env.PATH = "/usr/local/rvm/gems/ruby-2.3.0/bin:/usr/local/rvm/gems/ruby-2.3.0@global/bin:/usr/local/rvm/rubies/ruby-2.3.0/bin:" + env.PATH
    env.GEM_HOME = "/usr/local/rvm/gems/ruby-2.3.0"
    env.GEM_PATH = "/usr/local/rvm/gems/ruby-2.3.0:/usr/local/rvm/gems/ruby-2.3.0@global"
    env.USERNAME = username

    cap = spawn 'bundle', ['exec', 'cap', stage, command], { env: env}
    @streamResult cap, msg

  streamResult: (cap, msg) ->
    capOut = carrier.carry cap.stdout
    capErr = carrier.carry cap.stderr
    output = ''

    capOut.on 'line', (line) ->
      output += line + "\n"

    capErr.on 'line', (line) ->
      output += "*" + line + "*\n"

    setInterval () ->
      if output != ""
        msg.send output.trim()
        output = ""
    , 10000

module.exports = Capistrano
