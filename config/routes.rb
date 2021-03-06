BbkProject::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.
  resources :tasks do
    member do
    end

    collection do
      get :assign_tasks, :verify_task, :reload_tasks
      post :uploadfile, :publish_flash_task, :uploadfile_flash_source_file
      get 'tasktag_pptlist'
    end
  end
  resources :task_tags do
    member do
    end

    collection do
    end
  end
  resources :users do
    member do
      
    end
    collection do
      post 'login','upload','add_user','modify_user'
      get 'management','confirm_final','download','ajax_download',
        'user_management','edit','disable_user','logout','flash_download'
    end
  end

  resources :calculations do
    member do
    end

    collection do
      get "wage_settlement",'settlement_list','whether_payment'
    end
  end
  resources :messages do
    member do
    end

    collection do
      post :send_msg
      get :reload_msg
    end
  end
  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index1.html.
  root :to => 'users#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
