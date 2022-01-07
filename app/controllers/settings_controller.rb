class SettingsController < ApplicationController

  def new
    @setting = Setting.new
  end
  
  def create
    @setting = current_user.build_setting(setting_params)
    @setting.save
    render json: @setting
  end
  
  def edit
    @setting = current_user.setting
  end
  
  def update
    @setting = current_user.setting.update(setting_params)
    render json: @setting
  end

  def new_setting; end

  def edit_setting; end


  private
  
  def setting_params
    params.require(:setting).permit(:prefecture_code, :push_time)
  end

end
