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

  QUERY_RECURSIVE = 0x0100
  CLASS_INTERNET = 0x0001
  NULL = 0

  attr_accessor :id
  attr_accessor :questions, :answers

  def initialize(id=0)
    @id = id
    @questions = []
  end

  def build
    question_bytes = @questions.map { |question| build_question(question) }.join("")
    build_header + question_bytes
  end

  private

  def build_header
    [
      @id,
      QUERY_RECURSIVE, # query recursively
      @questions.size,
      0, 0, 0 # no other records
    ].pack("n6")
  end

  def build_question(question)
    parts = question[:domain].split(".").map { |part| part.size.chr + part }
    type = RECORD_TYPE[question[:type] || "A"]

    parts.join("") + NULL.chr + [type].pack("n") + [CLASS_INTERNET].pack("n")
  end
end
