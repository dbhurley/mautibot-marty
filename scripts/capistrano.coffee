FolderReader      = require './capistrano/handler/FolderReader'
PermissionHandler = require './capistrano/handler/PermissionHandler'
Capistrano        = require './capistrano/handler/Capistrano'

if (!process.env.HUBOT_CAP_DIR)
  throw new Error 'You must define the env HUBOT_CAP_DIR'

folder     = new FolderReader process.env.HUBOT_CAP_DIR
permission = new PermissionHandler folder
cap        = new Capistrano

module.exports = (robot) ->

  robot.hear /mautibot list projects/i, (msg) ->
    username = msg.message.user.name

    if (permission.hasPermission username, 'global')
      msg.send "Project list: #{folder.getProjects().join(', ')}"

  robot.hear /mautibot list stages ([a-z0-9]+)/i, (msg) ->
    username = msg.message.user.name

    if (msg.match[1]?)
      project = msg.match[1];
      if (!folder.projectExists project)
        projects = '`'
        projects += folder.getProjects().join('`, `')
        projects += '`'

        msg.send "`#{project}` does not exist. Available projects are #{projects}"

      if (permission.hasPermission username, project)
          msg.send "Stages for `#{project}` include #{permission.getStages(project)}"

  robot.hear /mautibot (cap|capistrano|deploy|rollback) ([a-z0-9]+) ([a-z0-9]+)\s?(.*)?/i, (msg) ->
    robot.brain.set('oe', 'a')

    command = ''
    if (msg.match[4]?)
      command = msg.match[4]

    if msg.match[1] == 'deploy'
      command = 'deploy' + command
    else if msg.match[1] == 'rollback'
      command ='deploy:rollback' + command

    project = msg.match[2]
    stage = msg.match[3]

    username = msg.message.user.name

    if (!permission.hasPermission username, 'global')
      return false

    if (!folder.projectExists project)
      projects = '`'
      projects += folder.getProjects().join('`, `')
      projects += '`'

      msg.send "`#{project}` does not exist. Available projects are #{projects}"

    if (!permission.hasPermission username, project)
      msg.send "You don't have permission in this project"
      msg.send "Please talk with @#{permission.getUsers(project)}" if permission.getUsers(project).length > 0
      return false

    if (!permission.stageExists project, stage)
      return msg.send "Stage `#{stage}` does not exist. Stages for `#{project}` include #{permission.getStages(project)}"

    cap.execute project, username, stage, command, msg, robot
