Rails.application.routes.draw do
  devise_for :users
  get 'welcome/index'
  get '/myCompetitions', :to =>'concursos#myCompetitions', as: :my_Competitions
  get 'concurso/:url' => 'concursos#show', as: :show_concursos
  get 'concursoP/:url' => 'concursos#showParticipant', as: :show_concursosP
  
  get 'concurso/delete/:url' => 'concursos#borrar', as: :delete_concursos
  get 'concurso/modify/:url' => 'concursos#modificar', as: :modificar_concursos
  get 'concurso/update/:url' => 'concursos#actualizar', as: :actualizar_concursos
  get 'concursos' => 'concursos#all', as: :all_concursos
  get 'videos/new/:url' => 'videos#new', as: :nuevo_video

  root 'welcome#index'

  # Resources
  resources :concursos
  resources :videos
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
