module Statue
  PROJECT_ROOT = Pathname(__dir__).parent
  INPUT_DIR = PROJECT_ROOT / 'input'
  DEFAULT_OUTPUT_DIR = PROJECT_ROOT / 'docs'
  TEMPLATES_DIR = PROJECT_ROOT / 'templates'
  WEBPACK_DIR = INPUT_DIR / 'frontend_tire_fire' # TODO: probs shouldn't be a const

  REDESIGN = false # switch to new Tailwind design

  #TODO: move this to config
  BASE_URL = Addressable::URI.parse("https://www.tomdalling.com/")
  GITHUB_BASE_URL = Addressable::URI.parse("https://github.com/tomdalling/tomdalling.com/tree/main/")
end
