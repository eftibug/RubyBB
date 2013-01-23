class DomainsController < ApplicationController
  before_filter :authenticate_user!

  # @domain is already loaded in an application_controller before_filter

  # GET /admin
  # GET /admin.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @domain }
    end
  end

  # PUT /admin
  # PUT /admin.json
  def update
    respond_to do |format|
      if @domain.update_attributes(params[:domain])
        format.html { redirect_to domains_url, notice: 'Domain was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: :show }
        format.json { render json: @domain.errors, status: :unprocessable_entity }
      end
    end
  end
end
