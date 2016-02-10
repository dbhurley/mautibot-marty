# Grab XKCD comic image urls
#
# xkcd - The latest XKCD comic
# xkcd <num> - XKCD comic matching the supplied number
# xkcd <search> - XKCD comic matching the search
module.exports = (robot) ->
  robot.respond /xkcd\s?(\d+)?$/i, (msg) ->
    xkcd(msg, msg.match[1])

  robot.respond /xkcd\s([^\s\d].+)/i, (msg) ->
    google msg, "site:xkcd.com #{msg.match[1]}", (url) ->
      if url and id = url.match(/xkcd.com\/(\d+)/)[1]
        xkcd(msg, id)
      else
        msg.send 'Comic not found.'

google = (msg, query, cb) ->
  msg.http('http://www.google.com/search')
    .query(q: query)
    .get() (err, res, body) ->
      cb body.match(/<a href="([^"]*)" class=l>/)?[1]

xkcd = (msg, id) ->
  msg.http("http://xkcd.com/#{if id then id + '/' else ''}info.0.json")
    .get() (err, res, body) ->
      if res.statusCode == 404
        msg.send 'Comic not found.'
      else
        object = JSON.parse(body)
        msg.send object.title, object.img, object.alt
