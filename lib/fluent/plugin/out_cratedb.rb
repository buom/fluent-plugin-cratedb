require 'crate_ruby'
require 'fluent/output'

module Fluent
  class Fluent::CratedbOutput < Fluent::BufferedOutput
    Fluent::Plugin.register_output('cratedb', self)

    include Fluent::SetTimeKeyMixin
    include Fluent::SetTagKeyMixin
    include Fluent::HandleTagNameMixin

    config_param :host, :string, :default => 'localhost', :desc => "CrateDB host."
    config_param :port, :integer, :default => 4200, :desc => "CrateDB port."
    config_param :hosts, :array, :default => nil
    config_param :http_options, :hash, :default => {}
    config_param :column_names, :string, :desc => "Bulk insert column."
    config_param :key_names, :string, :default => nil
    config_param :table, :string, :desc => "Bulk insert table."
    config_param :http_auth, :bool, :default => false, :desc => "Enable HTTP auth."
    config_param :user, :string, :default => nil, :desc => "HTTP user."
    config_param :password, :string, :default => nil, :desc => "HTTP password."

    # Define `log` method for v0.10.42 or earlier
    unless method_defined?(:log)
      define_method("log") { $log }
    end

    def configure(conf)
      super

      if @column_names.nil?
        fail Fluent::ConfigError, 'column_names MUST specified, but missing'
      end

      @column_names = @column_names.split(',').collect(&:strip)
      @key_names = @key_names.nil? ? @column_names : @key_names.split(',').collect(&:strip)
 
      @servers = @hosts ? @hosts : ["#{@host}:#{@port}"]
    end

    def start
      super
      opts = {:http_options => @http_options, :logger => log}
      begin
        @client = CrateClient.new(@servers, opts)
        log.info "CrateDB connection confirmed: #{@servers.join(", ")}"
      rescue => e
        raise e
      end
    end

    def shutdown
      super
    end

    def format(tag, time, record)
      [tag, time, format_proc.call(tag, time, record)].to_msgpack
    end

    def write(chunk)
      values = []
      chunk.msgpack_each do |tag, time, data|
        #data = format_proc.call(tag, time, data)
        values << data
      end
      sql = "INSERT INTO #{@table} (#{@column_names.join(',')}) VALUES (#{ @column_names.map { |key| '?' }.join(',') })"
      @client.execute(
        sql,
        nil,
        values,
        @http_options,
        @http_auth,
        @user,
        @password,
      )
    end


    private

    def format_proc
      proc do |tag, time, record|
        values = []
        @key_names.each_with_index do |key, i|
          value = record[key]
          values << value
        end
        values
      end
    end
  end

  class CrateClient < CrateRuby::Client

    def initialize(servers = [], opts = {})
      super(servers, opts)
    end

    # Copy from https://github.com/crate/crate_ruby/blob/master/lib/crate_ruby/client.rb#L95
    #
    # Executes a SQL statement against the Crate HTTP REST endpoint.
    # @param [String] sql statement to execute
    # @param [Array] args Array of values used for parameter substitution
    # @param [Hash] Net::HTTP options (open_timeout, read_timeout)
    # @return [ResultSet]
    def execute(sql, args = nil, bulk_args = nil, http_options = {}, http_auth = false, user = nil, password = nil)
      @logger.debug sql
      req = Net::HTTP::Post.new("/_sql", initheader = {'Content-Type' => 'application/json'})
      body = {"stmt" => sql}
      body.merge!({'args' => args}) if args
      body.merge!({'bulk_args' => bulk_args}) if bulk_args
      req.body = body.to_json
      if http_auth
        req.basic_auth user, password
      end
      response = request(req, http_options)
      @logger.debug response.body
      success = case response.code
                  when /^2\d{2}/
                    ResultSet.new response.body
                  else
                    @logger.info(response.body)
                    raise CrateRuby::CrateError.new(response.body)
                end
      success
    end
  end
end
