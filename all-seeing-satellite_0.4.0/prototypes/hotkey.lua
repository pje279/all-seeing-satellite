Constants = require("libs.constants.settings-constants")

data:extend({
  {
    type = "custom-input",
    name = Constants.HOTKEY_EVENT_NAME.name,
    key_sequence = Constants.HOTKEY_EVENT_NAME.value,
    consuming = "none",
    localised_name = 'Toggle Satellite'
  }
})