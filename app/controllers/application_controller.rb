class ApplicationController < ActionController::Base
	require 'will_paginate/array'
  protect_from_forgery

	before_filter :set_locale
	before_filter :is_browser_supported?
	before_filter :preload_global_variables
	before_filter :initialize_gon
	before_filter :store_location

	unless Rails.application.config.consider_all_requests_local
		rescue_from Exception,
		            :with => :render_error
		rescue_from ActiveRecord::RecordNotFound,
		            :with => :render_not_found
		rescue_from ActionController::RoutingError,
		            :with => :render_not_found
		rescue_from ActionController::UnknownController,
		            :with => :render_not_found
		rescue_from ActionController::UnknownAction,
		            :with => :render_not_found

    rescue_from CanCan::AccessDenied do |exception|
      redirect_to root_url, :alert => exception.message
    end
	end

	Browser = Struct.new(:browser, :version)
	SUPPORTED_BROWSERS = [
		Browser.new("Chrome", "15.0"),
		Browser.new("Safari", "4.0.2"),
		Browser.new("Firefox", "10.0.2"),
		Browser.new("Internet Explorer", "9.0"),
		Browser.new("Opera", "11.0")
	]

	def is_browser_supported?
		user_agent = UserAgent.parse(request.user_agent)
logger.debug "////////////////////////// BROWSER = #{user_agent}"
#		if SUPPORTED_BROWSERS.any? { |browser| user_agent < browser }
#			# browser not supported
#logger.debug "////////////////////////// BROWSER NOT SUPPORTED"
#			render "layouts/unsupported_browser", :layout => false
#		end
	end


	def set_locale
    if params[:locale] and I18n.available_locales.include?(params[:locale].to_sym)
      I18n.locale = params[:locale]
    else
      I18n.locale = I18n.default_locale
    end
	end

  def default_url_options(options={})
    { :locale => I18n.locale }
  end

	def preload_global_variables
    # indicate that whether login should allow local and omniauth or just locale
	  @enable_omniauth = false

    # breakdown the referer into controller/action
    # this is used so know whether to return to home page or timestamps page
    referer = Rails.application.routes.recognize_path(request.referrer) if request.referrer.present?
    if referer.present?
      @referer_controller = referer[:controller]
      @referer_action = referer[:action]
    end
  end

	def initialize_gon
		gon.set = true
		gon.highlight_first_form_field = params[:controller].present? && params[:controller].start_with?('devise/')

		if I18n.locale == :ka
		  gon.datatable_i18n_url = "/datatable_ka.txt"
		else
		  gon.datatable_i18n_url = ""
		end
	end

	def after_sign_in_path_for(resource)
		session[:previous_urls].last || request.env['omniauth.origin'] || root_path(:locale => I18n.locale)
	end

  def valid_role?(role)
    redirect_to root_path, :notice => t('app.msgs.not_authorized') if !current_user || !current_user.role?(role)
  end

	# store the current path so after login, can go back
	# only record the path if this is not an ajax call and not a users page (sign in, sign up, etc)
	def store_location
		session[:previous_urls] ||= []
		if session[:previous_urls].first != request.fullpath && 
        params[:format] != 'js' && params[:format] != 'json' && !request.xhr? &&
        request.fullpath.index("/users/").nil?
        
	    session[:previous_urls].unshift request.fullpath
    elsif session[:previous_urls].first != request.fullpath &&
       request.xhr? && !request.fullpath.index("/users/").nil? &&
       params[:return_url].present?
       
      session[:previous_urls].unshift params[:return_url]
		end

		session[:previous_urls].pop if session[:previous_urls].count > 1
    #Rails.logger.debug "****************** prev urls session = #{session[:previous_urls]}"
	end
	
  # add in required content for translations if none provided
  # - if default locale does not have translations, use first trans that does as default
  def add_missing_translation_content(ary_trans)
    if ary_trans.present?
      default_trans = ary_trans.select{|x| x.locale == I18n.default_locale.to_s}.first
  
      if default_trans.blank? || !default_trans.required_data_provided?
        # default locale does not have data so get first trans that does have data
        ary_trans.each do |trans|
          if trans.required_data_provided?
            default_trans = trans
            break
          end
        end
      end

      if default_trans.present? && default_trans.required_data_provided?
        ary_trans.each do |trans|
          if trans.locale != default_trans.locale && !trans.required_data_provided?
            # add required content from default locale trans
            trans.add_required_data(default_trans)
          end
        end
      end
    end
  end

	
  # load data for the charts
  def load_data_for_charts(records, dates, chart_xaxis_key, chart_yaxis_key, i18n_key, is_summary=false, item_name=nil)
    # set dates for datepicker
    gon.start_at = params[:timestamp_start_at].to_s if params[:timestamp_start_at].present?
    gon.end_at = params[:timestamp_end_at].to_s if params[:timestamp_end_at].present?
    if dates.present?
      gon.datepicker_dates = dates
      gon.begin_at = dates.first
      gon.last_at = dates.last
    end

    if records[:records].present?

      @timestamps = records[:records]

      gon.chart_data = records[:chart_data]
      gon.xaxis_categories = records[:xaxis_categories]
      if is_summary
        gon.bar_chart_title = I18n.t("#{i18n_key}.bar.title", item: item_name)
      else
        gon.bar_chart_title = I18n.t("#{i18n_key}.bar.title")
      end
      options = {start: params[:timestamp_start_at],
          hours: records[:counts][:hours],
          xaxis: records[:counts][chart_xaxis_key],
          yaxis: records[:counts][chart_yaxis_key]}
      options[:end] = params[:timestamp_end_at] if i18n_key != 'charts.summary.date'
      gon.bar_chart_subtitle = I18n.t("#{i18n_key}.bar.subtitle", options)
      gon.bar_chart_xaxis = I18n.t("#{i18n_key}.bar.xaxis")
      if is_summary
        gon.pie_chart_title = I18n.t("#{i18n_key}.pie.title", item: item_name)
      else
        gon.pie_chart_title = I18n.t("#{i18n_key}.pie.title")
      end
      gon.pie_chart_subtitle = I18n.t("#{i18n_key}.pie.subtitle", options)

    end
  end

  #######################
	def render_not_found(exception)
		ExceptionNotifier::Notifier
		  .exception_notification(request.env, exception)
		  .deliver
		render :file => "#{Rails.root}/public/404.html", :status => 404
	end

	def render_error(exception)
		ExceptionNotifier::Notifier
		  .exception_notification(request.env, exception)
		  .deliver
		render :file => "#{Rails.root}/public/500.html", :status => 500
	end

end
