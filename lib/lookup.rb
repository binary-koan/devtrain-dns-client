require "socket"
require_relative "../lib/dns_query"
require_relative "../lib/dns_query_parser"

module SocketLookup
  module_function

  def lookup(name_server:, domain_name:, record_type:)
    query = DNSQuery.new(3)
    query.questions << domain_name

    data, _ = udp_lookup(ip: name_server, port: 53, query: query)

    DNSQueryParser.new(data).parse
  end

  def udp_lookup(ip:, port:, query:)
    socket = UDPSocket.new
    socket.connect(ip, port)
    socket.send(query.build, 0)

    socket.recvfrom(512) # UDP DNS requests are limited to 512 bytes
  end
end
