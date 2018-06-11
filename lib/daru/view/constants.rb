# Regex pattern to match a valid URL
PATTERN_URL = Regexp.new(
  '^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$'
).freeze
