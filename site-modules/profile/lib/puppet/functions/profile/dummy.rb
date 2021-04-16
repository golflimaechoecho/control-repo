require 'nokogiri'
require 'net/http'

# Nokogiri stupidness
Puppet::Functions.create_function(:'profile::dummy') do
  # @param host host to connect to
  # @param port port to connect to
  dispatch :dummy do
    param 'String', :host
    param 'String', :port
  end
  def dummy(host, port)
    data = {
      "environment": "production",
      "task": "package",
      "params": {
        "action": "status",
        "name": "httpd"
      },
      "scope": {
        "nodes": [ "ip-172-31-38-55.ap-southeast-2.compute.internal" ]
      }
    }
    headers = { 'content-type' => 'application/json', 'X-Authentication' => '0RxZgd2x2QOr9OglKGuKTQYl_ErVLs5NtMNYyDT-3ZtQ' }
    @http = Net::HTTP.new(host, port)

    @http.request_post('/command/task', data, headers)
    nk = Nokogiri(response.body)
    [nk.xpath('//soapenv:Body/*').select(&:element?).first, response.body.size]
  end
end
