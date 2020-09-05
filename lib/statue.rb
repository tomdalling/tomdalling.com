module Statue
  PROJECT_ROOT = Pathname(__dir__).parent
  INPUT_DIR = PROJECT_ROOT / 'input'
  OUTPUT_DIR = PROJECT_ROOT / 'output'
  TEMPLATES_DIR = PROJECT_ROOT / 'templates'

  #TODO: move this to config
  BASE_URL = "https://www.tomdalling.com"
end
