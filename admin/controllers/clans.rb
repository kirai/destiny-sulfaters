Sulfaters::Admin.controllers :clans do
  get :index do
    @title = "Clans"
    @clans = Clan.all
    render 'clans/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'clan')
    @clan = Clan.new
    render 'clans/new'
  end

  post :create do
    @clan = Clan.new(params[:clan])
    if @clan.save
      @title = pat(:create_title, :model => "clan #{@clan.id}")
      flash[:success] = pat(:create_success, :model => 'Clan')
      params[:save_and_continue] ? redirect(url(:clans, :index)) : redirect(url(:clans, :edit, :id => @clan.id))
    else
      @title = pat(:create_title, :model => 'clan')
      flash.now[:error] = pat(:create_error, :model => 'clan')
      render 'clans/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "clan #{params[:id]}")
    @clan = Clan.find(params[:id])
    if @clan
      render 'clans/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'clan', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "clan #{params[:id]}")
    @clan = Clan.find(params[:id])
    if @clan
      if @clan.update_attributes(params[:clan])
        flash[:success] = pat(:update_success, :model => 'Clan', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:clans, :index)) :
          redirect(url(:clans, :edit, :id => @clan.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'clan')
        render 'clans/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'clan', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Clans"
    clan = Clan.find(params[:id])
    if clan
      if clan.destroy
        flash[:success] = pat(:delete_success, :model => 'Clan', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'clan')
      end
      redirect url(:clans, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'clan', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Clans"
    unless params[:clan_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'clan')
      redirect(url(:clans, :index))
    end
    ids = params[:clan_ids].split(',').map(&:strip)
    clans = Clan.find(ids)
    
    if Clan.destroy clans
    
      flash[:success] = pat(:destroy_many_success, :model => 'Clans', :ids => "#{ids.to_sentence}")
    end
    redirect url(:clans, :index)
  end
end
