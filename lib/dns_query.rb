class DNSQuery
  RECORD_TYPE = {
    "A" => 0x01,
    "NS" => 0x02,
    "CNAME" => 0x05,
    "PTR" => 0x0c,
    "MX" => 0x0f,
    "SRV" => 0x21,
    "IXFR" => 0xfb,
    "AXFR" => 0xfc,
    "ALL" => 0xff
  }

  attr_accessor :id
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

    question_bytes = @questions.map do |question|
      parts = question[:domain].split(".").map do |part|
        part.size.chr + part
      end.join("")

      type = RECORD_TYPE[question[:type] || "A"]

      parts + 0.chr + [type].pack("n") + [0x0001].pack("n")
    end.join("")

    header_bytes + question_bytes
  end
end
