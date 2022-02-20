# frozen_string_literal: true

require './app/controllers/app_controller'
require './app/controllers/pressure_controller'

use PressureController
run AppController
