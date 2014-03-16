class Message
    constructor: (@text, @type='info', @icon='envelope') ->


# Flash messaging middleware
exports.messages = (req, res, next) ->
  # Re-initialize message array every request
  messages = res.locals.messages = req.session.messages = []

  # Register the function for controllers to use
  req.message = (type, text) ->
    switch type
      when 'success' then messages.push(new Message(text, 'success', 'ok'))
      when 'error' then messages.push(new Message("<strong>Error: </strong>#{ text }", 'error', 'exclamation-sign'))
      when 'warning' then messages.push(new Message("<strong>Warning: </strong>#{ text }", 'warn', 'flag'))
      else messages.push(new Message(text))

  next()

# Basic authentication middleware
exports.auth = (req, res, next) ->
  if not req.session.userid
      return res.redirect('/login')
  res.locals.userid = req.session.userid
  next()
