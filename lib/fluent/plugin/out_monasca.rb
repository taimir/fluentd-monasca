# encoding: UTF-8
require 'date'
require 'uri'

require_relative './monasca/monasca_log_api_client'
require_relative './keystone/keystone_client'

begin
  require 'strptime'
rescue LoadError
end

class Fluent::MonascaOutput < Fluent::Output
  Fluent::Plugin.register_output('monasca', self)

  config_param :keystone_url, :string
  config_param :monasca_log_api, :string
  config_param :monasca_log_api_version, :string
  config_param :username, :string
  config_param :password, :string, secret: true
  config_param :domain_id, :string
  config_param :project_name, :string

  public

  # Called before start.
  def configure(conf)
    super
  end

  def initialize
    super
  end

  # initialize client
  # open connection to monasca.
  def start
    super
    @keystone_client = Keystone::Client.new @keystone_url, @log
    @monasca_log_api_client = Monasca::get_log_api_client @monasca_log_api, @monasca_log_api_version, @log
    @token = authenticate
    @log.info('Authenticated keystone user:', username: @username, project_name: @project_name)
  end

  # shut down the plugin.
  def shutdown
    super
  end

  # handle fluentd event
  def format(tag, time, record)
  end

  # Unbuffered outputs use emit.
  def emit(tag, es, chain)
    validate_token
    chain.next
    es.each {|time,record|
      # Assume that all non-message keys are dimensions.
      message = record.delete("message")
      dimensions = record
      send_log message, dimensions
    }
  end

  private

  def validate_token
    now = DateTime.now + Rational(1, 1440)
    if now >= @token.expire_at
      @logger.info('Token #{@token} has expired. Issue a new one.')
      @token = get_token
    end
  end

  def authenticate
    @keystone_client.authenticate(@domain_id, @username, @password, @project_name)
  end

  def send_log(message, dimensions)
    @monasca_log_api_client.send_log(message, @token.id, dimensions) if @token.id && message
  end
end
