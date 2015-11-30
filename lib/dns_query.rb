class DNSQuery
  def self.from_data(data)
    DNSQuery.new.tap { |query| query.parse(data) }
  end

  attr_accessor :id, :type
  attr_accessor :questions, :answers

  def initialize(id=0)
    @id = id
    @questions = []
  end

  def build
    header_bytes = [
      @id,
      0x0100, # query recursively
      @questions.size,
      0, 0, 0 # no other records
    ].pack("n6")

    question_bytes = @questions.map do |domain_name|
      parts = domain_name.split(".").map do |part|
        part.size.chr + part
      end.join("")

      type = 0x01 #TODO support things other than A records

      parts + 0.chr + [type].pack("n") + [0x0001].pack("n")
    end.join("")

    header_bytes + question_bytes
  end
end
