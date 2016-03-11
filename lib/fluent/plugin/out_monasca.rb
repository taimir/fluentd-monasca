# encoding: UTF-8
require 'date'
require 'uri'

require_relative './monasca/monasca_log_api_client'
require_relative './keystone/keystone_client'

begin
  require 'strptime'
rescue LoadError
end

class Fluent::MonascaOutput < Fluent::BufferedOutput
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
    # @keystone_client = Keystone::Client.new @keystone_url
    # @monasca_log_api_client = MonascaLogApiClient.new @monasca_log_api, @monasca_log_api_version
    # @token = authenticate
    # @logger.inf('Authenticated keystone user:', username: @username, project_name: @project_name)
  end

  # open connection to monasca.
  # initialize client
  def start
    super
  end

  # shut down the plugin.
  def shutdown
    super
  end

  # handle fluentd event
  def format(tag, time, record)
  end

  # write the buffered chunk to monasca
  def write(_chunk)
    log.debug('${chunk}')
  end

  # send the log message to monasca
  def send(data)
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

  def send_log(data, dimensions)
    @monasca_log_api_client.send_event(nil, data, @token.id, dimensions, 'application: json') if @token.id && data
  end
end
