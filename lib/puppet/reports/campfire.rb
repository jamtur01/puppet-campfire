require 'puppet'

begin
  require 'tinder'
rescue LoadError => e
  Puppet.info "You need the `tinder` gem to use the campfire report"
end

Puppet::Reports.register_report(:campfire) do

CAMPFIRE = "your-campfire-subdomain"
CAMPFIRE_TOKEN = "your-campfire-token"

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
