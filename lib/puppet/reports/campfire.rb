require 'puppet'
require 'yaml'

begin
  require 'tinder'
rescue LoadError => e
  Puppet.info "You need the `tinder` gem to use the campfire report"
end

Puppet::Reports.register_report(:campfire) do

  configfile = File.join([File.dirname(Puppet.settings[:config]), "campfire.yaml"])
  raise(Puppet::ParseError, "Campfire report config file #{configfile} not readable") unless File.exist?(configfile)
  config = YAML.load_file(configfile)
  CAMPFIRE = config[:domain]
  CAMPFIRE_TOKEN = config[:token]

  desc <<-DESC
  Send report information to Campfire.
  DESC

  def process
    if self.status == 'failed'
      Puppet.debug "Sending status for #{self.host} to Campfire #{CAMPFIRE}"
      campfire = Tinder::Campfire.new(CAMPFIRE, :token => CAMPFIRE_TOKEN)
      campfire.rooms.first.speak("Puppet run for #{self.host} #{self.status}")
      output = []
      self.logs.each do |log|
        output << log
      end
      campfire.rooms.first.paste(output.join("\n"))
    end
  end
end
