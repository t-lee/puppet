#!/usr/bin/env ruby1.9.3

# send a sms with www.any-sms.biz

require 'logger'
require 'yaml'
require 'optparse'
require 'uri'
require 'net/https'
require 'net/http'

module Nagios

MAX_SMS_PER_DAY = 50
KEEP_SMS_IN_HOURS = 24
ALLOW_SMS_EVERY_MINUTE = 60
NOW = Time.now
SMS_LIST_FILE = '/var/lib/sms_sender/sms_list.yaml'
LOG_FILE = '/var/log/sms_sender/send_sms.log'

options = {
  :absender => 'Nagios', 
#  :test => 1,
  :gateway => 15,
  :id => 102788,
  :pass => '6qzhexkb',
}
optparse = OptionParser.new do |opts|
  opts.banner = 'Usage: send_sms [options]'
  opts.on('-t', '--text TEXT', 'Set SMS text') {|text| options[:text] = text}
  opts.on('-n', '--number NUMBER', 'Set SMS number') {|number| options[:nummer] = number}
  opts.on('-i', '--id ID', 'ID of SMS account') {|id| options[:id] = id.to_i}
  opts.on('-p', '--password PASSWORD', 'Password of SMS account') {|pass| options[:pass] = pass}
  opts.on('-g', '--gateway GATEWAY', 'SMS gateway number') {|gateway| options[:gateway] = gateway.to_i}
  opts.on('-h', '--help', 'Display this screen') {puts opts; exit}
end
optparse.parse!
  
class SMSSender
  def send options
    uri = URI('http://www.any-sms.biz/gateway/send_sms.php')
    uri.query = URI.encode_www_form options

    Net::HTTP.start(uri.host, 443, :use_ssl => true, :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
      request = uri.path+'?'+uri.query
      $logger.debug "request: #{request}"
      resp = http.get request
      if resp.code == '200'
        $sms_list.log({
          :options => options, :request => request, :response => resp.body,
          :timestamp => NOW.to_i, :time => NOW,
        })
        response = resp.body.gsub("\n", ' ').gsub(":", '=')
        $logger.debug "response: #{response}"
        puts response
      else
        $logger.debug "request: #{request}"
        $logger.debug "response code: "+resp.code        
      end
    end
  end
end

class SMSList  
  def initialize
    read_from_disk
  end

  def log entry = {}
    @list << entry
    write_to_disk
  end

  def can_send_sms_in_max_days?
    $logger.debug "can_send_sms_in_max_days?: #{@list.size < MAX_SMS_PER_DAY}"  
    return @list.size < MAX_SMS_PER_DAY
  end
    
  def can_send_sms_in_allow_time?
    @list.each do |entry|
      sms_time = entry[:time]
      age_of_sms_in_minutes = ((NOW - sms_time) / 60).round
      if age_of_sms_in_minutes < ALLOW_SMS_EVERY_MINUTE
        $logger.debug "can_send_sms_in_allow_time?: false, age_of_sms_in_minutes=#{age_of_sms_in_minutes}"  
        return false 
      end
    end
    $logger.debug "can_send_sms_in_allow_time?: true"  
    true
  end
  
  private
    
  def is_current? entry
    sms_time = entry[:time]
    age_of_sms_in_hours = ((NOW - sms_time) / 3600).round
  
    $logger.debug "age_of_sms_in_hours: #{age_of_sms_in_hours} (#{entry[:time]}), is_current? #{age_of_sms_in_hours < KEEP_SMS_IN_HOURS}"  
    age_of_sms_in_hours < KEEP_SMS_IN_HOURS
  end
  
  def read_from_disk
    @list = []
    begin
      loaded_list = YAML.load_file SMS_LIST_FILE || []
      loaded_list.each {|entry| @list << entry if is_current? entry} 
    rescue
      write_to_disk
    end    
  end
    
  def write_to_disk 
    File.open(SMS_LIST_FILE, 'w') {|f| f.write @list.to_yaml}
  end
  
end
 
$logger = Logger.new(LOG_FILE, 'daily')
$sms_list = SMSList.new
$sms_sender = SMSSender.new

if $sms_list.can_send_sms_in_allow_time? or $sms_list.can_send_sms_in_max_days?
  if options[:nummer] and options[:text]
    msg = "Number (#{options[:nummer]}), Text(#{options[:text]})."
    $logger.info msg; puts msg
    $sms_sender.send options
  else
    msg = "Missing number (#{options[:nummer]}) or text(#{options[:text]})."
    $logger.info msg; puts msg
  end
else
  msg = "throttle: can not send sms to #{options[:nummer]}:#{options[:text]}"
  $logger.info msg; puts msg
end

end #module Nagios
