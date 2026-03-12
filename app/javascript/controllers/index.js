// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "./application"
import MediaToggleController from "./media_toggle_controller"
import SwipeController from "./swipe_controller"

application.register("media-toggle", MediaToggleController)
application.register("swipe", SwipeController)
