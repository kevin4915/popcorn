// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "./application"
import MediaToggleController from "./media_toggle_controller"
import SwipeController from "./swipe_controller"
import HomeTabsController from "./home_tabs_controller"
import AvatarPreviewController from "./avatar_preview_controller"

application.register("media-toggle", MediaToggleController)
application.register("swipe", SwipeController)
application.register("home-tabs", HomeTabsController)
application.register("avatar-preview", AvatarPreviewController)
