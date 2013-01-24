class DomainsController < ApplicationController
  # @domain is already loaded in an application_controller before_filter

  # GET /admin
  # GET /admin.json
  def show
    authorize! :read, @domain
    respond_to do |format|
      format.html # show.html.erb
      format.css { render :text => @domain.css, :content_type => "text/css" }
      format.json { render json: @domain }
    end
  end

  def delete_banner
    authorize! :manage, @domain
    @domain.banner.destroy
    respond_to do |format|
      format.html { redirect_to domains_url, notice: 'Domain was successfully updated.' }
      format.json { head :no_content }
      format.js
    end
  end

  # PUT /admin
  # PUT /admin.json
  def update
    authorize! :manage, @domain
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
