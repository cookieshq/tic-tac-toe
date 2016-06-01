Rails.application.routes.draw do
  root to: "grid#index"
  mount ActionCable.server => "/cable"
end
