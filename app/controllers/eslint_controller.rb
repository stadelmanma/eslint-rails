class EslintController < ActionController::Base

  before_filter :set_filename

  def show
    @warnings = ESLintRails::Runner.new(@filename).run
  end

  def source
    @source = Rails.application.assets[@filename].to_s
  end

  def config_file
    config = ESLintRails::Config.read(force_default: params[:force_default])
    render json: JSON.pretty_generate(config)
  end

  private

  def set_filename
    @filename = params[:filename] || 'application'
  end
end
