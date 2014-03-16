# Application-wide settings
settings =
  PORT: 3000
  SECRET_KEY: '24kjbakjbiouhsdboiua083'


# Override any defined property with environment vars, if set
for key, val in settings
  settings[key] = process.env[key] or val

module.exports = settings
