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

  # This method is called when an event stream reaches Fluentd.
  # Convert the event to a raw string using messagepack.
  def format_stream(tag, es)
    # es is a Fluent::OneEventStream or Fluent::MultiEventStream.
    # Each event item gets serialised as a [timestamp, record] array.
    [tag, es.to_msgpack_stream].to_msgpack
  end

  # Buffered outputs use write.
  def write(chunk)
    # chunk is a Fluent::MemoryBufferChunk or Fluent::FileBufferChunk.
    validate_token
    chunk.msgpack_each {|tag, data|
      es = Fluent::MessagePackEventStream.new(data)
      es.each {|time,record|
        message, dimensions = convert_record tag, record
        send_log message, dimensions
      }
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

  # Convert a record into a [message, dimensions] pair.
  def convert_record(tag, record)
    # Assume that all non-message items in the record are dimensions.
    message = record.delete("message")
    dimensions = record
    dimensions["tag"] = tag
    [message, dimensions]
  end

  def send_log(message, dimensions)
    @monasca_log_api_client.send_log(message, @token.id, dimensions) if @token.id && message
  end
end
