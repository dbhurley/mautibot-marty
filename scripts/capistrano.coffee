FolderReader      = require './capistrano/handler/FolderReader'
PermissionHandler = require './capistrano/handler/PermissionHandler'
Capistrano        = require './capistrano/handler/Capistrano'

if (!process.env.HUBOT_CAP_DIR)
  throw new Error 'You must define the env HUBOT_CAP_DIR'

folder     = new FolderReader process.env.HUBOT_CAP_DIR
permission = new PermissionHandler folder
cap        = new Capistrano

module.exports = (robot) ->

  robot.hear /list projects/i, (msg) ->
    username = msg.message.user.name

    if (permission.hasPermission username, 'global')
      msg.send "Project list: #{folder.getProjects().join(', ')}"

  robot.hear /(cap|capistrano) ([a-z0-9]+) ([a-z0-9]+) (.*)/i, (msg) ->
    robot.brain.set('oe', 'a')
    project  = msg.match[2]
    stage = msg.match[3]
    command  = msg.match[4]
    username = msg.message.user.name

    if (!permission.hasPermission username, 'global')
      return false

    if (!folder.projectExists project)
      return msg.send "This project doesn't exists."

    if (!permission.hasPermission username, project)
      msg.send "You don't have permission in this project"
      msg.send "Please talk with @#{permission.getUsers(project)}" if permission.getUsers(project).length > 0
      return false

    msg.send "Please wait..."

    cap.execute project, stage, command, msg
